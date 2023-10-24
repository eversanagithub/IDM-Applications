<#
		Program Name: SendClientWebsiteInvite.ps1
		Date Written: May 28th, 2023
		  Written By: Dave Jaynes
		 Description: Send designated client e-mail invite to IDM website
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$EmpID = $args[0]
$Table = "WebEncryptedKeys"

function CreateEncryptedKey {
	Param (
		[string]$EmpID
	)
	$connStr = @"
	DSN=DBWebConnection;
"@

	$UnEncryptedKey2 = Get-Random
	$EncryptedKey2 = $UnEncryptedKey2| ConvertTo-SecureString –AsPlainText –Force | ConvertFrom-SecureString
	$UnEncryptedKey = $UnEncryptedKey2.ToString()
	$MyEncryptedKey = $EncryptedKey2.ToString()
	$Length = $MyEncryptedKey.Length
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()

	# Nuke the old entry
	$sql = "delete from $Table where EmpID = '$EmpID'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()

	# Create the new entry.
	$sql = "insert into $Table(EmpID,UnEncryptedKey,EncryptedKey) values ('$EmpID','$UnEncryptedKey','$MyEncryptedKey')"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	
	$con.Close()
}

CreateEncryptedKey -EmpID $EmpID
