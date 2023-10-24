[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw

# Define SQL information
$SQLServer = "10.241.36.13"
$SQLDatabase = "encryptedpasswords"
$SQLTable = "encryptedpasswords"

# Set up the SQL Read single field function
function SQLRead    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\Connector NET 8.0\Assemblies\v4.5.2\\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$SQLDatabase;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$SQLReturnValue = while($myreader.Read()){ $myreader.GetString($field) }
	$myconnection.Close()
	$SQLReturnValue
}

$currentUser = $env:UserName
$serviceAccountUserName = Get-Content "C:\PowerShell\credentials\O365UserName.txt"
$EncryptedPasswordFile = SQLRead -SQLCommand "select filepath from $SQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName'"
$serviceAccountPassword = Get-Content $EncryptedPasswordFile | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($serviceAccountUserName,$serviceAccountPassword)
Connect-AzureAD -Credential $credentials

Disconnect-AzureAD

