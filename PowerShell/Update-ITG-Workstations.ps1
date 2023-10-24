#Author: Jayson Chin
#Modified: 05-25-2022
#Purpose: To autopopulate ITG-Workstations AD Group with members from ITG Workstations OU

$OU="OU=Workstations,OU=ITG,OU=Users and Workstations,DC=Universal,DC=co"

$ShadowGroup="CN=ITG-Workstations,OU=Global,OU=Security,OU=Groups,DC=Universal,DC=co"

Get-ADGroupMember –Identity $ShadowGroup | Where-Object {$_.distinguishedName –NotMatch $OU} | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}

Get-ADComputer –SearchBase $OU –SearchScope OneLevel –LDAPFilter "(!memberOf=$ShadowGroup)" | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup}