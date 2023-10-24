#Original Author: Gregory Warner
#Last Modified: 2021-03-08
#Summary: Update "LeanIX_Viewers" AD Security Group

# Declare an array of all IT department codes
$departmentCodes = @("119990","150000","151000","152000","153000","153100","153200","153250","405000","409000","601000","602000","606990")

# Get current members of the parent "LeanIX_Viewers" Security Group
$group = "LeanIX_Viewers"
$itUsers = (get-adgroupmember $group -Recursive).ObjectGUID.Guid

$groupLeanIX_Viewers = "LeanIX_Viewers"
$groupEmployeesGUID = (Get-ADGroup -Identity $groupLeanIX_Viewers).ObjectGUID.Guid

# For each department code, make sure all users in that department have been added to the proper child DL for the parent "LeanIX_Viewers" Security Group
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
                                Add-ADGroupMember -Identity $groupLeanIX_Viewers -Members $GUID -Confirm:$false
                            }
                    }
            }
    }