#Author: Jayson Chin
#Last Modified: 02/15/2021
#Summary: Copy all members of a group to another group, if they are not already members

$sourceGroups = @("ENGAGE Saratoga Springs-11221972164","ENGAGE Berkeley Heights-1473291923","ENGAGE La Jolla-1321552986")
$destinationGroup = "SSNY-PEP_STORAGE"

foreach ($sourceGroup in $sourceGroups)
{
        $sourceUsers = get-adgroupmember $sourceGroup -Recursive #-server "DCOBDC01.universal.com"
        $destinationUsers = (get-adgroupmember $destinationGroup -Recursive).objectGUID.GUID #-server "DCOBDC01.universal.com"

        Write-Host "Checking $sourceGroup for users to add..."

        foreach ($user in $sourceUsers)
            {
                   if ($destinationUsers -notcontains $($user.ObjectGUID.GUID))
                {
                    Add-ADGroupMember -Identity $destinationGroup -Members $($user.ObjectGUID.GUID)
                    Write-Host "Added user:"$($user.Name)
                }
        }
}