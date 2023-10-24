[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Connect to services
$serviceAccountUserName1 = Get-Content "C:\Apache24\credentials\PowerBIUserName.txt"
$serviceAccountPassword1 = Get-Content "C:\Apache24\credentials\EncryptedPowerBiPassword.txt" | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)
Connect-AzAccount -Credential $credential1
$serviceAccountUserName2 = Get-Content "C:\Apache24\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\Apache24\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)
Connect-AzureAD -Credential $credential2
$TenantURL = 'https://eversana-admin.sharepoint.com/'
Connect-SPOService -url $TenantURL -Credential $credential2
$serviceAccountUserName3 = Get-Content "C:\Apache24\credentials\AzureAutomationUserName.txt"
$serviceAccountPassword3 = Get-Content "C:\Apache24\credentials\EncryptedAzureAutomationPassword.txt" | ConvertTo-SecureString
Disconnect-AzureAD
Disconnect-SPOService
Disconnect-AzAccount
Disconnect-PnPOnline