[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Connect to AzAccount for access to Storage Tables
$AzAccountUserName = Get-Content "C:\PowerShell\credentials\PowerBIUserName.txt"
$AzAccountPassword = Get-Content "C:\PowerShell\credentials\EncryptedPowerBiPassword.txt" | ConvertTo-SecureString
$AzureADCredential = New-Object System.Management.Automation.PSCredential($AzAccountUserName,$AzAccountPassword)
Connect-AzAccount -Credential $AzureADCredential|Out-File -Filepath C:\temp\junk.txt

# Connect to Azure Active Directory
$AzureADUserName = Get-Content "C:\PowerShell\credentials\OneDriveRetentionUserName.txt"
$AzureADPassword = Get-Content "C:\PowerShell\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($AzureADUserName,$AzureADPassword)
Connect-AzureAD -Credential $credentials|Out-File -Filepath C:\temp\junk.txt

$User = "Naaman Endres"
$GUID = '6e895371-38f1-46c6-97db-00dd6c539479'
$nomfagroupObjectId = '2703905c-8d1a-4810-b9e9-229e2fc250aa'
$MAE = 'cc95345d-0d8c-4319-aae4-1f2889545474'
$ssprGroupObjectId = 'adcb0576-780e-4e87-b898-5ca81fd63d49'
$mfagroupObjectId = '270e3526-c06a-4fc9-a21c-701f5687d67d'

function Reset
{
	add-azureadgroupmember -objectid $nomfagroupObjectId -refobjectid $GUID
	add-azureadgroupmember -objectid $MAE -refobjectid $GUID
	remove-azureadgroupmember -objectid $ssprGroupObjectId -memberid $GUID
	remove-azureadgroupmember -objectid $mfagroupObjectId -memberid $GUID
}

function Check
{
	# Remove member from the Office365_NoMFA Group if they are currently a member.
	$Check = $null
	$Check = Get-azureadgroupmember -objectid $nomfagroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
	if($Check -ne '' -and $Check -ne $null) 	
	{
		Write-Host "$User is still in the Office365_NoMFA Group"
	}
	else
	{
		Write-Host "$User is no longer in the Office365_NoMFA Group"
	}
		
	# Remove member from the Mobile Attestation Exception Group if they are currently a member.
	$Check = $null
	$Check = Get-azureadgroupmember -objectid $MAE -All $true| ? {$_.ObjectId -eq $GUID}
	if($Check -ne '' -and $Check -ne $null)
	{
		Write-Host "$User is still in the Mobile Attestation Exception Group"
	}
	else
	{
	Write-Host "$User is no longer in the Mobile Attestation Exception Group"
	}

	# Add member to the Office365_SSPR_Required Group if they are not currently a member.
	$Check = $null
	$Check = Get-azureadgroupmember -objectid $ssprGroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
	if($Check -eq '' -or $Check -eq $null)
	{
		Write-Host "$User is no longer in the Office365_SSPR_Required Group"
	}
	else
	{
		Write-Host "$User is still in the Office365_SSPR_Required Group"
	}

	# Add member to the MFA Default Policy Group if they are not currently a member.
	$Check = $null
	$Check = Get-azureadgroupmember -objectid $mfagroupObjectId -All $true| ? {$_.ObjectId -eq $GUID}
	if($Check -eq '' -or $Check -eq $null)	
	{
		Write-Host "$User is no longer in the MFA Default Policy Group"
	}
	else
	{
		Write-Host "$User is still in the MFA Default Policy Group"
	}
}

# Reset
  Check

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk.txt