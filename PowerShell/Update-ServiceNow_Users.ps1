<#
		Program Name: Update-ServiceNow_Users.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Update ServiceNow_Users Group (SSO) and Approver_User Group (Manager Approval) 
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ServiceNow_Users_Group = "d0e48589-84bb-48cd-9434-d1474eeec0ef"
$EnabledUsers = get-aduser -filter {Enabled -eq $True -and (extensionAttribute4 -eq "human" -or extensionAttribute4 -like "*|*" -or extensionAttribute4 -like "*|")}

# Check to see if the employee is in the ServiceNow Users CN. If so, check to see if they
# are registered in the ServiceNow Users group. If now, add them to it.
foreach ($User in $EnabledUsers) 
{
	$GUID = $User.ObjectGUID.GUID
	$Membership = (get-aduser $GUID -Properties memberof).memberof
	if($Membership -like "CN=ServiceNow Users*" -or $Membership -like "*CN=ServiceNow Users*") 
	{
	} 
	else 
	{
		Add-ADGroupMember -Identity $ServiceNow_Users_Group -Members $GUID -Confirm:$false
	}
}
