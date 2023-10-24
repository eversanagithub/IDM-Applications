<#
		Program Name: Update-IT_Dept-All.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Update "IT Dept-All" Distribution List's Nested Distribution Lists. 
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Declare an array of all IT department codes
$departmentCodes = @("119990","150000","151000","152000","153000","153100","153200","153250","405000","409000","601000","602000","606990")

# Get current members of the parent "IT Dept - All" DL
$group = "IT Dept - All-1111362042"
$itUsers = (get-adgroupmember $group -Recursive).ObjectGUID.Guid

$groupContractors = "IT Dept - Contractors-12069377504"
$groupContractorsGUID = (Get-ADGroup -Identity $groupContractors).ObjectGUID.Guid
$groupEmployees = "IT Dept - Employees-1104001912"
$groupEmployeesGUID = (Get-ADGroup -Identity $groupEmployees).ObjectGUID.Guid

# For each department code, make sure all users in that department have been added to the proper child DL for the parent "IT Dept - All" DL
foreach ($departmentCode in $departmentCodes)
{
	$users = get-aduser -filter {(extensionAttribute8 -eq $departmentCode) -and (enabled -eq $true)} -Properties extensionAttribute4
	foreach ($user in $users)
	{
		$GUID = ''
		$GUID = $user.ObjectGUID.Guid
		if ($itUsers -notcontains $GUID)
		{
			$ext4 = ''
			$ext4 = $user.extensionAttribute4
			if (($ext4 -like "FTE*") -or ($ext4 -like "PTE*"))
			{
				Add-ADGroupMember -Identity $groupEmployeesGUID -Members $GUID -Confirm:$false
			}
			else
			{
				Add-ADGroupMember -Identity $groupContractorsGUID -Members $GUID -Confirm:$false
			}
		}
	}
}

## Verify contractors group, and promote to employees group, if applicable
$itContractors = get-adgroupmember $groupContractors -Recursive
# $itEmployees = get-adgroupmember $groupEmployees -Recursive

# Get details for each member of the contractors DL
foreach ($itContractor in $itContractors)
{
	$GUID = ''
	$GUID = $user.objectGUID.GUID
	$ad = ''
	$ad = Get-ADUser $GUID -properties name,enabled,title,physicalDeliveryOfficeName,company,department,manager,whenChanged,description,employeeNumber,extensionAttribute4,extensionAttribute8 #-Server "ZCDDNDC01.ddnnet.com"
	$ext4 = ''
	$ext4 = $ad.extensionAttribute4
	if (($ext4 -like "FTE*") -or ($ext4 -like "PTE*"))
	{
		Add-ADGroupMember -Identity $groupEmployeesGUID -Members $GUID -Confirm:$false
		Remove-ADGroupMember -Identity $groupContractorsGUID -Members $GUID -Confirm:$false
	}
}