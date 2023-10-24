<#
$EncryptedSQLUserName = "c:\Apache24\htdocs\IDM_Applications\credentials\EncryptedSQLUserName.txt"
$EncryptedSQLPassword = "c:\Apache24\htdocs\IDM_Applications\credentials\EncryptedSQLPassword.txt"

# The Azure user GUID of the person we want to pull Exchange information from.
$EMailID = '94b3f4ea-caea-4d82-a601-f0181f81ebc7'

# This is the 'Decrypt function I spoke to above. Note, this is not a system function but rather
# one I had to create from scratch. Its only function is to return the unencrypted text from
# the Secret and Client ID files also listed above.
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

$ClientID = Decrypt -EncryptedPath $EncryptedClientIDPath
$ClientSecret = Decrypt -EncryptedPath $EncryptedSecretPath
#>

Write-Host "IDMAPP"