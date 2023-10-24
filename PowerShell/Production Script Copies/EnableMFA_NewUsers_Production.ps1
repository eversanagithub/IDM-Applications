<#
	Program Name: EnableMFA_NewUsers
	Date Written: February 7, 2023
	  Written By: Dave Jaynes
	     Purpose: Removes active users from the No-MFA Users groups and add them to the 
								SSPR, Mobile Responsibilities and Multi-Factor Authentication groups. 
								This targets users whose starting date is today or a past date.
#>

###############################################################
#		Step 1: Assign various local variables.										#
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "EmployeeTransitions"
$SQLTable = "MFA_Onboarding_processed"

###############################################################
#		Step 2: Define the SQL Read and Write functions.					#
###############################################################

function SQLWrite    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MYSQL\Connector NET 8.0\Assemblies\v4.5.2\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$myconnection.Close()
}

function SQLRead    
{
 param(
  [string]$SQLCommand
 )  
 [void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MYSQL\Connector NET 8.0\Assemblies\v4.5.2\MYSql.Data.dll")
 $myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
 $myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
 $myconnection.Open()
 $mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
 $mycommand.Connection = $myconnection
 $mycommand.CommandText = "$SQLCommand"
 $myreader = $mycommand.ExecuteReader()
 $a = while($myreader.Read()){ $myreader.GetString($field) }
 $myconnection.Close()
 $a
}

###############################################################
#		Step 3: Connect to Azure Resources.												#
###############################################################

# Connect to AzAccount for access to Storage Tables
$AzAccountUserName = Get-Content "C:\PowerShell\credentials\PowerBIUserName.txt"
$AzAccountPassword = Get-Content "C:\PowerShell\credentials\EncryptedPowerBiPassword.txt" | ConvertTo-SecureString
$AzureADCredential = New-Object System.Management.Automation.PSCredential($AzAccountUserName,$AzAccountPassword)
Connect-AzAccount -Credential $AzureADCredential|Out-File -Filepath C:\temp\junk.txt

# Connect to Azure Active Directory
$AzureADUserName = Get-Content "C:\PowerShell\credentials\OneDriveRetentionUserName.txt"
$AzureADPassword = Get-Content "C:\PowerShell\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($AzureADUserName,$AzureADPassword)
Connect-AzureAD -Credential $credentials|Out-File -Filepath C:\temp\junk.txt

###############################################################
#		Step 4: Create SQL table if it does not currently exist		#
###############################################################

SQLWrite -SQLCommand "create table if not exists $SQLTable(Employee varchar(70),E_Mail varchar(80),GUID varchar(40),Activation_Date datetime,MFA_Activated bool,SSPR_Activated bool,MAE_Activated bool,DaysBeforeActivation int)"
#Gather the GUIDs for the Multi-Factor Authentication, Single Signon and Mobile Attestation Exception Groups.

###############################################################
#		Step 5: Find the GUID for each f the four groups.					#
###############################################################

# Group UID that enforces No Multi-Factor Authentication.
$nomfagroup = get-azureadgroup -searchstring "Office365_NoMFA" | ? {$_.displayname -notlike "*ServiceAccount" -and $_.displayname -notlike "*SharedMailbox"}
$nomfagroupObjectId = $nomfagroup.objectid

# Group UID that enforces Multi-Factor Authentication.
$mfagroup = get-azureadgroup -searchstring "MFA Default Policy"
$mfagroupObjectId = $mfagroup.objectid

# Group UID that enforces SSPR registration.
$ssprGroup = get-azureadgroup -searchstring "Office365_SSPR_Required"
$ssprGroupObjectId = $ssprGroup.objectid

# Group UID that enforces Mobile Attestation Exception.
$mobileAttestationExceptionGroup = get-azureadgroup -searchstring "Mobile Attestation Exception"
$MAE = $mobileAttestationExceptionGroup.objectid

# Next we gather all the users that are currently in the No Multi-Factor Authentication Group.
# These are folks who have been hired by Eversana but have not yet started their first day at Work.
# Once their Start date reaches todays date, we need to take them out of the No MFA group.
# Additionally we need to remove them from the Moble Attestation Exception Group so they will 
# receive the MAE agreement form on their Mobile Devices when attempting to logon to E-Mail and Teams.
# Finally we need to add them to the Single Sign-On Group so they can reset their own password.

###############################################################
#		Step 6: Process each user in the Office365_NoMFA Group.		#
###############################################################

$noMFAUsers = get-azureadgroupmember -objectid $nomfagroupObjectId
$noMFAUsers | %{
	$user = $_
	$ProcessRecord = 'Yes'
	$Reset = "No"
	$extProps = $user | select -expandproperty ExtensionProperty
	[DateTime]$startDateObj = '2000-01-01 00:00:00'
	$row = ''
	$Date = ''
	$UPN2 = $null
	$UPN = $null
	$UPN2 = $user.UserPrincipalName
	$UPN = $UPN2.ToLower()
	$Employee = ''
	$Employee = $user.DisplayName
	$GUID = $user.objectid
	if($GUID -eq $null -or $GUID -eq '') { $ProcessRecord = 'No' }
	$userEmpNo = $extProps.extension_906e14d00db8455cbcdd210acc93d584_employeeNumber
	# Pull start date from HR
	$Date = Invoke-Sqlcmd -ServerInstance iuatidmgmtsql01.universal.co -Database IAM -Query "select HR.Hire_dt from dbo.HR_Trx HR inner join dbo.Feed_AD_Azure AD on HR.AssociateID = AD.employeeNumber where AD.UPN = '$UPN' ORDER BY HR.Hire_dt OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY"
	try
	{
		$Counter = 0
		foreach($row in $Date)
		{
			$Counter++
			[DateTime]$startDateObj = $row.Item(0)
		}
	}
	catch
	{
		$AA = 0
	}
	
	# If start date not found in HR, look in AD
	if($Counter -eq 0)
	{
		$startDateStr = $extProps.extension_906e14d00db8455cbcdd210acc93d584_extensionAttribute5
		$startDateStr = (($startDateStr -replace "/","") -replace "-","")
		$startDateObj = [datetime]::parseexact($startDateStr, "MMddyyyy", $null)
		$Reset = "Yes"
	}

	# Only process the record if the user GUID is populated.
	if($ProcessRecord -eq 'Yes')
	{
		[String]$Activation_Date = $startDateObj.ToString("yyyy-MM-dd HH:MM:ss")
		$delta = New-TimeSpan -Start $startDateObj -End (get-date)
		$daysDelta = $delta.Days
		if($daysDelta -ge 0)
		{
			# Remove member from the Office365_NoMFA Group if they are currently a member.
			$Check = $null
			$Check = Get-azureadgroupmember -objectid $nomfagroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
			if($Check -ne '' -and $Check -ne $null) { remove-azureadgroupmember -objectid $nomfagroupObjectId -memberid $GUID }

			# Remove member from the Mobile Attestation Exception Group if they are currently a member.
			$Check = $null
			$Check = Get-azureadgroupmember -objectid $MAE -All $true| ? {$_.ObjectId -eq $GUID}
			if($Check -ne '' -and $Check -ne $null) { remove-azureadgroupmember -objectid $MAE -memberid $GUID }
			
			# Add member to the Office365_SSPR_Required Group if they are not currently a member.
			$Check = $null
			$Check = Get-azureadgroupmember -objectid $ssprGroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
			if($Check -eq '' -or $Check -eq $null) { add-azureadgroupmember -objectid $ssprGroupObjectId -refobjectid $GUID }			

			# Add member to the MFA Default Policy Group if they are not currently a member.
			$Check = $null
			$Check = Get-azureadgroupmember -objectid $mfagroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
			if($Check -eq '' -or $Check -eq $null) { add-azureadgroupmember -objectid $mfagroupObjectId -refobjectid $GUID }	
			
			# Update SQL tables to add new entry or update existing ones.
			$QueryGUID = $null
			$DaysBeforeActivation = [Math]::ABS($daysDelta)
			$QueryGUID = SQLRead -SQLCommand "select GUID from $SQLTable where GUID = '$GUID'"
			# Chect to see if they are in the table yet. Add row if they aren't and update row if they are.
			if($QueryGUID -eq '' -or $QueryGUID -eq $null)
			{			
				SQLWrite -SQLCommand "insert into $SQLTable(Employee,E_Mail,GUID,Activation_Date,MFA_Activated,SSPR_Activated,MAE_Activated,DaysBeforeActivation) values ('$Employee','$UPN','$GUID','$Activation_Date',1,1,1,0)"
			}
			else
			{
				SQLWrite -SQLCommand "update $SQLTable set DaysBeforeActivation = '$DaysBeforeActivation',MFA_Activated = 1,SSPR_Activated = 1,MAE_Activated = 1,DaysBeforeActivation = 0 where GUID = '$GUID'"
			}
		}
		else
		{
			# Add the user to the SQL table as in the system but not ready to be activated yet.
			# This way we can track the progress of the user as they get closer to activation time.
			$QueryGUID = $null
			$DaysBeforeActivation = [Math]::ABS($daysDelta)
			$QueryGUID = SQLRead -SQLCommand "select GUID from $SQLTable where GUID = '$GUID'"
			# Chect to see if they are in the table yet. Add row if they aren't and update row if they are.
			if($QueryGUID -eq '' -or $QueryGUID -eq $null)
			{
				SQLWrite -SQLCommand "insert into $SQLTable(Employee,E_Mail,GUID,Activation_Date,MFA_Activated,SSPR_Activated,MAE_Activated,DaysBeforeActivation) values ('$Employee','$UPN','$GUID','$Activation_Date',0,0,0,'$DaysBeforeActivation')"
			}
			else
			{
				SQLWrite -SQLCommand "update $SQLTable set DaysBeforeActivation = '$DaysBeforeActivation' where GUID = '$GUID'"
			}
		}
	}
}

###############################################################
#		Step 7: Disconnect to Azure Resources.										#
###############################################################

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk.txt

###############################################################
#		Step 8: Find user already in MFA which need SSPR changes.	#
###############################################################

# Connect to Azure Active Directory
$AzureADUserName = Get-Content "c:\powershell\credentials\SRV_SSPR_UserName.txt"
$AzureADPassword = Get-Content "c:\powershell\credentials\SRV_SSPR_Password.txt"| ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($AzureADUserName,$AzureADPassword)
Connect-AzureAD -Credential $credentials|Out-File -Filepath C:\temp\junk.txt

#Get all users in Azure AD
$allUsers = get-azureaduser -All $true

#Get SSPR group members
$ssprGroup = get-azureadgroup -searchstring "Office365_SSPR_Required"
$ssprGroupObjectId = $ssprGroup.objectid

#Create an array of objectID's
$ssprMembers = get-azureadgroupmember -ObjectID $ssprGroupObjectId -All $True
$ssprMembersObjectIdArray = $ssprMembers.ObjectID

#Get noMFA group members
$nomfagroup = get-azureadgroup -searchstring "Office365_NoMFA" | ? {$_.displayname -notlike "*ServiceAccount" -and $_.displayname -notlike "*SharedMailbox"}
$nomfagroupObjectId = $nomfagroup.objectid

#Create an array of objectID's
$nomfaMembers = get-azureadgroupmember -ObjectID $nomfagroupObjectId -All $True
$nomfaMembersObjectIdArray = $nomfaMembers.ObjectId

#Loop through all users
foreach ($user in $allUsers) 
{
	$GUID = $user.objectID
	$extProps = $user | select -expandproperty ExtensionProperty
	$accountType = $extProps.extension_906e14d00db8455cbcdd210acc93d584_extensionAttribute4 

	if ($user.AccountEnabled -eq "True") 
	{
		#Check if user is marked as a human account
		if (($accountType -eq "human") -or ($accountType -like "*|") -or ($accountType -like "*|*")) 
		{
			#If the enabled human user has MFA disabled, remove the user from the SSPR group
			if ($nomfaMembersObjectIdArray -contains $GUID) 
			{
				if ($ssprMembersObjectIdArray -contains $GUID) 
				{
					$Check = $null
					$Check = Get-azureadgroupmember -objectid $ssprGroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
					if($Check -ne '' -and $Check -ne $null) { remove-azureadgroupmember -objectid $ssprGroupObjectId -memberid $GUID }	
				}
			} 
			else 
			{
				#If the enabled human user has MFA enabled and is not a member of the SSPR group, add them to the SSPR group
				if ($ssprMembersObjectIdArray -notcontains $GUID) 
				{
					$Check = $null
					$Check = Get-azureadgroupmember -objectid $ssprGroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
					if($Check -eq '' -or $Check -eq $null) { add-azureadgroupmember -objectid $ssprGroupObjectId -refobjectid $GUID }
				}
			}
		}
	} 
	else 
	{
		#If account is not enabled, remove from SSPR group
		if ($ssprMembersObjectIdArray -contains $GUID) 
		{
			$Check = $null
			$Check = Get-azureadgroupmember -objectid $ssprGroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
			if($Check -ne '' -and $Check -ne $null) { remove-azureadgroupmember -objectid $ssprGroupObjectId -memberid $GUID }	
		}
	}
}

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt