[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw

# Define SQL information
$SQLServer = "10.241.36.13"
$SQLDatabase = "encryptedpasswords"
$SQLTable = "encryptedpasswords"
$DevOrProd = "SNtoSPDevOrProd"

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

function Decrypt
{
	Param 
	(
		[string]$EncryptedPassword
	)
	$securepwd = $EncryptedPassword | ConvertTo-SecureString
	$Marshal = [System.Runtime.InteropServices.Marshal]
	$Bstr = $Marshal::SecureStringToBSTR($securepwd)
	$Secret = $Marshal::PtrToStringAuto($Bstr)
	return $Secret
}

$currentUser = $env:UserName
$serviceAccount = Get-Content "C:\PowerShell\credentials\O365UserName.txt"
$EncryptedPassword = SQLRead -SQLCommand "select encryptedpassword from encryptedpasswords where currentUser = '$currentUser' and serviceAcct = '$serviceAccount'"
$password = Decrypt -EncryptedPassword $EncryptedPassword
Write-Host "password = [$password]"
$SecurePassword = ConvertTo-SecureString "$password" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($serviceAccount, $SecurePassword)
Connect-AzureAD -Credential $credentials
Disconnect-AzureAD

