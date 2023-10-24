#Author: Justin Noggle & Gregory Warner
#Last Modified: 9/16/20
#Summary: Update "ContosoLab" Distribution List with All Current Users

$groups = @(
    "DCCECITUSRDS Users_Global",
    "DCCECSRDS MC Users_Global",
    "DCCECSRDS PV Users_Global",
    "DCCECSWRRDS Users_Global",
    "DCCEDBARDS Users_Global",
    "DCCEDELRDS Users_Global",
    "DCCEDEVRDS Users_Global",
    "DCCEHEORRDS Users_Global",
    "DCCEITRDS Users_Global",
    "DCCEMMARDS Users_Global",
    "DCCEPDRRDS Users_Global",
    "DCCEPUINDBARDS Users_Global",
    "DCCEPUINRDS Users_Global",
    "DCCERPARDS Users_Global",
    "DCCESQARDS Users_Global",
    "DCCEWFHRDS Users_Global",
    "DCOBCONRDS Users_Global",
    "DCOBDATEXRDS Users_Global",
    "DCOBFSRDS Users_Global",
    "DCOBHSIRDS Users_Global",
    "DCOBPUINFINRDS Users_Global",
    "DCOBWFHRDS Users_Global",
    "DCCEAPIRDS Users_Global")

$target = "EVERSANA RDS Users-11936881221"

foreach ($group in $groups)
    {
        $targetMembers = (Get-ADGroupMember $target).objectGUID.GUID
        $sourceMembers = (Get-ADGroupMember $group -Recursive | Where-Object {($_.SamAccountName -notlike "a_*") -and ($_.SamAccountName -notlike "d_*")}).objectGUID.GUID

        Write-Host "Checking $group for users to add..."

        foreach ($sourceMember in $sourceMembers)
            {
                if ($targetMembers -notcontains $sourceMember)
                    {
                        Add-ADGroupMember -Identity $target -Members $sourceMember -Confirm:$false
                    }
            }
    }