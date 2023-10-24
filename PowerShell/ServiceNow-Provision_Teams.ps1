<#

		Program Name: ServiceNow_Provision_Teams.ps1
		Date Written: January 9th, 2023
		  Written By: Dave Jaynes
		 Description: Pull All Open Tasks to Provision Teams from ServiceNow to Create New Microsoft Teams
#>

# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Step 2: Create credentials.
# Teams Admin Service Account
$TeamsUserName = Get-Content "C:\PowerShell\credentials\TeamsUserName.txt"
$TeamsPassword = Get-Content "C:\PowerShell\credentials\TeamsPassword.txt" | ConvertTo-SecureString
$teamsCredential = New-Object System.Management.Automation.PSCredential($TeamsUserName,$TeamsPassword)

# Notification Email Account
$AzureAutomationUserName = Get-Content "C:\PowerShell\credentials\AzureAutomationUserName.txt"
$AzureAutomationPassword = Get-Content "c:\powershell\credentials\AzureAutomationPassword.txt" | ConvertTo-SecureString
$SmtpCredential = New-Object System.Management.Automation.PSCredential($AzureAutomationUserName,$AzureAutomationPassword)

# ServiceNow API Account
$ServiceNowAPIUserName = Get-Content "C:\PowerShell\credentials\ServiceNowAPIUserName.txt"
$ServiceNowAPIPassword = Get-Content "C:\PowerShell\credentials\ServiceNowAPIPassword.txt" | ConvertTo-SecureString
$apiCredential = New-Object System.Management.Automation.PSCredential($ServiceNowAPIUserName,$ServiceNowAPIPassword)

# Step 3: Set variables
$recipients = "dave.jaynes@eversana.com"
$assignee = 'e915a30c1b1fccd00203eb1cad4bcb28'
$instance = "eversana"

# Step 4: Set up the Service-Now API Connector Credentials.
$method = "GET"
$user = $apiCredential.UserName
$pass = $apiCredential.GetNetworkCredential().Password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')

# Step 5: Pull all the New Collaboration Site requests that are not in review status and have a state value of 1 or 2.
#$scTasksURI = "https://$instance.service-now.com/api/now/table/sc_task?sysparm_query=short_descriptionLIKENew%20Collaboration%20Site%20Request"
$scTasksURI = "https://$instance.service-now.com/api/now/table/sc_task?sysparm_query=short_descriptionLIKENew%20Collaboration%20Site%20Request%5Eshort_descriptionLIKETeam%5Eshort_descriptionNOT%20LIKEReview%5EstateIN1%2C2"
	
$scTasks = (Invoke-RestMethod -Headers $headers -Method $method -Uri $scTasksURI).result

# Step 6: Pull all data related to open task details & provision teams.
Write-Host "scTasks = [$($scTasks.count)]"
if ($($scTasks.count) -gt 0)
{
    #Connect to Microsoft Teams
    Connect-MicrosoftTeams -Credential $teamsCredential

    foreach ($sctask in $scTasks) 
    {
		$sctask
            $requestItem = ''
            $requestItem = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scTask.request_item.link)).result

            #$request = ''
            #$request = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($requestItem.request.link)).result

            #Get Dependent Items from sc_item_option_mtom
            $variableOwnershipURI = "https://$instance.service-now.com/api/now/table/sc_item_option_mtom?sysparm_query=request_item.number%3D" + $requestItem.number
            $variables = (Invoke-RestMethod -Headers $headers -Method $method -Uri $variableOwnershipURI).result

            #Clear Previous Variables
                $teamName = ''
                $primaryOwnerSysID = ''
                $secondaryOwnerSysID = ''
                $initialMembersSysID = ''
                $externalGuests = ''

            #Gather Current Variables

            foreach ($variable in $variables) 
            {
                $scItemOption = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($variable.sc_item_option.link)).result
                $itemOptionNew = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scItemOption.item_option_new.link)).result
                if ($itemOptionNew.name -eq "approved_name_of_team_site") 
                {
                    $teamName = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "primary_owner") 
                {
                    $primaryOwnerSysID = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "secondary_owner") 
                {
                    $secondaryOwnerSysID = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "initial_members") 
                {
                    $initialMembersSysID = $scItemOption.value
                }
                elseif ($itemOptionNew.name -eq "external_guests")
                {
                    $externalGuests = $scItemOption.value
                }
            }

            $primaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $primaryOwnerSysID
            $primaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $primaryOwnerURI).result.user_name

            $secondaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $secondaryOwnerSysID
            $secondaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $secondaryOwnerURI).result.user_name
    
            #Used to collect members' usernames
            $members = @()
            #Split string into an array
            $initialMembersSysID = $initialMembersSysID.Split(",")

                foreach ($initialMemberSysID in $initialMembersSysID) 
                {
                    $memberURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $initialMemberSysID
                    $member = (Invoke-RestMethod -Headers $headers -Method $method -Uri $memberURI).result.user_name
                    $members += $member
                }

                
            ### Provision the team & throw an alert if an error is encountered
            Try
            {
				Write-Host "New-Team -DisplayName $teamName -Visibility Private"
                #$newTeam = New-Team -DisplayName $teamName -Visibility Private
                Start-Sleep -Seconds 30
    
                $ID = ''
                $ID = $newTeam.groupId
                $ID
    
                Start-Sleep -Seconds 15
                #Add Members to Team
                foreach ($member in $members)
                {
                    #$member
					Write-Host "Add-TeamUser -GroupId $ID -User $member -Role Member"
                    #Add-TeamUser -GroupId $ID -User $member -Role Member
                    Start-Sleep -Seconds 3
                }
    
                #Add Primary Owner
				Write-Host "Add-TeamUser -GroupId $ID -user $primaryOwner -Role Owner"
                #Add-TeamUser -GroupId $ID -user $primaryOwner -Role Owner
    
                #Add Secondary Owner
				Write-Host "Add-TeamUser -GroupId $ID -user $secondaryOwner -Role Owner"
                #Add-TeamUser -GroupId $ID -user $secondaryOwner -Role Owner

             ### Close the sc_task
                if ($(Get-Team -DisplayName $teamName) -ne $null)
                {
                    # Specify endpoint uri
                    $scTaskSysID = $scTask.sys_id
                    $uri = "https://$instance.service-now.com/api/now/table/sc_task/$scTaskSysID"

                    # Specify HTTP method
                    $methodPUT = "put"

                    # Specify request body
                    $body = '{"assigned_to":"'+$assignee+'","state":"3"}'

                    # Send HTTP request
					Write-Host "Invoke-RestMethod -Headers $headers -Method $methodPUT -Uri $uri -Body $body"
                    #Invoke-RestMethod -Headers $headers -Method $methodPUT -Uri $uri -Body $body
                }
            }
            Catch
            {
				$A = 0
			}
<#
                $From = 'azureautomation@eversana.com'
                $SmtpServer = 'smtp.office365.com'
                $SmtpPort = 587
                [string[]]$to = $recipients.Split(',')

                $scTaskNumber = ''
                $scTaskNumber = $scTask.number
                $Subject = "Automation Error Experienced Provisioning Team: $teamName"
                $Body = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                    An error was encountered provisioning the following team.<br/>
                    <br/>
                        <ul>
                            <li>Catalog Task: $scTaskNumber</li>
                            <li>Team Name: $teamName</li>
                            <li>Primary Owner: $primaryOwner</li>
                            <li>Secondary Owner: $secondaryOwner</li>
                            <li>Members: $members</li>
                        </ul>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@


                Send-MailMessage `
                    -From $From `
                    -UseSsl `
                    -SmtpServer $SmtpServer `
                    -Port $SmtpPort `
                    -To $To `
                    -Subject $Subject `
                    -Body $Body `
                    -BodyAsHtml `
                    -credential $SmtpCredential

            }

            #Notify if external guests need to be invited for the team
            if ($externalGuests -ne '')
            {
                $From = 'azureautomation@eversana.com'
                $SmtpServer = 'smtp.office365.com'
                $SmtpPort = 587
                [string[]]$to = $recipients.Split(',')

                $scTaskNumber = ''
                $scTaskNumber = $scTask.number
                $SubjectGuests = "Please Invite Guests for Team: $teamName"
                $BodyGuests = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                    Please invite guest users for the following team.<br/>
                    <br/>
                        <ul>
                            <li>Catalog Task: $scTaskNumber</li>
                            <li>Team Name: $teamName</li>
                            <li>Primary Owner: $primaryOwner</li>
                            <li>Secondary Owner: $secondaryOwner</li>
                            <li>Members: $members</li>
                            <li>Guests: $externalGuests</li>
                        </ul>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@

                Send-MailMessage `
                    -From $From `
                    -UseSsl `
                    -SmtpServer $SmtpServer `
                    -Port $SmtpPort `
                    -To $To `
                    -Subject $SubjectGuests `
                    -Body $BodyGuests `
                    -BodyAsHtml `
                    -credential $SmtpCredential
            }
#>
    }

    #Disconnect from Microsoft Teams
    Disconnect-MicrosoftTeams
}

