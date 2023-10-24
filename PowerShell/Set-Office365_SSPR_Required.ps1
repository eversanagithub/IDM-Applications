<#
		Program Name: Set-Office365_SSPR_Required.ps1
		Date Written: February 8th, 2023
		  Written By: Dave Jaynes
		 Description: Automate Delegated Access to Personal OneDrive Accounts
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Connect to Azure Active Directory
$AzureADUserName = Get-Content "c:\powershell\credentials\SRV_SSPR_UserName.txt"
$AzureADPassword = Get-Content "c:\powershell\credentials\SRV_SSPR_Password.txt"| ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($AzureADUserName,$AzureADPassword)
Connect-AzureAD -Credential $credentials|Out-File -Filepath C:\temp\junk.txt

#Get all users in Azure AD
$allUsers = get-azureaduser -All $true

#Get SSPR group members
$ssprGroup = get-azureadgroup -searchstring "Office365_SSPR_Required"
$ssprGroupObjectId = $ssprGroup.objectid

#Create an array of objectID's
$ssprMembers = get-azureadgroupmember -ObjectID $ssprGroupObjectId -All $True
$ssprMembersObjectIdArray = $ssprMembers.ObjectID

#Get noMFA group members
$nomfagroup = get-azureadgroup -searchstring "Office365_NoMFA" | ? {$_.displayname -notlike "*ServiceAccount" -and $_.displayname -notlike "*SharedMailbox"}
$nomfagroupObjectId = $nomfagroup.objectid

#Create an array of objectID's
$nomfaMembers = get-azureadgroupmember -ObjectID $nomfagroupObjectId -All $True
$nomfaMembersObjectIdArray = $nomfaMembers.ObjectId

#Loop through all users
foreach ($user in $allUsers) 
{
	$userObjectId = $user.objectID
	$extProps = $user | select -expandproperty ExtensionProperty
	$accountType = $extProps.extension_906e14d00db8455cbcdd210acc93d584_extensionAttribute4 

	if ($user.AccountEnabled -eq "True") 
	{
		#Check if user is marked as a human account
		if (($accountType -eq "human") -or ($accountType -like "*|") -or ($accountType -like "*|*")) 
		{
			#If the enabled human user has MFA disabled, remove the user from the SSPR group
			if ($nomfaMembersObjectIdArray -contains $userObjectId) 
			{
				if ($ssprMembersObjectIdArray -contains $userObjectId) 
				{
					Write-Host "remove-azureadgroupmember -objectid $ssprGroupObjectId -memberid $userObjectId"
				}
			} 
			else 
			{
				#If the enabled human user has MFA enabled and is not a member of the SSPR group, add them to the SSPR group
				if ($ssprMembersObjectIdArray -notcontains $userObjectId) 
				{
					Write-Host "add-azureadgroupmember -objectid $ssprGroupObjectId -refobjectid $userObjectId"
				}
			}
		}
	} 
	else 
	{
		#If account is not enabled, remove from SSPR group
		if ($ssprMembersObjectIdArray -contains $userObjectId) 
		{
			Write-Host "remove-azureadgroupmember -objectid $ssprGroupObjectId -memberid $userObjectId"
		}
	}
}

Disconnect-AzureAD