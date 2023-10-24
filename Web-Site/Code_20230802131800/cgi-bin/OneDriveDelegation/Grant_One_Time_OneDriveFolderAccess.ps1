<#
		Program Name: Grant_One_Time_OneDriveFolderAccess.ps1
		Date Written: May 12th, 2023
		  Written By: Dave Jaynes
		 Description: Automate Delegated Access to Personal OneDrive Accounts
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DAP = "WebDelegatesAlreadyProcessed"
$SAP = "WebStatusOfODDProgress"
$ProcessRequest = "WebProcessAccessRequest"
$secondaryAdmin = "srv_OneDriveRetention@eversana.com"
$from = 'srv_OneDriveRetention@eversana.com'
$Bcc = 'idminternal@eversana.com'
$fromError = 'AzureAutomation@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$HTMLFile = "C:\Apache24\cgi-bin\WorkingTextFiles\HTMLFile.txt"
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }

##############################################################
#           F U N C T I O N S   S E C T I O N                #
##############################################################

function AddAccessEMailTemplate
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
	
	$HTMLFile = "C:\Apache24\cgi-bin\WorkingTextFiles\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	
	$dateFormat = 'dddd, MMMM dd, yyyy'
	$30Days = (Get-Date).AddDays(30)
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
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>You have requested access to the One-Drive account belonging to <FONT COLOR=blue SIZE=3><i>$niceEmployeeName</i></FONT>. Your request has been approved and now have been delegated read-only access to this site.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Please back up any of $niceFirstName's important files to your personal space before <FONT COLOR=blue SIZE=3><b>$FutureDate</b></font>, after which time they will be deleted.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>If this folder is empty, the user most likely did not have any files stored in their OneDrive repository, or the files have been removed due to a 30 day retention policy limit being exceeded.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "<br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='SummaryText'>OneDrive Details</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Disabled User: $TermedEmployee</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Requestor: $Manager</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Link to One-Drive Site: <a href='$oneDriveURL'>Click Here</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
}

function RemoveAccessEMailTemplate
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
	
	$HTMLFile = "C:\Apache24\cgi-bin\WorkingTextFiles\HTMLFile.txt"
	$DoesFileExist = Test-Path $HTMLFile
	if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
	
	$dateFormat = 'dddd, MMMM dd, yyyy'
	$30Days = (Get-Date).AddDays(30)
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
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>You are receiving this E-Mail to inform you that your Read-Only access to $niceEmployeeName's One-Drive site has been removed.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>If you still require Read-Only access this this account, please submit a ticket via Service-Now to have your access reinstated.</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "<br>"
	Add-Content -Path "$HTMLFile" -Value "<table>"
	Add-Content -Path "$HTMLFile" -Value "<tr><td><p class='DetailText'>Regards, IT Automation Support</p></td></tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
}

function FindPendingRecords
{
	$Count = 0
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select count(*) from $ProcessRequest where CurrentlyProcessing = 1"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Count = $rdr[""]
	}
	$rdr.Close()
	$con.Close()
	return $Count
}

function FindLatestTimestamp
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select top 1 TimeStamp from $ProcessRequest where status = 'Pending' and CurrentlyProcessing = 1 order by TimeStamp asc"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$DTG = $rdr["TimeStamp"]
	}
	$rdr.Close()
	$con.Close()
	return $DTG
}

function FindEmployee {
	Param (
		[datetime]$DTG
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select Employee from $ProcessRequest where TimeStamp = '$DTG'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Employee = $rdr["Employee"]
	}
	$rdr.Close()
	$con.Close()
	return $Employee
}

function FindPersonRequestingAccess {
	Param (
		[datetime]$DTG
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select PersonRequestingAccess from $ProcessRequest where TimeStamp = '$DTG'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$PersonRequestingAccess = $rdr["PersonRequestingAccess"]
	}
	$rdr.Close()
	$con.Close()
	return $PersonRequestingAccess
}

function FindAction {
	Param (
		[datetime]$DTG
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select Action from $ProcessRequest where TimeStamp = '$DTG'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Action = $rdr["Action"]
	}
	$rdr.Close()
	$con.Close()
	return $Action
}

function SetStatusToComplete {
	Param (
		[string]$Employee
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $ProcessRequest set status = 'Completed' where Employee = '$Employee'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function SetCurrentlyProcessingToZero {
	Param (
		[string]$Employee
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $ProcessRequest set CurrentlyProcessing = 0 where Employee = '$Employee'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function FindDelegatedURL {
	Param (
		[string]$Employee
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select DelegatedURL from $DAP where Owner = '$Employee'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$DelegatedURL = $rdr["DelegatedURL"]
	}
	$rdr.Close()
	$con.Close()
	return $DelegatedURL
}

function FindTargetFolder {
	Param (
		[string]$Employee
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select TargetFolder from $DAP where Owner = '$Employee'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$TargetFolder = $rdr["TargetFolder"]
	}
	$rdr.Close()
	$con.Close()
	return $TargetFolder
}

function NoAssociateName
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set msg = 'No associate name selected',msg1 = 'Please select associate name'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function NoRequesterName
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '0%',msg = 'Process canceled due to no Requester name',msg1 = 'This process will not be run as no Requester E-Mail Address was entered',msg2 = 'Please enter requester E-Mail Address'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function ConnectingToCloudServices
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '10%',msg = 'Connecting to Cloud Services'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
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

function ExtractingDelegates
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '30%',msg = 'Pulling Delegate Names from AD'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function FilteringOutDisabledUsers
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '40%',msg = 'Filtering Out Disabled Users'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function PullingSharePointFolders
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '50%',msg = 'Pulling SharePoint Folders'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function DeterminingTargetFolder
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '60%',msg = 'Determining Target Folder'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function CreatingTargetURLS
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '70%',msg = 'Building Target URLs'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function SettingRequesterPermissions
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '80%',msg = 'Setting Requester One-Drive Permissions'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function ComposingEMailMessage
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set pctdone = '90%',msg = 'Sending out E-Mail to Requester'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function CompletedODD {
	Param (
		[string]$Action,
		[string]$Requester,
		[string]$Employee
	)
	# Generate nice associate name
	$firstName = $Employee.split("@")[0].split(".")[0]
	$lastName = $Employee.split("@")[0].split(".")[1]
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
	
	# Generate nice requster name
	$firstName = $Requester.split("@")[0].split(".")[0]
	$lastName = $Requester.split("@")[0].split(".")[1]
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
	$niceRequesterName = $niceFirstName + $space + $niceLastName
	
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	
	if($Action -eq 'ADD')
	{
		$sql = "update $SAP set pctdone = '100%',msg = 'Delegation Process has Completed Successfully!',msg1 = 'Access has been granted to $niceRequesterName for the OneDrive files formally owned by $niceEmployeeName.',msg2 = 'An E-Mail message has been sent to $niceRequesterName with a link providing direct access to this OneDrive site.'"
	}
	else
	{
		$sql = "update $SAP set pctdone = '100%',msg = 'Sending out E-Mail to Requester',msg1 = 'Access to $Employee One-Drive Site has been removed from ${niceRequesterName}.',msg2 = 'An E-Mail message has been sent to $niceRequesterName informing the associate of the access removal action.'"
	}
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

##############################################################
#         E N D   F U N C T I O N S   S E C T I O N          #
##############################################################

##############################################################
#       M A I N   P R O C E S S I N G   S E C T I O N        #
##############################################################

[int]$PendingRecords = 0
$PendingRecords = FindPendingRecords
if($PendingRecords -gt 0)
{
	# Get TimeStamp of record to process so we are pulling all fields from the same record.
	[DateTime]$TimeStampDate = FindLatestTimestamp
	$Employee = FindEmployee -DTG $TimeStampDate
	$PersonRequestingAccess = FindPersonRequestingAccess -DTG $TimeStampDate
	$Action = FindAction -DTG $TimeStampDate
	$ProcessODD = "Yes"
	
	if($Employee -eq '' -or $Employee -eq $null)
	{
		NoAssociateName
		$ProcessODD = "No"
	}
	else
	{
		$Employee = $Employee.ToLower()
	}

	if($PersonRequestingAccess -eq '' -or $Employee -eq $null)
	{
		$ProcessODD = "No"
		NoRequesterName
	}
	else
	{
		$PersonRequestingAccess = $PersonRequestingAccess.ToLower()
	}

	if($ProcessODD -eq "Yes")
	{
		$Action = $Action.ToUpper()
		$US = '_'
		$firstName = $Employee.split(".")[0]
		$temp = $Employee.split(".")[1]
		$lastName = $temp.split("@")[0]
		$temp = $firstName + $US + $lastName
		$fullName = $temp.ToLower()
		$URL = 'https://eversana-my.sharepoint.com/personal/' + $fullName + '_eversana_com'
		$secondaryAdmin = "srv_OneDriveRetention@eversana.com"
		
		ConnectingToCloudServices
		# Connect to services
		$serviceAccountUserName1 = Get-Content "C:\Apache24\credentials\PowerBIUserName.txt"
		$serviceAccountPassword1 = Get-Content "C:\Apache24\credentials\EncryptedPowerBiPassword.txt" | ConvertTo-SecureString
		$credential1 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)
		Connect-AzAccount -Credential $credential1|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
		$serviceAccountUserName2 = Get-Content "C:\Apache24\credentials\OneDriveRetentionUserName.txt"
		$serviceAccountPassword2 = Get-Content "C:\Apache24\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
		$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)
		Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
		$TenantURL = 'https://eversana-admin.sharepoint.com/'
		Connect-SPOService -url $TenantURL -Credential $credential2|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
		$serviceAccountUserName3 = Get-Content "C:\Apache24\credentials\AzureAutomationUserName.txt"
		$serviceAccountPassword3 = Get-Content "C:\Apache24\credentials\EncryptedAzureAutomationPassword.txt" | ConvertTo-SecureString

		# The follow lines 343 thru 374 extract the $targetFolder, $manager and $oneDriveURL variables values so we can set permissions for the person requesting access and put that information into the E-Mail to provide a One-Click link to the former associate's One-Drive site.
		ExtractingOneDriveSites
		$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'"
		ExtractingDelegates
		$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $Employee})
		$termName = $(($($Employee.split("@"))[0]).ToUpper())
		FilteringOutDisabledUsers
		$disabledUser = get-azureaduser -All $true -filter "UserPrincipalName eq '$Employee'"
		$disabledUserUPN = $disabledUser.UserPrincipalName
		$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $disabledUserUPN})
		$delegateURL = $delegate.Url
		$URL = ''
		$URL = $delegate.Url
		$owner = ''
		$owner = $delegate.Owner
		$ownerUpper = $owner.ToUpper()
		PullingSharePointFolders
		$ownerAzureAD = Get-AzureADUser -filter "UserPrincipalName eq `'$owner`'"
		$manager = Get-AzureADUser -filter "userPrincipalName eq '$personRequestingAccess'"
		$managerUPN = $manager.UserPrincipalName
		$dateFuture = ((Get-Date).AddDays(30)).ToUniversalTime()
		Connect-PnPOnline -Url $URL -Credentials $credential2
		$web = Get-PnPWeb
		$relativeUrl = $web.ServerRelativeUrl + "/Documents/"
		$termDate = Get-Date -Format yyyMMdd
		$folderName = "TERM-"+$termDate+"-"+$termName
		$targetFolder = "Documents/"+$folderName
		DeterminingTargetFolder
		$baseUrl = $web.Url
		$urlID = $relativeUrl + $folderName
		$urlID = [System.Web.HTTPUtility]::UrlEncode($urlID)
		$urlID = $urlID.Replace("_","%5F")
		$urlID = $urlID.Replace(".","%2E")
		$urlID = $urlID.Replace("-","%2D")
		CreatingTargetURLS
		$oneDriveURL = $baseUrl + "/_layouts/15/onedrive.aspx?id=" + $urlID
		Set-SPOUser -site $URL -LoginName $secondaryAdmin -IsSiteCollectionAdmin $True|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
		$oneDriveURL = FindDelegatedURL -Employee $Employee
		$targetFolder = FindTargetFolder -Employee $Employee
		#$oneDriveURL = SQLRead -SQLCommand "select DelegatedURL from $DAP where Owner = '$Employee'"
		#$targetFolder = SQLRead -SQLCommand "select TargetFolder from $DAP where Owner = '$Employee'"
	
		# Use the SWITCH command to determine which course of action to take regarding access to the Former Associate's OneDrive site.
		# This action comes directly from the selection made on the Add/Remove Access Radio buttons within the Web Page.
		switch($Action)
		{
			ADD
			{
				try
				{
					SettingRequesterPermissions
					Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $PersonRequestingAccess -AddRole 'Read'
					ComposingEMailMessage
					AddAccessEMailTemplate -TermedEmployee $termName -Manager $managerUPN -FutureDate $dateFuture -OneDriveURL $oneDriveURL
					Add-Content -Path "$HTMLFile" -Value "</body>"
					Add-Content -Path "$HTMLFile" -Value "</html>"
					$addAccessSubjectLine = "OneDrive Account Access for " + $ownerUpper
					$body = Get-Content $HTMLFile -Raw
					$recipients = "$managerUPN"
					[string[]]$to = $recipients.Split(',')
					Send-MailMessage `
						-From $from `
						-To $to `
						-Bcc $Bcc `
						-Subject $addAccessSubjectLine `
						-Body $body `
						-BodyAsHtml `
						-UseSsl `
						-SmtpServer $SmtpServer `
						-Port $SmtpPort `
						-credential $credential2
				}
				catch
				{
					AddAccessEMailTemplate -TermedEmployee $termName -Manager $managerUPN -FutureDate $dateFuture -OneDriveURL $oneDriveURL
					Add-Content -Path "$HTMLFile" -Value "</body>"
					Add-Content -Path "$HTMLFile" -Value "</html>"
					$addAccessSubjectLine = "OneDrive Account Access for " + $ownerUpper
					$body = Get-Content $HTMLFile -Raw
					$recipients = "$managerUPN"
					[string[]]$to = $recipients.Split(',')
					Send-MailMessage `
						-From $from `
						-To $to `
						-Bcc $Bcc `
						-Subject $addAccessSubjectLine `
						-Body $body `
						-BodyAsHtml `
						-UseSsl `
						-SmtpServer $SmtpServer `
						-Port $SmtpPort `
						-credential $credential2				
				}
				break
			}
			REMOVE
			{
				try
				{
					SettingRequesterPermissions
					Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $PersonRequestingAccess -RemoveRole 'Read'
					ComposingEMailMessage
					RemoveAccessEMailTemplate -TermedEmployee $termName -Manager $managerUPN -FutureDate $dateFuture -OneDriveURL $oneDriveURL
					Add-Content -Path "$HTMLFile" -Value "</body>"
					Add-Content -Path "$HTMLFile" -Value "</html>"
					$removeAccessSubjectLine = "OneDrive Account Access for " + $ownerUpper
					$body = Get-Content $HTMLFile -Raw
					$recipients = "$managerUPN"
					[string[]]$to = $recipients.Split(',')
					Send-MailMessage `
						-From $from `
						-To $to `
						-Bcc $Bcc `
						-Subject $removeAccessSubjectLine `
						-Body $body `
						-BodyAsHtml `
						-UseSsl `
						-SmtpServer $SmtpServer `
						-Port $SmtpPort `
						-credential $credential2
				}
				catch
				{
					RemoveAccessEMailTemplate -TermedEmployee $termName -Manager $managerUPN -FutureDate $dateFuture -OneDriveURL $oneDriveURL
					Add-Content -Path "$HTMLFile" -Value "</body>"
					Add-Content -Path "$HTMLFile" -Value "</html>"
					$removeAccessSubjectLine = "OneDrive Account Access for " + $ownerUpper
					$body = Get-Content $HTMLFile -Raw
					$recipients = "$managerUPN"
					[string[]]$to = $recipients.Split(',')
					Send-MailMessage `
						-From $from `
						-To $to `
						-Bcc $Bcc `
						-Subject $removeAccessSubjectLine `
						-Body $body `
						-BodyAsHtml `
						-UseSsl `
						-SmtpServer $SmtpServer `
						-Port $SmtpPort `
						-credential $credential2
				}
				break
			}
			Default
			{
				Write-Host "[$action] is an invalid switch ... only Add and Remove are permitted."
			}
		}
		CompletedODD -Action $Action -Requester $PersonRequestingAccess -Employee $Employee
	}

	# Disconnect to the Azure services now that our connections are no longer needed.
	Disconnect-AzureAD|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
	Disconnect-SPOService|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
	Disconnect-AzAccount|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
	Disconnect-PnPOnline|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt

	# Finally we update the processaccessrequest table, setting the status field to complete and the CurrentlyProcessing to a value of 0 (false).
	# These updates will trigger the GrantOneDriveFolderAccess.pl CGI script to update the web page, informing the user the process has completed.
	SetStatusToComplete -Employee $Employee
	SetCurrentlyProcessingToZero -Employee $Employee
}
