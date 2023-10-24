$EncryptedPath = $args[0]
if($EncryptedPath -eq '' -or $EncryptedPath -eq $null)
{
	Write-Host
	Write-Host "Incorrect format."
	Write-Host
	Write-Host "Please type: dp Path_To_Encrypted_Password"
	Write-Host
	Write-Host "Example: dp c:\powershell\credentials\SharePointPassword.txt"
	Write-Host
	exit
}

function Decrypt
{
	Param (
		[Parameter(ParameterSetName = 'SpecifyConnectionFields', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$EncryptedPath
	)
	$EncryptedObject = Get-Content $EncryptedPath
	$securepwd = $EncryptedObject | ConvertTo-SecureString
	$Marshal = [System.Runtime.InteropServices.Marshal]
	$Bstr = $Marshal::SecureStringToBSTR($securepwd)
	$Secret = $Marshal::PtrToStringAuto($Bstr)
	return $Secret
}

$PlanTextPwd = Decrypt -EncryptedPath $EncryptedPath
Write-Host
Write-Host "Decrypted Password: $PlanTextPwd"
Write-Host
