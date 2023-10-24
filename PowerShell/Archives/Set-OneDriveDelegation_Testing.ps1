<#
		Program Name: Set-OneDriveDelegation.ps1
		Date Written: January 27th, 2023
		  Written By: Dave Jaynes
		 Description: Automate Delegated Access to Personal OneDrive Accounts
#>

#################################################
#		Step 1: Define Prerequisite Variables				#
#################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$me = "dave.jaynes@eversana.com"
$secondaryAdmin = "srv_OneDriveRetention@eversana.com"
$from = 'srv_OneDriveRetention@eversana.com'
$fromError = 'AzureAutomation@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$HTMLFile = "C:\temp\HTMLFile.txt"
$UPNArrayList = New-Object -TypeName "System.Collections.ArrayList"
$URLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$TermedEmployeeArrayList = New-Object -TypeName "System.Collections.ArrayList"
$ExpirationURLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "OneDriveDelegation"
$SQLTable = "newonedrivedelegation"
$ProcessRecord = "Yes"
$SQLDump = "c:\PowerShell\OneDriveDelegation\OneDriveDelegation_SQL_Database_Backup.sql"

#################################################
#		Step 2: Define Functions for Script					#
#################################################

function BaseEMailMessage
{
	param(
		[string]$TermedEmployee,
		[string]$Manager,
		[string]$FutureDate,
		[string]$OneDriveURL
	)  

	# Parse out the manager's first name for aesthetics purposes.
	$managerFirstName = $Manager.split(".")[0]
	$niceManagerFirstName = ''
	for($i=0;$i -lt $managerFirstName.length;$i++)
	{
		$x = $managerFirstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceManagerFirstName = $niceManagerFirstName + $x
	}
	
	# Parse out the terminated employee's first and last name for aesthetics purposes.
	$firstName = $TermedEmployee.split("@")[0].split(".")[0]
	$lastName = $TermedEmployee.split("@")[0].split(".")[1]
	$space = ' '
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$niceLastName = ''
	for($i=0;$i -lt $lastName.length;$i++)
	{
		$x = $lastName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceLastName = $niceLastName + $x
	}
	$niceEmployeeName = $niceFirstName + $space + $niceLastName
	
	$HTMLFile = "C:\temp\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	
	$dateFormat = 'dddd, MMMM dd, yyyy'
	$30Days = (Get-Date).AddDays(30)
	Get-Date -Date $30Days -Format $dateFormat
	$FutureDate = Get-Date -Date $30Days -Format $dateFormat
	
	Add-Content -Path "$HTMLFile" -Value "<html>"
	Add-Content -Path "$HTMLFile" -Value "<head>"
	Add-Content -Path "$HTMLFile" -Value "<style>"
	Add-Content -Path "$HTMLFile" -Value "p.NameText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: blue;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 17px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.AlertText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: red;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 17px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.SummaryText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: green;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 20px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "text-decoration: underline;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.DetailText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: black;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 16px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.HeaderText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: Arial, Helvetica, sans-serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: Black;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 30px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: bold;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "</style>"
	Add-Content -Path "$HTMLFile" -Value "</head>"
	Add-Content -Path "$HTMLFile" -Value "<body>"
	Add-Content -Path "$HTMLFile" -Value "<center>"
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</center>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='NameText'>$niceManagerFirstName,</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	if($Manager -eq "robert.muldoon@eversana.com")
	{
		Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='AlertText'>Robert Muldoon, this notification for OneDrive delegation is coming to you because the manager's name could not be found in Azure. We will need to notify the manager manually.</p></td></tr>"
		Add-Content -Path "$HTMLFile" -Value "</table>"
		Add-Content -Path "$HTMLFile" -Value "<br>"
		Add-Content -Path "$HTMLFile" -Value "<table>"
	}
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>The user account belonging to <FONT COLOR=blue SIZE=3><i>$niceEmployeeName</i></FONT> has been disabled. As their manager, you have been delegated read-only access to the contents of their OneDrive folders.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Please back up any of $niceFirstName's important files to your personal space before <FONT COLOR=blue SIZE=3><b>$FutureDate</b></font>, after which time they will be deleted.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>If an account delegated to you is empty, the user most likely did not have any files stored in their OneDrive repository.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "<br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>You will receive an E-Mail reminder in 20 days to copy these files to your personnel space if not already done.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>A link to $niceFirstName's folder is provided below for your convenience.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "<br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='SummaryText'>OneDrive Details</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Disabled User: $TermedEmployee</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Manager: $Manager</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>OneDrive Files URL: <a href='$oneDriveURL'>Click Here</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
}

function AdditionsEMailMessage {
	Param (
		[System.Collections.ArrayList]$UPN,
		[System.Collections.ArrayList]$URL,
		[datetime]$dateFuture
	)
	$HTMLFile = "C:\temp\HTMLFile.txt"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>As the disabled user was a manager, they were recently delegated access to the following accounts which have now been delegated to you.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Please also make sure to back up any important files from any accounts below to your personal OneDrive within the next 30 days by <b>$dateFuture UTC</b>. These files will not be held for you indefinitely.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>As the disabled user was a manager, they were recently delegated access to the following accounts which have now been delegated to you.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"	
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Here are the delegates whom we are sharing the OneDrive files to you.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Click on the former employees name below to pull up their One-Drive files.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"	
	$NumRecs = $UPN.Count
	for($i=0;$i -lt $NumRecs;$i++)
	{
		$delegateName = $UPN[$i]
		$accountOneDriveURL = $URL[$i]
		Add-Content -Path "$HTMLFile" -Value "<a href='$accountOneDriveURL'>$delegateName</a></p></td></tr>"
	}
	Add-Content -Path "$HTMLFile" -Value "</table>"
}

function ErrorEMailMessage {
	Param (
		[string]$TermedEmployee,
		[string]$Manager,
		[string]$OneDriveURL
	)
	$HTMLFile = "C:\temp\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	Add-Content -Path "$HTMLFile" -Value "<html>"
	Add-Content -Path "$HTMLFile" -Value "<head>"
	Add-Content -Path "$HTMLFile" -Value "<style>"
	Add-Content -Path "$HTMLFile" -Value "p.NameText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: blue;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 17px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.DetailText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: black;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 16px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: normal;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "p.HeaderText {"
	Add-Content -Path "$HTMLFile" -Value "  font-family: Arial, Helvetica, sans-serif;"
	Add-Content -Path "$HTMLFile" -Value "        color: Black;"
	Add-Content -Path "$HTMLFile" -Value "    font-size: 30px;"
	Add-Content -Path "$HTMLFile" -Value "   font-style: normal;"
	Add-Content -Path "$HTMLFile" -Value "  font-weight: bold;"
	Add-Content -Path "$HTMLFile" -Value "}"
	Add-Content -Path "$HTMLFile" -Value "</style>"
	Add-Content -Path "$HTMLFile" -Value "</head>"
	Add-Content -Path "$HTMLFile" -Value "<body>"
	Add-Content -Path "$HTMLFile" -Value "<center>"
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</center>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='NameText'>An error has been experienced delegating the OneDrive belonging to <a href='$oneDriveURL'>$ownerUpper</a>. Please investigate and respond accordingly.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>OneDrive Details</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Disabled User: $ownerUpper</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Manager: $managerUPN </p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>OneDrive Files URL: <a href='$oneDriveURL'>Click Here</a></p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</body>"
	Add-Content -Path "$HTMLFile" -Value "</html>"
}

function ReminderEMailMessage {
	Param (
		[System.Collections.ArrayList]$TermedEmployeeArrayList,
		[System.Collections.ArrayList]$ExpirationURLArrayList,
		[string]$Manager,
		[datetime]$ReminderExpirationDate
	)
	$firstName = $Manager.split(".")[0]
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$HTMLFile = "C:\temp\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='NameText'>$niceFirstName,</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>As a reminder, you were delegated read-only access to the contents of the following OneDrive account(s) for which access may be lost in ten days at <b>$ReminderExpirationDate UTC</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Please copy all important files to another location. If an account delegated to you is empty, the user did not have any files in their OneDrive account.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>The list of names are provided below:</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"	
	$NumRecs = $TermedEmployeeArrayList.Count
	for($i=0;$i -lt $NumRecs;$i++)
	{
		$TermedEmployee = $TermedEmployeeArrayList[$i]
		$ExpirationURL = $ExpirationURLArrayList[$i]
		Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='NameText'><a href='$ExpirationURL'>$TermedEmployee</a></p></td></tr>"
	}
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</body>"
	Add-Content -Path "$HTMLFile" -Value "</html>"
}
								
function GeneralErrorEMailMessage {
	Param (
		[string]$Manager,
		[datetime]$ReminderExpirationDate,
		[string]$ReminderList
	)
	$firstName = $Manager.split(".")[0]
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$HTMLFile = "C:\temp\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='NameText'>An error has been experienced sending a reminder about delegated OneDrive expiration to $remindManager. Please investigate and respond accordingly.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Delegation Reminder Details</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Manager: $Manager</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Delegation Expiration: $ReminderExpirationDate</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Reminder List: $ReminderList</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</body>"
	Add-Content -Path "$HTMLFile" -Value "</html>"
}

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

function SQLOneQueryCommand    
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
#################################################
#		Step 3: Connect to Azure Resources					#
#################################################

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

# Set credentials for AzureAutomation to authorize the sending of error email messages
$AzureAutomationUserName = Get-Content "C:\PowerShell\credentials\AzureAutomationUserName.txt"
$AzureAutomationPassword = Get-Content "C:\PowerShell\credentials\AzureAutomationPassword.txt" | ConvertTo-SecureString
$credentialsError = New-Object System.Management.Automation.PSCredential($AzureAutomationUserName,$AzureAutomationPassword)

#Connect to SharePoint Admin
$TenantURL = 'https://eversana-admin.sharepoint.com/'
Connect-SPOService -url $TenantURL -Credential $credentials|Out-File -Filepath C:\temp\junk.txt

#################################################
#		Step 4: Create SQL tables if non existant		#
#################################################

#SQLWrite -SQLCommand "create table if not exists $Table(Owner varchar(70),Manager bool,URL varchar(255),DelegatedTo varchar(255),DelegatedOn datetime,DelegatedURL varchar(255),DelegationExpires datetime,TargetFolder varchar(100),Valid bool,ReminderModify bool,ReminderSentOn datetime)"

#################################################
#		Step 5: Initiate Storage Table Connections	#
#################################################

# Identify Storage Group, Account Name and Primary Key settings
$resourceGroupName = "esa-prod-auto-rg"
$storageAccountName = "prodautostorage"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$partitionKey = "OneDriveAccount"

# Create the One-Drive Delegation Main Table connection variables
$tableName = "OneDriveDelegation"
$table = (Get-AzStorageTable -Context $storageAccount.context -Name $tableName).CloudTable

#################################################
#		Step 6: Pull previously processed delegates	#
#################################################

# Get all previously delegated OneDrive entries from the main table
$delegatesPast = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true'"
$delegatesPastOwners = $delegatesPast.Owner

#################################################
#		Step 7: Get all personal OneDrive sites			#
#################################################

$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'"

#################################################
#		Step 8: Get all current disabled users			#
#################################################

$disabledUsers = get-azureaduser -All $true -filter "AccountEnabled eq false"
$disabledUsers.Count
#################################################
#		Step 9: Create list of eligable delegates		#
#################################################

<#
Compile an listing within the array '$delegates' of those employees in AD who meet this criteria:
1. Marked as disabled is AD.
2. The One-Drive URL field is populated.
3. The delegate object is populated with an employee record.
#>

[String[]]$delegatesPastOwners = SQLOneQueryCommand -SQLCommand "select Owner from $SQLTable"
$delegates = @()
foreach ($disabledUser in $disabledUsers)
{
	$disabledUserUPN = $disabledUser.UserPrincipalName
	$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $disabledUserUPN})
	$delegateURL = $delegate.Url
	# Here is where we look into the 'OneDriveDelegation' SQL Table to see if the delegate has already been processed.
	if ($delegatesPastOwners -notcontains $disabledUserUPN)
	{
		if (($delegateURL -ne $null) -and ($($delegate.count) -eq 1))
		{
			Write-Host "Processing delegate [$disabledUserUPN]"
			$delegates += $delegate
		}
	}

}
exit

#################################################
#		Now that the preliminaries tasks have been	#
#		completed, we will commence with walking 		#
#		through each disabled delegate record and 	#
#		check to see if it has previously been 			#
#		processed by this script. Remember, all			#
#		employee records are kept in AD regardless	#
#		if they are active or prior employees. This	#
#		is done for legal purposes. We only want to	#
#		process those inactive records which have		#
#		not been registered in 'OneDriveDelegation'	#
#		storage table as this table contains entrees#
#		of previously processed delegates. Without	#
#		the 'OneDriveDelegation' table, all inactive#
#		employees would be processed over and over	#
#		each night and managers would scream about	#
#		a plethora of repeated delegation e-mails.	#
#################################################

#################################################
#		Step 10: Process eligable delegates					#
#################################################

foreach ($delegate in $delegates)
{
	Try
	{
		$targetFolder = ''
		$URL = ''
		$URL = $delegate.Url
		$owner = ''
		$owner = $delegate.Owner
		$ownerUpper = $owner.ToUpper()
		$ownerAzureAD = Get-AzureADUser -filter "UserPrincipalName eq `'$owner`'"
		$ownerDirectReports = (Get-AzureADUserDirectReport -ObjectID $($ownerAzureAD.ObjectID)).count

		# Get Manager Details
		$manager = Get-AzureADUserManager -ObjectID $((Get-AzureADUser -filter "userPrincipalName eq `'$owner`'").ObjectID)
		$managerUPN = $manager.UserPrincipalName
		$managerEnabled = $manager.AccountEnabled
		
		# Give Robert Read-Only access if no manager is listed.
		if($managerUPN -eq '' -or $managerUPN -eq $null) 
		{
			$managerUPN = SQLQueryCommand -SQLCommand "select manager from findmanager where owner = '$owner'"
		}	
		if($managerUPN -eq '' -or $managerUPN -eq $null) 
		{ 
			$managerUPN = 'robert.muldoon@eversana.com' 
			$ProcessRecord = "No"
		}
		Write-Host
		Write-Host "#####################################################################"
		Write-Host "#                                                                   #"
		Write-Host "#  owner = [$owner], managerUPN = [$managerUPN]              #"
		Write-Host "#                                                                   #"
		Write-Host "#####################################################################"
		Write-Host
		# We need to service account 'srv_OneDriveRetention@eversana.com' as a Site Collection Admin for this account
		# so it has the rights to scan, read and copy files from the ex-delegates folder to the managers folders.
		if($ProcessRecord -eq "Yes")
		{
			Set-SPOUser -site $URL -LoginName $secondaryAdmin -IsSiteCollectionAdmin $True
		}

		#Connect to SharePoint Site Directly
		Connect-PnPOnline -Url $URL -Credentials $credentials|Out-File -Filepath C:\temp\junk.txt

		#Get folders only in root Documents directory
		$web = Get-PnPWeb
		$relativeUrl = $web.ServerRelativeUrl + "/Documents/"
		$foldersDraft = ((Get-PnPListItem -List Documents -Fields ID,Title,GUID).FieldValues | Where-Object {($_.FileRef -notlike "$relativeUrl*.*") -and ($_.FileRef -notlike "$relativeUrl*/*")}).FileRef
 
		$folders = @()
		foreach ($folderDraft in $foldersDraft)
		{
			$start = ($relativeUrl.Length) - 10
			$end = ($folderDraft.length) - $start
			$substring = $folderDraft.Substring($start,$end)
			$folders += $substring
		}

		$termName = $(($($owner.split("@"))[0]).ToUpper())
		$termDate = Get-Date -Format yyyMMdd
		$folderName = "TERM-"+$termDate+"-"+$termName
		$targetFolder = "Documents/"+$folderName
		
		if($ProcessRecord -eq "Yes")
		{
			#$folderAdd = Add-PNPFolder -Name $folderName -Folder Documents
			foreach ($folder in $folders)
			{
				#$folderMove = Move-PnpFolder -Folder $folder -TargetFolder $targetFolder
			}
		}

		# Get remaining files to move into new folder
		$filesAll = (Get-PnPListItem -List Documents -Fields ID,Title,GUID).FieldValues
		$files = $filesAll | Where-Object {$_.FileRef -notlike "*$folderName*"}

		foreach ($file in $files)
		{
			$sourceFile = $file.FileRef
			$filepathIndex = $($sourceFile.indexOf("Documents/")) + 10
			$filepathExtract = $sourceFile.Substring(0,$filepathIndex)
			$targetFile = $filepathExtract+$folderName+"/"+$file.FileLeafRef
			if($ProcessRecord -eq "Yes")
			{			
				#$fileMove = Move-PnpFile -ServerRelativeUrl $sourceFile -TargetURL $targetFile -Force
			}
		}

		# Build the shared OneDrive URL
		$baseUrl = $web.Url
		$urlID = $relativeUrl + $folderName
		$urlID = [System.Web.HTTPUtility]::UrlEncode($urlID)
		$urlID = $urlID.Replace("_","%5F")
		$urlID = $urlID.Replace(".","%2E")
		$urlID = $urlID.Replace("-","%2D")
		$oneDriveURL = $baseUrl + "/_layouts/15/onedrive.aspx?id=" + $urlID

		# Generate email content
		$dateFuture = ((Get-Date).AddDays(30)).ToUniversalTime()
		$subject = "OneDrive Files for Terminated User: " + $ownerUpper
		
		# Build the Base HTML file to be sent out in the E-Mail
		BaseEMailMessage -TermedEmployee $termName -Manager $managerUPN -FutureDate $dateFuture -OneDriveURL $oneDriveURL
		$body = Get-Content $HTMLFile -Raw
		# Send email notifications or take additional action if the termed user was delegated access to other users' OneDrives which hasn't expired
		if (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -eq 0))
		{
			###############################################################
			#		In this decision branch, the delegate was a manager.			#
			#		There were no terminated delegates with non-expired files	#
			#		reporting to this manager at time of termination.					#
			###############################################################
			
			Add-Content -Path "$HTMLFile" -Value "</body>"
			Add-Content -Path "$HTMLFile" -Value "</html>"
			$body = Get-Content $HTMLFile -Raw
			# Give read-only permission to the manager
			if($ProcessRecord -eq "Yes")
			{
				#Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
			}
			# Notify manager with an email containing the termed user's OneDrive folder
			$recipients = "$managerUPN,$me"
			[string[]]$to = $recipients.Split(',')
			Send-MailMessage `
				-From $from `
				-To $me `
				-Subject $subject `
				-Body $body `
				-BodyAsHtml `
				-UseSsl `
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-credential $credentials
			# Add record to the table
			if($ProcessRecord -eq "Yes")
			{
				#Add-AzTableRow -table $table -PartitionKey $partitionKey -rowKey $((New-Guid).Guid) -property @{'Owner'= $owner;'URL'=$URL;'DelegatedTo'=$managerUPN;'DelegatedOn'=$(Get-Date);'DelegatedURL'=$oneDriveURL;'DelegationExpires'=$dateFuture;'TargetFolder'=$targetFolder;'Valid'='true';}
			}
			$dateFormat = 'yyyy-MM-dd'
			$Today = (Get-Date).AddDays(0)
			$Thirty = (Get-Date).AddDays(30)
			$TempDate = Get-Date -Date $Today -Format $dateFormat
			$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
			[string]$SQLDate = $TempDate.ToString()
			[string]$SQL30Date = $Temp30Date.ToString()
			if($managerEnabled -eq 'True' -or $managerEnabled -eq 'true') { $Mgmt = 1 } else { $Mgmt = 0 } 
			if($ProcessRecord -eq "Yes")
			{
				$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from onedrivedelegation where Owner = '$owner' limit 1"
				if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
				{
					#SQLWrite -SQLCommand "insert into $Table(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
				}
			}
		}
		elseif (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -gt 0))
		{
			###############################################################
			#		In this decision branch, the delegate was a manager.			#
			#		There were terminated delegates with non-expired files		#
			#		reporting to this manager who quit (or was terminated)		#
			#		so we need to loop through and re-assign those files to		#
			#		this terminated manager's manager. (Director most likely)	#
			###############################################################
			
			# Give read-only permission to the manager
			if($ProcessRecord -eq "Yes")
			{
				#Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
			}
			# Check records for delegated access belonging to owner less than 30 days old
			$accounts = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true'" | Where-Object {$_.DelegatedTo -eq $owner}
			if ($($accounts.count) -gt 0)
			{
				$bodyAdd = ''
				$accountCounter=0
				$TotalAccounts = $accounts.count
				$UPNArrayList.Clear
				$URLArrayList.Clear
				foreach ($account in $accounts)
				{
					# Disconnect
					Disconnect-PnPOnline
					# Reshare existing delegated OneDrives with manager's manager if access has not expired
					$bodyAddInsert = ''
					$accountDelegationExpires = ''
					$accountDelegationExpires = $account.DelegationExpires
					if ([datetime]$accountDelegationExpires -gt $((Get-Date).ToUniversalTime()))
					{
						$accountGUID = ''
						$accountGUID = $account.RowKey
						$accountManagerUPN = ''
						$accountManagerUPN = $account.DelegatedTo
						$accountOneDriveURL = ''
						$accountOneDriveURL = $account.DelegatedURL
						$accountOwner = ''
						$accountOwner = $account.Owner
						$accountTargetFolder = ''
						$accountTargetFolder = $account.TargetFolder
						$accountURL = ''
						$accountURL = $account.URL
						$Junk = $UPNArrayList.Add($accountManagerUPN)
						$Junk = $URLArrayList.Add($accountOneDriveURL)
						
						# Append to the Base HTML file with the additional delegates.
						AdditionsEMailMessage -UPN $UPNArrayList -URL $URLArrayList -dateFuture $dateFuture
						
						Connect-PnPOnline -Url $accountURL -Credentials $credentials
						# Re-delegate access to new manager
						if($ProcessRecord -eq "Yes")
						{
							#Set-PnPFolderPermission -List 'Documents' -Identity $accountTargetFolder -User $managerUPN -AddRole 'Read'
							# Update records to indicate the new expiration date for delegated access to the OneDrive
							$accountModify = Get-AzTableRow -table $table -CustomFilter "RowKey eq `'$accountGUID`'"
							$accountModify.DelegationExpires = $dateFuture
							$accountModify.DelegatedTo = $managerUPN
							$accountModify | Update-AzTableRow -table $table
						}
					}
				}
				# Notify manager with the extended email containing the termed user's OneDrive folder and any unexpired OneDrive accounts for which the user received delegated access
				Add-Content -Path "$HTMLFile" -Value "</body>"
				Add-Content -Path "$HTMLFile" -Value "</html>"
				$bodyManager = Get-Content $HTMLFile -Raw
				$recipients = "$managerUPN,$me"
				[string[]]$to = $recipients.Split(',')
				Send-MailMessage `
					-From $from `
					-To $me `
					-Subject $subject `
					-Body $bodyManager `
					-BodyAsHtml `
					-UseSsl `
					-SmtpServer $SmtpServer `
					-Port $SmtpPort `
					-credential $credentials      
			}
			else
			{
				if($ProcessRecord -eq "Yes")
				{
					#Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
				}
				# Notify manager with an email containing the termed user's OneDrive folder
				Add-Content -Path "$HTMLFile" -Value "</body>"
				Add-Content -Path "$HTMLFile" -Value "</html>"
				$body = Get-Content $HTMLFile -Raw
				$recipients = "$managerUPN,$me"
				[string[]]$to = $recipients.Split(',')
				Send-MailMessage `
					-From $from `
					-To $me `
					-Subject $subject `
					-Body $body `
					-BodyAsHtml `
					-UseSsl `
					-SmtpServer $SmtpServer `
					-Port $SmtpPort `
					-credential $credentials
				# Add record to the table
				if($ProcessRecord -eq "Yes")
				{
					#Add-AzTableRow -table $table -PartitionKey $partitionKey -rowKey $((New-Guid).Guid) -property @{'Owner'= $owner;'URL'=$URL;'DelegatedTo'=$managerUPN;'DelegatedOn'=$(Get-Date);'DelegatedURL'=$oneDriveURL;'DelegationExpires'=$dateFuture;'TargetFolder'=$targetFolder;'Valid'='true';}
				}
				$dateFormat = 'yyyy-MM-dd'
				$Today = (Get-Date).AddDays(0)
				$Thirty = (Get-Date).AddDays(30)
				$TempDate = Get-Date -Date $Today -Format $dateFormat
				$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
				[string]$SQLDate = $TempDate.ToString()
				[string]$SQL30Date = $Temp30Date.ToString()
				if($managerEnabled -eq 'True' -or $managerEnabled -eq 'true') { $Mgmt = 1 } else { $Mgmt = 0 } 
				if($ProcessRecord -eq "Yes")
				{
					$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from onedrivedelegation where Owner = '$owner' limit 1"
					if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
					{
						#SQLWrite -SQLCommand "insert into $Table(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
					}
				}
			}
		}
		else
		{
			###############################################################
			#		In this decision branch, this is a non-manager delegate.	#
			#		This decision branch will most certainly be used most.		#
			###############################################################

			Add-Content -Path "$HTMLFile" -Value "</body>"
			Add-Content -Path "$HTMLFile" -Value "</html>"
			$body = Get-Content $HTMLFile -Raw
			$recipients = "$managerUPN,$me"
			[string[]]$to = $recipients.Split(',')
			Send-MailMessage `
				-From $from `
				-To $me `
				-Subject $subject `
				-Body $body `
				-BodyAsHtml `
				-UseSsl `
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-credential $credentials
				
			# Add record to the table
			#$managerUPN = 'dave.jaynes@eversana.com'
			if($ProcessRecord -eq "Yes")
			{
				#Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
				#Add-AzTableRow -table $table -PartitionKey $partitionKey -rowKey $((New-Guid).Guid) -property @{'Owner'= $owner;'URL'=$URL;'DelegatedTo'='nobody';'DelegatedOn'=$(Get-Date);'DelegatedURL'=$oneDriveURL;'DelegationExpires'=$dateFuture;'TargetFolder'=$targetFolder;'Valid'='true';}
			}
			
			# Write record to SQL
			$dateFormat = 'yyyy-MM-dd'
			$Today = (Get-Date).AddDays(0)
			$Thirty = (Get-Date).AddDays(30)
			$TempDate = Get-Date -Date $Today -Format $dateFormat
			$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
			[string]$SQLDate = $TempDate.ToString()
			[string]$SQL30Date = $Temp30Date.ToString()
			if($managerEnabled -eq 'True' -or $managerEnabled -eq 'true') { $Mgmt = 1 } else { $Mgmt = 0 }
			if($ProcessRecord -eq "Yes")
			{
				$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from onedrivedelegation where Owner = '$owner' limit 1"
				if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
				{
					#SQLWrite -SQLCommand "insert into $Table(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
				}
			}
		}
		# Disconnect
		Disconnect-PnPOnline
	}
	Catch
	{
		Write-Output "Ran into an issue: $($PSItem.ToString())"
		$PSItem.InvocationInfo | Format-List *
		# Notify support with an email containing the user for which delegation triggered an error
		$fromError = "AzureAutomation@eversana.com"
		$recipients = "dave.jaynes@eversana.com"
		[string[]]$to = $recipients.Split(',')
		$subject = "Error Experienced Delegating OneDrive for Terminated User: " + $ownerUpper
		
		# Build the Error HTML file to be sent out with the E-Mail.
		ErrorEMailMessage -TermedEmployee $ownerUpper -Manager $managerUPN -OneDriveURL $oneDriveURL
		
		$body = Get-Content $HTMLFile -Raw
		Send-MailMessage `
			-From $fromError `
			-To $me `
			-Subject $subject `
			-Body $body `
			-BodyAsHtml `
			-UseSsl `
			-SmtpServer $SmtpServer `
			-Port $SmtpPort `
			-credential $credentialsError

		# Disconnect
		Disconnect-PnPOnline
	}
}

#################################################
#		Step 11: Send out Manager reminder E-Mails	#
#################################################

$today = Get-Date
# Get OneDrive Accounts that Are Ten Days Prior to Expiration and Delegated to an Actual Person
$remindersAll = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true'" | Where-Object {($(([datetime]$_.DelegationExpires).Date.AddDays(-10)) -eq $($today.Date)) -and ($_.DelegatedTo -ne "nobody")}

$remindManagers = $remindersAll.DelegatedTo | Select-Object -Unique $_

$TermedEmployeeArrayList.Clear
$ExpirationURLArrayList.Clear
foreach ($remindManager in $remindManagers)
{
	Try
	{
		$reminders = $remindersAll | Where-Object {$_.DelegatedTo -eq $remindManager}
		$reminderList = @()
		foreach ($reminder in $reminders)
		{
			$reminderGUID = ''
			$reminderGUID = $reminder.RowKey
			$reminderManagerUPN = ''
			$reminderManagerUPN = $reminder.DelegatedTo
			$reminderOneDriveURL = ''
			$reminderOneDriveURL = $reminder.DelegatedURL
			$reminderExpiration = ''
			$reminderExpiration = $reminder.DelegationExpires
			$reminderOwner = ''
			$reminderOwner = $reminder.Owner
			$reminderOwnerUpper = $reminderOwner.ToUpper()
			$TermedEmployeeArrayList.Add($reminderOwnerUpper)
			$ExpirationURLArrayList.Add($reminderExpiration)
			# Update records to indicate the new expiration date for delegated access to the OneDrive
			$reminderModify = ''
			$reminderModify = Get-AzTableRow -table $table -CustomFilter "RowKey eq `'$reminderGUID`'"
			if($ProcessRecord -eq "Yes")
			{
				#Add-Member -InputObject $reminderModify -NotePropertyName 'ReminderSentOn' -NotePropertyValue $today -Force
				$reminderModify | Update-AzTableRow -table $table
			}
		}
		$reminderSubject = "Reminder: Delegated Access to OneDrive Files for Terminated User(s) Ending on "+$((($reminderExpiration.Date).ToString().Split(" "))[0])
		ReminderEMailMessage -TermedEmployeeArrayList $TermedEmployeeArrayList -ExpirationURLArrayList $ExpirationURLArrayList -Manager $reminderManagerUPN -ReminderExpirationDate $reminderExpiration
		$recipients = "$remindManager,$me"
		[string[]]$to = $recipients.Split(',')
		$reminderBody = Get-Content $HTMLFile -Raw
		Send-MailMessage `
			-From $from `
			-To $me `
			-Subject $reminderSubject `
			-Body $reminderBody `
			-BodyAsHtml `
			-UseSsl `
			-SmtpServer $SmtpServer `
			-Port $SmtpPort `
			-credential $credentials
	}
	Catch
	{
		# Notify support with an email containing the user for which delegation triggered an error
		$fromError = "AzureAutomation@eversana.com"
		$recipients = "dave.jaynes@eversana.com"
		[string[]]$to = $recipients.Split(',')
		$subject = "Error Experienced Sending OneDrive Delegation Reminder to: " + $remindManager
		GeneralErrorEMailMessage -Manager $remindManager -ReminderExpirationDate $reminderExpiration -ReminderList $reminderList
		$body = Get-Content $HTMLFile -Raw

		Send-MailMessage `
			-From $fromError `
			-To $me `
			-Subject $subject `
			-Body $body `
			-BodyAsHtml `
			-UseSsl `
			-SmtpServer $SmtpServer `
			-Port $SmtpPort `
			-credential $credentialsError
	}
}

#################################################
#		Step 12: Disconnect from Azure services			#
#################################################

Disconnect-AzureAD
Disconnect-SPOService
Disconnect-AzAccount

& "c:\program files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" --user=$SQLUserName --password=$SQLUserPassword onedrivedelegation  > $SQLDump

# To Restore database, issue this command at the Windows command prompt:
# "c:\program files\MySQL\MySQL Server 8.0\bin\mysql.exe" --user=$SQLUserName --password=$SQLUserPassword onedrivedelegation < $SQLDump