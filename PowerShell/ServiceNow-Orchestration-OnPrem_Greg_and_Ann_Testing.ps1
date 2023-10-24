#Author: Gregory Warner
#Last Modified: 11/6/20
#Summary: Connects to Azure Table to Complete Work Requested by ServiceNow

# Read-Host -Prompt "Enter your password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\PowerShell\ServiceNow-Orchestration-OnPrem\Srv_Orchestration.txt"
# Read-Host -Prompt "Enter your password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\PowerShell\ServiceNow-Orchestration-OnPrem\AzureAutomation.txt"
# GET-CREDENTIAL –Credential (Get-Credential) | EXPORT-CLIXML "C:\PowerShell\ServiceNow-Orchestration-OnPrem\ServiceNow_Powershell.xml"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$azureUser = "Srv_Orchestration@eversana.com" # Password is: hx!En5)&Fatq
$azurePass = Get-Content "C:\PowerShell\ServiceNow-Orchestration-OnPrem\Srv_Orchestration_Dave.txt" | ConvertTo-SecureString
$azureCredential = New-Object System.Management.Automation.PSCredential($azureUser,$azurePass)
Connect-AzAccount -Credential $azureCredential

# Designate variables for use with Azure Storage table for recordkeeping
$resourceGroupName = "esa-prod-auto-rg"
$storageAccountName = "prodautostorage"
$tableName = "OnPremOrchestration"
# $accessKey = Get-AutomationVariable -Name 'OneDriveStorageAccountAccessKey'
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$table = (Get-AzStorageTable -Context $storageAccount.context -Name $tableName).CloudTable

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "dave.jaynes@eversana.com,Abdul.Wahid@Eversana.com,Ann.Becker@Eversana.com"
[string[]]$to = $recipients.Split(',')

<#
Table fields
------------
Processed      : true
Valid          : true
requestItem    : RITM0025067
source         : eversana
sysID          : 68fcf0b31bb26c90670d0e1dcd4bcbd9
PartitionKey   : Mobile Device Access Request
RowKey         : f93f853f-5d03-4a61-a436-d617c412d9d8
TableTimestamp : 3/16/2021 11:20:11 AM -05:00
Etag           : W/"datetime'2021-03-16T16%3A20%3A11.1797412Z'"
#>

# $jobs = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true' and Processed eq 'false'"
Get-AzTableRow -table $table
exit
<#

foreach(job in jobs)
{
	
}
# Begin the process
if ($jobs)
    {
        # SMTP Details for Notifications
        $smtpUser = "AzureAutomation@eversana.com"
        $smtpPass = Get-Content "C:\PowerShell\ServiceNow-Orchestration-OnPrem\AzureAutomation.txt" | ConvertTo-SecureString
        $smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser,$smtpPass)
        $fromError = 'AzureAutomation@eversana.com'
        $smtpServer = 'smtp.office365.com'
        $smtpPort = 587

        ### Build auth header & Request for ServiceNow API
        #Specify ServiceAccount and Password
        $servicenowCredentials = Import-Clixml "C:\PowerShell\ServiceNow-Orchestration-OnPrem\ServiceNow_Powershell.xml"
        $servicenowUser = $servicenowCredentials.UserName
        $servicenowPass = $servicenowCredentials.GetNetworkCredential().Password
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $servicenowUser,$servicenowPass)))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/json')


        foreach ($job in $jobs)
            {
                Try
                    {
                        # Identify instance
                        $instance = ''
                        $instance = $job.source
                        $requestItem = ''
                        $requestItem = $job.requestItem
                        $catalogTask = ''
                        $catalogTask = $job.PartitionKey
                        $sysID = ''
                        $sysID = $job.sysID

                        $uriGet = ''
                        $uriGet = "https://$instance.service-now.com/api/now/table/u_stage_sc_request?sysparm_query=sys_id%3D$sysID"

                        $record = ''
                        $record = (Invoke-RestMethod -Headers $headers -Method Get -Uri $uriGet).result
            
                        # Trigger appropriate script or action based on catalogTask name
                        Switch ($catalogTask)
                            {
                               'Mobile Device Access Request'
                                    {
                                        # Get the variables
                                        $variables = ''
                                        $variables = ($record.u_variables).split("|")
                                        # User variable
                                        $variable1 = $variables[0]

                                        # Group to add user
                                        $groupGUID = "e9f6eb0e-2a50-4f2c-910b-982641274b20"
                                        $groupName = "Office365_Intune_AttestationComplete"

                                        # Get user details
                                        $userGUID = ''
                                        $userGUID = (Get-ADUser -filter {userPrincipalName -eq $variable1}).ObjectGUID.GUID

                                        if (($userGUID -eq $null) -or ($userGUID -eq ''))
                                            {
                                                $userGUID = (Get-ADUser -filter {mail -eq $variable1}).ObjectGUID.GUID
                                            }

                                        # Do the actions
                                        Write-Host "Adding $variable1 to group $groupName"
                                        Write-Host "Adding $userGUID to group $groupName"
                                        
                                        if ($(Get-ADGroup $groupGUID))
                                            {
                                                Add-ADGroupMember -Identity $groupGUID -Members $userGUID -Confirm:$false
                                            }
                                        else
                                            {
                                                $groupGUID = (Get-ADGroup $groupName).ObjectGUID.GUID
                                                Add-ADGroupMember -Identity $groupGUID -Members $userGUID -Confirm:$false
                                            }

                                        # Get current processed date
                                        $date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

                                        # Update Azure storage table
                                        $job.Processed = 'true'
                                        $job | Update-AzTableRow -table $table

                                        # Specify request body
                                        $bodyJSON = '{"u_return_code":"200","u_processed":"'+$date+'"}'

                                        # Send HTTP request
                                        $uriPut = ''
                                        $uriPut = "https://$instance.service-now.com/api/now/table/u_stage_sc_request/$sysID" 
                                        Invoke-RestMethod -Headers $headers -Method Put -Uri $uriPut -Body $bodyJSON
                                    }
                                Default
                                    {
                                        $subject = "Unknown OnPrem Task Encountered: " + $catalogTask
                                        $body = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://team.eversana.com/wp-content/uploads/2019/10/EmailHeader-IT-Service-Desk.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                The "ServiceNow-Orchestration-OnPrem" script has encountered a catalog item with no processing instructions. Please investigate and respond accordingly.<br/>
                <br/>
                <hr>
                <b>Catalog Item Details</b><br/>
                    Request Item: $requestItem<br/>
                    Catalog Task: $catalogTask<br/>
                    SysID: $sysID<br/>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@
                                        Send-MailMessage `
                                            -From $fromError `
                                            -To $to `
                                            -Subject $subject `
                                            -Body $body `
                                            -BodyAsHtml `
                                            -UseSsl `
                                            -SmtpServer $SmtpServer `
                                            -Port $SmtpPort `
                                            -credential $SmtpCredential

                                        # Update Azure storage table
                                        $job.Processed = 'error'
                                        $job | Update-AzTableRow -table $table

                                        # Terminate the script
                                        Exit
                                    }
                            }
                    }
                Catch
                    {
                        $subject = "Error Experienced Processing OnPrem Orchestration For: " + $requestItem + "-" + $catalogTask
                        $body = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://team.eversana.com/wp-content/uploads/2019/10/EmailHeader-IT-Service-Desk.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                An error has been experienced processing OnPrem Orchestation from ServiceNow. Please investigate and respond accordingly.<br/>
                <br/>
                <hr>
                <b>Catalog Item Details</b><br/>
                    Request Item: $requestItem<br/>
                    Catalog Task: $catalogTask<br/>
                    SysID: $sysID<br/>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@
                        Send-MailMessage `
                            -From $fromError `
                            -To $to `
                            -Subject $subject `
                            -Body $body `
                            -BodyAsHtml `
                            -UseSsl `
                            -SmtpServer $SmtpServer `
                            -Port $SmtpPort `
                            -credential $SmtpCredential

                        # Update Azure storage table
                        $job.Processed = 'error'
                        $job | Update-AzTableRow -table $table
                    }
            }
    }
#>
Disconnect-AzAccount