#Author: Dave Jaynes
#Last Modified: 9/3/2021
#Summary: Display COntoso users

# Define path and remove old file
$Path = "C:\PowerShell\TeamsReport\TeamsReport.csv"
Remove-Item $Path -Force

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

<# Display add all normal users 
foreach ($user in $users)
    {
        $user
    }
#>	
	
foreach ($user in $users)
{
	if ($user.Enabled -eq 'True')
	{
		$user| Export-Csv $Path -NoTypeInformation -Append -Force
	}
}

<#
# Display any admin users 
foreach ($adminUser in $adminUsers)
{
	if ($adminUser.Enabled -eq 'True')
	{
		$adminUser
	}
}
#>