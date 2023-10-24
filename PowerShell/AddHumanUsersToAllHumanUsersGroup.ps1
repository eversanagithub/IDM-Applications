#Author: Chris Matute
#Last Modified: 05/09/2022
#Summary: Adds all humans to the AllHumanUsers security group

$users = get-aduser -filter {Enabled -eq $true -and (ExtensionAttribute4 -like "*|*" -or ExtensionAttribute4 -eq "human")} -Properties ExtensionAttribute4

$groupName = "AllHumanUsers"

$groupMembers = (Get-ADGroup $groupName -Properties members).members

<#
$users | ? {$_.SamAccountName -eq "chris.matute" -or `
            $_.SamAccountName -eq "will.conner" -or `
            $_.SamAccountName -eq "greg.warner"} | % {
#>

$users | % {
    
    $flag = $false
    
    $dName = $_.distinguishedname
	   
    $groupMembers | % { if($_ -eq $dName){ $flag = $true } }
    
    if(!$flag){ add-adgroupmember $groupName -members $_ -verbose}
}


<#

$groupName = "ExternalSenderTag"

$groupMembers = (Get-ADGroup $groupName -Properties members).members

$users | ? {$_.enabled -eq $true} | % {
    
    $flag = $false
    
    $dName = $_.distinguishedname
	   
    $groupMembers | % { if($_ -eq $dName){ $flag = $true } }
    
    if(!$flag){ add-adgroupmember $groupName -members $_ -verbose}
}

#>

$groupName = "humanusers-dl" 

$groupMembers = (get-adgroup -filter {DisplayName -eq $groupName} -Properties members).members

$users | % {
    
    $flag = $false
    
    $dName = $_.distinguishedname
	   
    $groupMembers | % { if($_ -eq $dName){ $flag = $true } }
    
    if(!$flag){ add-adgroupmember (get-adgroup -filter {DisplayName -eq $groupName}) -members $_ -verbose}
}