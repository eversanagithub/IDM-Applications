﻿<#
		Program Name: Update-CSR_DFS_BUON_AllUsers_Global.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Copy all members of a group to another group, if they are not already members. 
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$sourceGroup = "Value & Evidence - Global Team-11018853931"
$destinationGroup = "DFS_BUON_AllUsers_Global"
$sourceUsers = get-adgroupmember $sourceGroup -Recursive #-server "DCOBDC01.universal.com"
$destinationUsers = (get-adgroupmember $destinationGroup -Recursive).objectGUID.GUID #-server "DCOBDC01.universal.com"

foreach ($user in $sourceUsers)
{
	if ($destinationUsers -notcontains $($user.ObjectGUID.GUID))
	{
		Add-ADGroupMember -Identity $destinationGroup -Members $($user.ObjectGUID.GUID)
	}
}