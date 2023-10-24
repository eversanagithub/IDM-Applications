# Author: Joe Chuzie
# Last Modified: 3/6/23
# Summary: Adds device objects in zAutopilotTest and Imaging OUs to AD group wireless_computers_global, which enables connectivity to EVERSANA SSID.

# Set target OUs and group GUIDs
$AutopilotOuId = "130aa9cc-92ee-4c8e-b1f8-beb51b268c66"
$ImagingOuId = "d8cda1fa-1a0f-42c4-9f4e-81d7b2fddda8"
$WirelessGroupId = "dc80fee9-cdb1-49e9-9cdf-d170452285cd"

# Get the target OUs and group
$AutopilotOu = Get-ADOrganizationalUnit -Filter {ObjectGUID -eq $AutopilotOuId}
$ImagingOu = Get-ADOrganizationalUnit -Filter {ObjectGUID -eq $ImagingOuId}
$WirelessGroup = Get-ADGroup -Identity $WirelessGroupId

# Get computer objects from each OU and add them to the group
$AutopilotOuComputers = Get-ADComputer -SearchBase $AutopilotOu.DistinguishedName -Filter *
$ImagingOuComputers = Get-ADComputer -SearchBase $ImagingOu.DistinguishedName -Filter *
foreach ($computer in $AutopilotOuComputers) {
    Add-ADGroupMember -Identity $WirelessGroup -Members $computer
    Write-Output "Added computer $($computer.Name) to group $($WirelessGroup.Name)"
}
foreach ($computer in $ImagingOuComputers) {
    Add-ADGroupMember -Identity $WirelessGroup -Members $computer
    Write-Output "Added computer $($computer.Name) to group $($WirelessGroup.Name)"
}

Write-Output "Script execution completed successfully."



###UTILITY###
#These were used to initially acquire the GUIDs of all targets, so if names ever change workflow is not impacted.
#
## Specify the Distinguished Names (DNs) of the two OUs you want to add computers from
# $ou1DN = "OU=zAutopilotTest,OU=Users and Workstations,DC=Universal,DC=co"
# $ou2DN = "OU=Imaging,DC=Universal,DC=co"
# Specify the DN of the target AD group
# $groupDN = "CN=Wireless_Computers_Global,OU=Global,OU=Security,OU=Groups,DC=Universal,DC=co"
#
## Get the object IDs of the two OUs
# $ou1ID = (Get-ADOrganizationalUnit -Identity $ou1DN).ObjectGUID
# $ou2ID = (Get-ADOrganizationalUnit -Identity $ou2DN).ObjectGUID
# Get the object ID of the target group
# $groupID = (Get-ADGroup -Identity $groupDN).ObjectGUID
##
# 'zAutopilotTest' AD OU GUID = '130aa9cc-92ee-4c8e-b1f8-beb51b268c66'
# 'Imaging' AD OU GUID = 'd8cda1fa-1a0f-42c4-9f4e-81d7b2fddda8'
# 'wireless_computers_global' AD group GUID = 'dc80fee9-cdb1-49e9-9cdf-d170452285cd'