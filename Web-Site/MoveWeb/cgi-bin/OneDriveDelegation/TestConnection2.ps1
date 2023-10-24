[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ProcessRequest = "processaccessrequest"

function Read_delegates_already_processed
{
	$connStr = @"
	DSN=IDMTrust;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn from delegates_already_processed"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$Owner = $rdr["Owner"]
		$Manager = $rdr["Manager"]
		$URL = $rdr["URL"]
		$DelegatedTo = $rdr["DelegatedTo"]
		$DelegatedOn = $rdr["DelegatedOn"]
		$DelegatedURL = $rdr["DelegatedURL"]
		$DelegationExpires = $rdr["DelegationExpires"]
		$TargetFolder = $rdr["TargetFolder"]
		$Valid = $rdr["Valid"]
		$ReminderModify = $rdr["ReminderModify"]
		$ReminderSentOn = $rdr["ReminderSentOn"]
		Write-Host "Owner = $Owner"
		Write-Host "Manager = $Manager"
		Write-Host "URL = $URL"
		Write-Host "DelegatedTo = $DelegatedTo"
		Write-Host "DelegatedOn = $DelegatedOn"
		Write-Host "DelegatedURL = $DelegatedURL"
		Write-Host "DelegationExpires = $DelegationExpires"
		Write-Host "TargetFolder = $TargetFolder"
		Write-Host "Valid = $Valid"
		Write-Host "ReminderModify = $ReminderModify"
		Write-Host "ReminderSentOn = $ReminderSentOn"
		Write-Host "-----------------------------------------------------------"
		#Write ("Owner: {0}] -> {1}" -f $rdr["name"], $rdr["create_date"])
	}
	$rdr.Close()
	$con.Close()
}

function Create_processaccessrequest
{
	$connStr = @"
	DSN=IDMTrust;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$ProcessRequest' AND TABLE_SCHEMA = 'dbo') CREATE TABLE $ProcessRequest(RecNo int IDENTITY(1,1) PRIMARY KEY,Employee varchar(70),PersonRequestingAccess varchar(70),Incident varchar(20),Action varchar(10),Status varchar(20),TimeStamp datetime,CurrentlyProcessing bit)"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

Create_processaccessrequest