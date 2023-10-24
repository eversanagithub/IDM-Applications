#Author: Gregory Warner
#Last Modified: 9/16/20
#Summary: Update "ContosoLab" Distribution List with All Current Users

# Read-Host -Prompt "Enter your password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\PowerShell\Update-ContosoLab\srv_ContosoEversana.txt"

# Get current members of the parent "IT Dept - All" DL
$group = "ContosoLab-1-394779065"
$groupGUID = (Get-ADGroup -Identity $group).ObjectGUID.Guid
$groupUsers = (get-adgroupmember $group -Recursive).ObjectGUID.Guid

# Credentials for service account on the Contoso.Zone domain
$username = "CONTOSO\srv_ContosoEversana"
$password = Get-Content "C:\PowerShell\Update-ContosoLab\srv_ContosoEversana.txt" | ConvertTo-SecureString
$CompName = "condc01.contoso.zone"
$credentials = New-Object System.Management.Automation.PSCredential($username, $password)

# Create remote session to the Contoso.Zone domain controller
$s = New-PSSession -Credential $credentials -ComputerName $CompName
    # Pull normal users from Contoso.Zone domain
    $users = Invoke-Command -Session $s -ScriptBlock {get-aduser -SearchBase "OU=Users,OU=Users and Workstations,DC=contoso,DC=zone" -filter {enabled -eq $true} -Properties extensionAttribute5}
    # Pull admin users from Contoso.Zone domain
    $adminUsers = Invoke-Command -Session $s -ScriptBlock {get-aduser -SearchBase "OU=Admins,DC=contoso,DC=zone" -filter {enabled -eq $true} -Properties extensionAttribute5}
#Close remote session to the Contoso.Zone domain controller
Remove-PSSession $s

# Add all normal users to the ContosoLab@eversana.com DL
foreach ($user in $users)
    {
        if (($user.extensionAttribute5 -ne $null) -and ($user.extensionAttribute5 -ne ''))
            {
                $UPN = ''
                $UPN = $user.extensionAttribute5
                $universalUser = ''
                $universalUser = get-aduser -filter {UserPrincipalName -eq $UPN}
                if (($universalUser -ne $null) -and ($universalUser -ne ''))
                    {
                        $GUID = ''
                        $GUID = $universalUser.ObjectGUID.GUID
                        if ($groupUsers -notcontains $GUID)
                            {
                                Add-ADGroupMember -Identity $groupGUID -Members $GUID -Confirm:$false
                            }
                    }
            }
        else
            {
                $SAM = ''
                $SAM = $(($user.UserPrincipalName).Split("@"))[0]
                $universalUser = ''
                $universalUser = get-aduser -filter {SAMAccountName -eq $SAM}
                if (($universalUser -ne $null) -and ($universalUser -ne ''))
                    {
                        $GUID = ''
                        $GUID = $universalUser.ObjectGUID.GUID
                        if ($groupUsers -notcontains $GUID)
                            {
                                Add-ADGroupMember -Identity $groupGUID -Members $GUID -Confirm:$false
                            }
                    }
            }
    }

# Add any admin users if they are mapped to an Eversana address and not already a member to the ContosoLab@eversana.com DL
foreach ($adminUser in $adminUsers)
    {
        if (($adminUser.extensionAttribute5 -ne $null) -and ($adminUser.extensionAttribute5 -ne ''))
            {
                $UPN = ''
                $UPN = $adminUser.extensionAttribute5
                $universalUser = ''
                $universalUser = get-aduser -filter {UserPrincipalName -eq $UPN}
                if (($universalUser -ne $null) -and ($universalUser -ne ''))
                    {
                        $GUID = ''
                        $GUID = $universalUser.ObjectGUID.GUID
                        if ($groupUsers -notcontains $GUID)
                            {
                                Add-ADGroupMember -Identity $groupGUID -Members $GUID -Confirm:$false
                            }
                    }
            }
    }