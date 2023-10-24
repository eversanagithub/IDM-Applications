[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UPNArrayList = New-Object -TypeName "System.Collections.ArrayList"
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "OneDriveDelegation"
$Table = "newonedrivedelegation"

# Define the SQL read function for one statement.
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

function SQLQueryCommand    
{
	param(
		[string]$SQLCommand,
		[int]$element,
		[int]$field
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
	$a[$element]
}

$Junk = $UPNArrayList.Add("Hello")
$UPNArrayList
$UPNArrayList.Clear()
$UPNArrayList
$disabledUserUPN = "saraha.brown@eversana.com"
#$disabledUserUPN = "joe.blow@eversana.com"
[String[]]$Name = SQLOneQueryCommand -SQLCommand "select Owner from $Table"

if ($Name -notcontains $disabledUserUPN)
{
	Write-Host "Not Found"
}



<#
exit
[int]$NumRows = 0
$NumRows = SQLOneQueryCommand -SQLCommand "select count(*) from $Table"
for ($i=0; $i -lt $NumRows;$i++)
{
	$Name = SQLQueryCommand -SQLCommand "select Owner from $Table" -element $i -field 0
	$Junk = $UPNArrayList.Add($Name)
	Write-Host "$i of $NumRows"
}
Write-Host
Write-Host
$UPNArrayList.Count
#>