<#
		Program Name: Set-OneDriveDelegation.ps1
		Date Written: January 27th, 2023
		  Written By: Dave Jaynes
		 Description: Automate Delegated Access to Personal OneDrive Accounts
		 
		 There are eight steps in this script, those being:
		 
		 1. Define Prerequisite Variables.
		 2. Write Daily Report Headings to the HTML file.
		 3. Create HTML E-Mail file entries.
		 4. Create SQL connectivity functions.
		 5. Pull Azure and SharePoint credentials based on user running script.
		 6. Connect to Azure Resources.
		 7. Process One-Drive delegation request.
		 8. Disconnect from SQL and Azure services and remove temporary log files.
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#################################################
#    Step 1: Create SQL connectivity functions  #
#################################################

function WriteToMSSQLProd
{
	param(
		[string]$MSSQLCommand
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $MSSQLCommand, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function GetPendingTermedUser
{
	$TermedUser = $null
	$SQL = "select * from WebAdhocODDProcess where OverallStatus = 'Pending'"
	$Continue = "No";
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQL, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$TermedUser = $rdr["TermedUser"]
	}
	$rdr.Close()
	$con.Close()
	return $TermedUser
}

function GetPendingRequestingUser
{
	$RequestingUser = $null
	$SQL = "select * from WebAdhocODDProcess where OverallStatus = 'Pending'"
	$Continue = "No";
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQL, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$RequestingUser = $rdr["RequestingUser"]
	}
	$rdr.Close()
	$con.Close()
	return $RequestingUser
}

function SearchAnyPendingJobs
{
	param(
		[string]$TermedUser,
		[string]$RequestingUser
	)
	$Status = $null
	$SQL = "select * from WebAdhocODDProcess where TermedUser = '$TermedUser' and RequestingUser = '$RequestingUser'"
	$Continue = "No";
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQL, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Status = $rdr["OverallStatus"]
	}
	$rdr.Close()
	$con.Close()
	return $Status
}

function SearchCurrentPendingJobs
{
	param(
		[string]$TermedUser,
		[string]$RequestingUser
	)
	$SQL = "select * from WebAdhocODDProcess where TermedUser = '$TermedUser' and RequestingUser = '$RequestingUser'"
	$Continue = "No";
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQL, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Status = $rdr["OverallStatus"]
		if($Status -eq "Pending")
		{
			$Continue = "Yes"
		}
	}
	$rdr.Close()
	$con.Close()
	return $Continue
}

function ExtractingOneDriveSites
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '20%',msg = 'Extracting One-Drive Sites'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}


$TermedUser = GetPendingTermedUser
$RequestingUser = GetPendingRequestingUser

$AnyJobs = SearchAnyPendingJobs -TermedUser $TermedUser -RequestingUser $RequestingUser

if($AnyJobs -ne "Pending") { exit 0 }

if(($Termeduser -eq $null) -or ($RequestingUser -eq $null)) { exit 0 }

$CurrentJobsToRun = SearchCurrentPendingJobs -TermedUser $TermedUser -RequestingUser $RequestingUser

if($CurrentJobsToRun -eq "No") { exit 0 }


#################################################
#    Step 2: Define Prerequisite Variables      #
#################################################

WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set OverallStatus = 'Running' where TermedUser = '$Termeduser' and RequestingUser = '$RequestingUser'"
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDRunSummary set Status = 'Running' where TermedUser = '$Termeduser' and RequestingUser = '$RequestingUser'"

WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set CurrentModuleProcessing = 'Initializing'"

[String]$DTGStamp = Get-Date -Format "yyyyMMddHHmmSS"
$me = "dave.jaynes@eversana.com"
$secondaryAdmin = "srv_OneDriveRetention@eversana.com"
$from = 'srv_OneDriveRetention@eversana.com'
$fromError = 'AzureAutomation@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$RunningLogFile = "C:\java\IDM\Logs\OneDriveDelegationLogfile_$DTGStamp.txt"
$UPNArrayList = New-Object -TypeName "System.Collections.ArrayList"
$URLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$TermedEmployeeArrayList = New-Object -TypeName "System.Collections.ArrayList"
$ExpirationURLArrayList = New-Object -TypeName "System.Collections.ArrayList"
$DAP = "WebDelegatesAlreadyProcessed"
$EncryptionSQLDatabase = "encryptedpasswords"
$EncryptionSQLTable = "encryptedpasswords"
$UnauthorizedList = "UnauthorizedList"
$ThisDate = (Get-Date).ToString("yyyyMMdd")
$HTMLFile = "C:\java\IDM\HTML\HTMLFile_$ThisDate.txt"
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }

# Create Junk Files for Azure connects and Disconnects
$AzAccountConnection = "C:\java\IDM\Logs\AzAccountConnection_$DTGStamp"
$AzAccountDisconnection = "C:\java\IDM\Logs\AzAccountDisconnection_$DTGStamp"
$AzureADConnection = "C:\java\IDM\Logs\AzureADConnection_$DTGStamp"
$AzureADDisconnection = "C:\java\IDM\Logs\AzureADDisconnection_$DTGStamp"
$SPOServiceConnection = "C:\java\IDM\Logs\SPOServiceConnection_$DTGStamp"
$SPOServiceDisconnection = "C:\java\IDM\Logs\SPOServiceDisconnection_$DTGStamp"
$PnPOnlineConnection = "C:\java\IDM\Logs\PnPOnlineConnection$DTGStamp"
$PnPOnlineDisconnection = "C:\java\IDM\Logs\PnPOnlineDisconnection$DTGStamp"
sleep 2
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set CurrentModuleProcessing = 'CreateHTML'"
#################################################
#    Step 2: Write Daily Report Headings        #
#################################################
[String]$TodaysDate = Get-Date -Format 'MMMM dd, yyyy'
Add-Content -Path "$RunningLogFile" -Value ""
Add-Content -Path "$RunningLogFile" -Value "Daily Set-OneDriveDelegation Detail Logging for $TodaysDate"
Add-Content -Path "$RunningLogFile" -Value "------------------------------------------------------------------"
Add-Content -Path "$RunningLogFile" -Value ""

#################################################
#    Step 3: Create HTML E-Mail file entries    #
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

####################################################################################
#    Step 5: Pull Azure and SharePoint credentials based on user running script.   #
####################################################################################

# Pull the correct encrypted credentials based on the user running this script.
$currentUser = $env:UserName

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\java\credentials\PowerBIUserName.txt"
$serviceAccountPassword1 = Get-Content "C:\java\Credentials\PowerBIPassword.txt" | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

# Create the credentials for AzureAD
$serviceAccountUserName2 = Get-Content "C:\java\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\java\Credentials\OneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Set credentials for AzureAutomation to authorize the sending of error email messages.
$serviceAccountUserName3 = Get-Content "C:\java\credentials\AzureAutomationUserName.txt"
$serviceAccountPassword3 = Get-Content "C:\java\Credentials\AzureAutomationPassword.txt" | ConvertTo-SecureString

$credentialsError = New-Object System.Management.Automation.PSCredential($serviceAccountUserName3,$serviceAccountPassword3)

sleep 2
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set CurrentModuleProcessing = 'ConnectToAzure'"

#################################################
#    Step 6: Connect to Azure Resources         #
#################################################

Add-Content -Path "$RunningLogFile" -Value "Connection to Azure Resources"
# Connect to AzAccount for access to Storage Tables
Connect-AzAccount -Credential $credential1|Out-File -FilePath $AzAccountConnection

# Connect to Azure Active Directory
Connect-AzureAD -Credential $credential2|Out-File -FilePath $AzureADConnection

#Connect to SharePoint Admin
$TenantURL = 'https://eversana-admin.sharepoint.com/'
Connect-SPOService -url $TenantURL -Credential $credential2|Out-File -FilePath $SPOServiceConnection

####################################################
#    Step 7: Process One-Drive delegation request  #
####################################################
sleep 2
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set CurrentModuleProcessing = 'MoveFiles'"
<#
Compile an listing within the array '$delegates' of those employees in AD who meet this criteria:
1. Marked as disabled is AD.
2. The One-Drive URL field is populated.
3. The delegate object is populated with an employee record.
#>

Add-Content -Path "$RunningLogFile" -Value ""
Add-Content -Path "$RunningLogFile" -Value "Processing recently terminated users one at a time"

$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'"

$delegates = @()

$connStr = @"
DSN=DBWebConnection;
"@
$con = New-Object System.Data.Odbc.OdbcConnection $connStr
$con.Open()
$sql = "select TermedUser, RequestingUser from WebAdhocODDProcess"
$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
$rdr = $cmd.ExecuteReader()

# Here is where we loop through the folks terminated yesterday.
while ($rdr.Read())
{
	$disabledUserUPN = $rdr["TermedUser"]
	$AlternateManagerUPN = $rdr["RequestingUser"]
	$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $disabledUserUPN})
	$termName = $disabledUserUPN
	
	if($delegate -ne '' -and $delegate -ne $null)
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
		$managerEnabled = $manager.AccountEnabled
		$managerUPN = $AlternateManagerUPN
                
		# We need to service account 'srv_OneDriveRetention@eversana.com' as a Site Collection Admin for this account
		# so it has the rights to scan, read and copy files from the ex-delegates folder to the managers folders.

		Add-Content -Path "$RunningLogFile" -Value ""
		Add-Content -Path "$RunningLogFile" -Value "Setting $secondaryAdmin as a temporary Site Collection Admin"
		Set-SPOUser -site $URL -LoginName $secondaryAdmin -IsSiteCollectionAdmin $True

			#Connect to SharePoint Site Directly
		Add-Content -Path "$RunningLogFile" -Value ""
		Add-Content -Path "$RunningLogFile" -Value "Connecting to PnPOnline for URL [$URL]"

		Connect-PnPOnline -Url $URL -Credentials $credential2|Out-File -FilePath $PnPOnlineConnection
			#Get folders only in root Documents directory
		try
		{
			$web = Get-PnPWeb
		}
		catch
		{
			Write-Host "Connect-PnPOnline -Url $URL -Credentials omitted Out-File -FilePath $PnPOnlineConnection"
			Write-Host "Error occurred when executing Get-PnPWeb. Error is:"
			Write-Host
			Write-Host $_
		}
		$relativeUrl = $web.ServerRelativeUrl + "/Documents/"
		
		try
		{
			$foldersDraft = ((Get-PnPListItem -PageSize 4900 -List Documents -Fields ID,Title,GUID).FieldValues | Where-Object {($_.FileRef -notlike "$relativeUrl*.*") -and ($_.FileRef -notlike "$relativeUrl*/*")}).FileRef
		}
		catch
		{
			Write-Host "Connect-PnPOnline -Url $URL -Credentials omitted Out-File -FilePath $PnPOnlineConnection"
			Write-Host "Error occurred when executing Get-PnPListItem. Error is:"
			Write-Host
			Write-Host $_
		}
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
	
		try 
		{
			Add-Content -Path "$RunningLogFile" -Value ""
			Add-Content -Path "$RunningLogFile" -Value "Adding folder [$folderName] in /Documents directory"
			$folderAdd = Add-PNPFolder -Name $folderName -Folder Documents
		}
		catch
		{
			Write-Host "Error occurred when adding folder [$folderName]. Error is:"
			Write-Host
			Write-Host $_
			
			Add-Content -Path "$RunningLogFile" -Value ""
			Add-Content -Path "$RunningLogFile" -Value "Main Folder [$folderName] already exists --- will not recreate it"
			Write-Host "Main Folder [$folderName] already exists."
		}
		foreach ($folder in $folders)
		{
			try
			{
				Add-Content -Path "$RunningLogFile" -Value ""
				Add-Content -Path "$RunningLogFile" -Value "Moving folder [$folder] into TERM folder."
				$folderMove = Move-PnpFolder -Folder $folder -TargetFolder $targetFolder
			}
			catch
			{
				Write-Host "Error occurred when Moving folder [$folderName]. Error is:"
				Write-Host
				Write-Host $_
					
				Add-Content -Path "$RunningLogFile" -Value ""
				Add-Content -Path "$RunningLogFile" -Value "Cannot move folder [$folderName] as it does not exist."
				Write-Host "Sub Folder [$folderName] does not exist."
			}
		}
		# Get remaining files to move into new folder
		$filesAll = (Get-PnPListItem -PageSize 4900 -List Documents -Fields ID,Title,GUID).FieldValues
		$files = $filesAll | Where-Object {$_.FileRef -notlike "*$folderName*"}
		foreach ($file in $files)
		{
			$sourceFile = $file.FileRef
			$filepathIndex = $($sourceFile.indexOf("Documents/")) + 10
			$filepathExtract = $sourceFile.Substring(0,$filepathIndex)
			$targetFile = $filepathExtract+$folderName+"/"+$file.FileLeafRef
			try
			{
				Add-Content -Path "$RunningLogFile" -Value ""
				Add-Content -Path "$RunningLogFile" -Value "Moving file [$sourceFile] into folder [$targetFile]"
				$fileMove = Move-PnpFile -ServerRelativeUrl $sourceFile -TargetURL $targetFile -Force
			}
			catch
			{
				Write-Host "Error occurred when Moving file [$sourceFile] into folder [$targetFile]. Error is:"
				Write-Host
				Write-Host $_
				Add-Content -Path "$RunningLogFile" -Value ""
				Add-Content -Path "$RunningLogFile" -Value "Cannot move file [$sourceFile] as it does not exist."
				Write-Host "File [$sourceFile] does not exist."
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

		Add-Content -Path "$HTMLFile" -Value "</body>"
		Add-Content -Path "$HTMLFile" -Value "</html>"
		$body = Get-Content $HTMLFile -Raw
		$recipients = "$managerUPN,$me"
		[string[]]$to = $recipients.Split(',')
		Send-MailMessage `
			-From $from `
			-To $to `
			-Subject $subject `
			-Body $body `
			-BodyAsHtml `
			-UseSsl `
			-SmtpServer $SmtpServer `
			-Port $SmtpPort `
			-credential $credential2

		Add-Content -Path "$RunningLogFile" -Value ""
		Add-Content -Path "$RunningLogFile" -Value "Adding record into the Azure Storage Table"
		
		# This one list is the reason for the entire script!
		Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
	}
}

#########################################################################################
#     Step 8: Disconnect from SQL and Azure services and remove temporary log files     #
#########################################################################################
$rdr.Close()
$con.Close()

Disconnect-AzureAD|Out-File -FilePath $AzureADDisconnection
Disconnect-SPOService|Out-File -FilePath $SPOServiceDisconnection
Disconnect-AzAccount|Out-File -FilePath $AzAccountDisconnection
$DoesFileExist = Test-Path $AzAccountConnection
if($DoesFileExist -eq "True") { Remove-Item $AzAccountConnection }
$DoesFileExist = Test-Path $AzureADConnection
if($DoesFileExist -eq "True") { Remove-Item $AzureADConnection }
$DoesFileExist = Test-Path $SPOServiceConnection
if($DoesFileExist -eq "True") { Remove-Item $SPOServiceConnection }
$DoesFileExist = Test-Path $AzureADDisconnection
if($DoesFileExist -eq "True") { Remove-Item $AzureADDisconnection }
$DoesFileExist = Test-Path $SPOServiceDisconnection
if($DoesFileExist -eq "True") { Remove-Item $SPOServiceDisconnection }
$DoesFileExist = Test-Path $AzAccountDisconnection
if($DoesFileExist -eq "True") { Remove-Item $AzAccountDisconnection }
$DoesFileExist = Test-Path $PnPOnlineConnection
if($DoesFileExist -eq "True") { Remove-Item $PnPOnlineConnection }
$DoesFileExist = Test-Path $PnPOnlineDisconnection
if($DoesFileExist -eq "True") { Remove-Item $PnPOnlineDisconnection }

Add-Content -Path "$RunningLogFile" -Value ""
Add-Content -Path "$RunningLogFile" -Value "All delegates processed ... see you tomorrow!!"
Add-Content -Path "$RunningLogFile" -Value ""

WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set CurrentModuleProcessing = 'FinishUp'"
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDProcess set OverallStatus = 'Completed' where TermedUser = '$Termeduser' and RequestingUser = '$RequestingUser'"
WriteToMSSQLProd -MSSQLCommand "update WebAdhocODDRunSummary set Status = 'Completed' where TermedUser = '$Termeduser' and RequestingUser = '$RequestingUser'"