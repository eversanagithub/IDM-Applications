#Author: Jayson Chin
#Modified: 06-03-2022
#Purpose: To autopopulate IntouchGroup AD Group with members from ITG People OU

$OU="OU=People,OU=ITG,OU=Users and Workstations,DC=Universal,DC=co"

$ShadowGroup="CN=IntouchGroup,OU=Distribution,OU=Groups,DC=Universal,DC=co"

Get-ADGroupMember –Identity $ShadowGroup | Where-Object {$_.distinguishedName –NotMatch $OU} | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}

Get-ADUser –SearchBase $OU –SearchScope OneLevel –LDAPFilter "(!memberOf=$ShadowGroup)" | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup}