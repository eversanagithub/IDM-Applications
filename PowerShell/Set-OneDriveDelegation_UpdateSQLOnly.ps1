<#
		Program Name: Set-OneDriveDelegation.ps1
		Date Written: January 27th, 2023
		  Written By: Dave Jaynes
		 Description: Automate Delegated Access to Personal OneDrive Accounts
#>

#################################################
#    Step 1: Define Prerequisite Variables      #
#################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[String]$LogFileDate = Get-Date -Format 'yyyyMMdd'
$me = "dave.jaynes@eversana.com"
$secondaryAdmin = "srv_OneDriveRetention@eversana.com"
$from = 'srv_OneDriveRetention@eversana.com'
$fromError = 'AzureAutomation@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$HTMLFile = "C:\temp\HTMLFile.txt"
$RunningLogFile = "C:\UtilityScripts\Logs\OneDriveDelegationLogfile_$LogFileDate.txt"
$UPNArrayList = New-Object -TypeName "System.Collections.ArrayList"
$URLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$TermedEmployeeArrayList = New-Object -TypeName "System.Collections.ArrayList"
$ExpirationURLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "EmployeeTransitions"
$SQLTable = "delegates_already_processed"
$DAP = "WebDelegatesAlreadyProcessed"
$EncryptionSQLDatabase = "encryptedpasswords"
$EncryptionSQLTable = "encryptedpasswords"
$UnauthorizedList = "UnauthorizedList"
$Script = "Set-OneDriveDelegation.ps1"
$ProcessRecord = "Yes"
$HTMLFile = "C:\temp\HTMLFile.txt"
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	
#################################################
#    Step 4: Create SQL connectivity functions  #
#################################################

# Set up the SQL Encryption Read function
function SQLReadEncryption   
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\Connector NET 8.0\Assemblies\v4.5.2\\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$EncryptionSQLDatabase;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$SQLReturnValue = while($myreader.Read()){ $myreader.GetString($field) }
	$myconnection.Close()
	$SQLReturnValue
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

function SQLQueryCommand    
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

function WriteToMSSQLProd
{
	param(
		[string]$MSSQLCommand
	)
	$connStr = @"
	DSN=ProdDBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $MSSQLCommand, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function WriteToMSSQLDev
{
	param(
		[string]$MSSQLCommand
	)
	$connStr = @"
	DSN=DevDBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $MSSQLCommand, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

# Report unauthorized user trying to run this script.
function NotAuthorized    
{
	param(
		[string]$currentUser,
		[string]$Script
	) 
	$DTG = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Host "currentUser = [$currentUser], Script = [$Script], DTG = [$DTG]"
	SQLReadEncryption -SQLCommand "insert into $UnauthorizedList(CurrentUser,Script,DTG) values ('$currentUser','$Script','$DTG')"
}

###############################################################
#    Step 5: Pull credentials based on user running script.   #
###############################################################

# Pull the correct encrypted credentials based on the user running this script.
$currentUser = $env:UserName

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\PowerShell\credentials\PowerBIUserName.txt"
$EncryptedPasswordFile1 = $null
$EncryptedPasswordFile1 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName1'"
if($EncryptedPasswordFile1 -eq '' -or $EncryptedPasswordFile1 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword1 = Get-Content $EncryptedPasswordFile1 | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

# Create the credentials for AzureAD
$serviceAccountUserName2 = Get-Content "C:\PowerShell\credentials\OneDriveRetentionUserName.txt"
$EncryptedPasswordFile2 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName2'"
if($EncryptedPasswordFile2 -eq '' -or $EncryptedPasswordFile2 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword2 = Get-Content $EncryptedPasswordFile2 | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Set credentials for AzureAutomation to authorize the sending of error email messages.
$serviceAccountUserName3 = Get-Content "C:\PowerShell\credentials\AzureAutomationUserName.txt"
$EncryptedPasswordFile3 = $null
$EncryptedPasswordFile3 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName3'"
if($EncryptedPasswordFile3 -eq '' -or $EncryptedPasswordFile3 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword3 = Get-Content $EncryptedPasswordFile3 | ConvertTo-SecureString
$credentialsError = New-Object System.Management.Automation.PSCredential($serviceAccountUserName3,$serviceAccountPassword3)


#################################################
#    Step 6: Connect to Azure Resources         #
#################################################

# Connect to AzAccount for access to Storage Tables
Connect-AzAccount -Credential $credential1|Out-File -Filepath C:\temp\junk.txt

# Connect to Azure Active Directory
Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\temp\junk.txt

#Connect to SharePoint Admin
$TenantURL = 'https://eversana-admin.sharepoint.com/'
Connect-SPOService -url $TenantURL -Credential $credential2|Out-File -Filepath C:\temp\junk.txt

#################################################
#    Step 7: Create SQL tables if non existant  #
#################################################

SQLWrite -SQLCommand "create table if not exists $SQLTable(Owner varchar(70),Manager bool,URL varchar(255),DelegatedTo varchar(255),DelegatedOn datetime,DelegatedURL varchar(255),DelegationExpires datetime,TargetFolder varchar(100),Valid bool,ReminderModify bool,ReminderSentOn datetime)"

#################################################
#    Step 8: Create list of eligable delegates #
#################################################

<#
Compile an listing within the array '$delegates' of those employees in AD who meet this criteria:
1. Marked as disabled is AD.
2. The One-Drive URL field is populated.
3. The delegate object is populated with an employee record.
#>

$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'"
$delegates = @()
$connStr = @"
DSN=ProdDBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select --r.RequestGUID, r.TBL,r.EversanaID,r.TargetID,r.action, r.status,r.ProcessedDate,coalesce(f.extensionattribute10, f2.extensionattribute10) EA10, 
    coalesce(ahsr.fieldvalue, sr.FieldValue) UserName, coalesce(f.userprincipalname, f2.userprincipalname) UPN
    ,coalesce(fm.userprincipalname, fm2.userprincipalname) ManagerUPN
    from Request_VW r 
    left join ADHoc_SubRequest ahsr on (ahsr.RequestGUID = r.RequestGUID and ahsr.FieldName = 'Username')
    left join SubRequest sr on (sr.RequestGUID = r.RequestGUID and sr.FieldName = 'Username')
    left join IdentityMap i on (i.Username = ahsr.FieldValue and i.TargetID = r.TargetID)
    left join IdentityMap i2 on (i.Username = sr.FieldValue and i.TargetID = r.TargetID)
    left join Feed_AD_Universal f on (f.sAMAccountName = ahsr.FieldValue)
    left join Feed_AD_Universal f2 on (f2.sAMAccountName = sr.FieldValue)
    left join Feed_AD_Universal fm on (f.extensionAttribute10 = fm.EmployeeNumber)
    left join Feed_AD_Universal fm2 on (f2.extensionAttribute10 = fm2.EmployeeNumber)
    where r.ProcessedDate > convert(varchar, getdate()-1,112)
    and r.ProcessedDate < convert(varchar, getdate(),112)
    and r.targetid = 'ad_universal'
    and status = 'completed'
    and r.action = 'DIS'
    and i.Username is null and i2.username is null"
$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
$rdr = $cmd.ExecuteReader()

# Here is where we loop through the folks terminated yesterday.
while ($rdr.Read())
{
	$disabledUserUPN = $rdr["UPN"]
	$ManagerUPN = $rdr["ManagerUPN"]
	$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $disabledUserUPN})
	if($delegate -ne '' -and $delegate -ne $null)
	{
		try
		{
			$targetFolder = ''
			$URL = ''
			$URL = $delegate.Url
			$owner = ''
			$owner = $delegate.Owner
			$ownerUpper = $owner.ToUpper()
			$ownerAzureAD = Get-AzureADUser -filter "UserPrincipalName eq `'$owner`'"
			$ownerDirectReports = (Get-AzureADUserDirectReport -ObjectID $($ownerAzureAD.ObjectID)).count	
			Write-Host "$owner has $ownerDirectReports direct reports."
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
				#$ProcessRecord = "No"
			}

			#Connect to SharePoint Site Directly

			Connect-PnPOnline -Url $URL -Credentials $credential2|Out-File -Filepath C:\temp\junk.txt

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

			# Get remaining files to move into new folder
			$filesAll = (Get-PnPListItem -List Documents -Fields ID,Title,GUID).FieldValues
			$files = $filesAll | Where-Object {$_.FileRef -notlike "*$folderName*"}

			foreach ($file in $files)
			{
				$sourceFile = $file.FileRef
				$filepathIndex = $($sourceFile.indexOf("Documents/")) + 10
				$filepathExtract = $sourceFile.Substring(0,$filepathIndex)
				$targetFile = $filepathExtract+$folderName+"/"+$file.FileLeafRef
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

			if (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -eq 0))
			{
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
					$AlreadyInSQL = $null
					$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from $SQLTable where Owner = '$owner' limit 1"
					if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
					{
						#SQLWrite -SQLCommand "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						
						#WriteToMSSQLProd -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						
						#WriteToMSSQLDev -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
					}
				}
			}
			elseif (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -gt 0))
			{
				$accounts = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true'" | Where-Object {$_.DelegatedTo -eq $owner}
				if ($($accounts.count) -gt 0)
				{
					$bodyAdd = ''
				}
				else
				{
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
						$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from $SQLTable where Owner = '$owner' limit 1"
						if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
						{
							#SQLWrite -SQLCommand "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
							Write-Host "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
							
							#WriteToMSSQLProd -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
							Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
							
							#WriteToMSSQLDev -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
							Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
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
					$AlreadyInSQL = SQLQueryCommand -SQLCommand "select Owner from $SQLTable where Owner = '$owner' limit 1"
					if($AlreadyInSQL -eq '' -or $AlreadyInSQL -eq $null)
					{
						#SQLWrite -SQLCommand "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $SQLTable(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
					
						#WriteToMSSQLProd -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						
						#WriteToMSSQLDev -MSSQLCommand "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
						Write-Host "insert into $DAP(Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn) values ('$owner',$Mgmt,'$URL','$managerUPN','$SQLDate','$oneDriveURL','$SQL30Date','$targetFolder',1,0,'$SQLDate')"
					}
				}
			}
		}
		Catch
		{
			$aa = 0
		}
	}
}
$rdr.Close()
$con.Close()

#################################################
#    Step 10: Disconnect from Azure services    #
#################################################

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt
Disconnect-SPOService|Out-File -Filepath C:\temp\junk.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk.txt

