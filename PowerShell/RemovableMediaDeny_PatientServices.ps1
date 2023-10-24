#$users = Get-ADUser -filter {samaccountname -eq "chris.matute"}
$users = Get-ADUser -filter {company -eq "Patient Services"}
$users = $users | ? {$_.distinguishedname -notlike "*disabled*"}

$exgroupname = "RemovableMedia_Exceptions"
$exusers = Get-ADGroupMember $exgroupname | select samaccountname

$users | foreach {
    $sam = $_.samaccountname
    $flag = $false
    $exusers | foreach {
        if($sam -eq $_.samaccountname){$flag = $true}    
    }
    if(!$flag){
        Add-ADGroupMember -Identity "RemovableMedia_Deny" -Members $_ -verbose #-WhatIf
        }
}
