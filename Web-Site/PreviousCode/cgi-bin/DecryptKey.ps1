<#
		Program Name: DecryptKey.ps1
		Date Written: May 28th, 2023
		  Written By: Dave Jaynes
		 Description: Decrypt encrypted Key
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$EncryptedKey = $args[0]
Write-Host
Write-Host "Using decrypted key: $EncryptedKey"
Write-Host
function Decrypt
{
	Param (
		[Parameter(ParameterSetName = 'SpecifyConnectionFields', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$EncryptedKey
	)
	$securepwd = $EncryptedKey | ConvertTo-SecureString
	$Marshal = [System.Runtime.InteropServices.Marshal]
	$Bstr = $Marshal::SecureStringToBSTR($securepwd)
	$Secret = $Marshal::PtrToStringAuto($Bstr)
	return $Secret
}

Decrypt -EncryptedKey $EncryptedKey

