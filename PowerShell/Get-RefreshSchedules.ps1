#Author: Gregory Warner
#Last Modified: 8/26/20
#Summary: Get Refresh Schedules for Power BI Reports with Powershell 7

# Install the MicrosoftPowerBIMgmt module first
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Designate path to second script that requires Powershell 5
$scriptPath = 'C:\PowerShell\PowerBI\Set-RefreshSchedules.ps1'
$exportFilepath = 'C:\PowerShell\PowerBI\RefreshSchedules.csv'

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "dave.jaynes@eversana.com"
[string[]]$to = $recipients.Split(',')

$powerBIUser = "srv_PowerBI@eversana.com"
$powerBIPass = Get-Content "C:\PowerShell\PowerBI\srv_PowerBI.txt" | ConvertTo-SecureString
$powerBICredential = New-Object System.Management.Automation.PSCredential($powerBIUser,$powerBIPass)
Connect-PowerBIServiceAccount -Credential $powerBICredential

$workspaces = Get-PowerBIWorkspace -Scope Organization -All | Where-Object {($_.Name -notlike "PersonalWorkspace*") -and ($_.Type -eq "Workspace")}

# Declare array to capture all workspace reports
$all = @()

try 
    {
        foreach ($workspace in $workspaces)
            {
                $reports = Get-PowerBIReport -Scope Organization -Workspace $workspace
                $datasets = Get-PowerBIDataSet -Scope Organization -Workspace $workspace
                if ($datasets.count -gt 0)
                    {
                        foreach ($dataset in $datasets)
                            {
                                $workspaceID = ''
                                $workspaceID = $workspace.Id.Guid
                                $datasetID = ''
                                $datasetID = $dataset.Id.Guid

                                $record = New-Object PSObject -property @{ 
                                    Workspace = $workspace.Name
                                    WorkspaceID = $workspace.Id.Guid
                                    DatasetName = $dataset.Name
                                    DatasetID = $dataset.Id.Guid
                                    ConfiguredBy = $dataset.ConfiguredBy
                                    RelatedReports = $(($reports | Where-Object {$_.DatasetID -eq $dataset.Id.Guid} | Select-Object -Unique $_).Name -join ",")
                                    Date = (Get-Date -Format yyyy-MM-dd)
                                }

                            if (($workspaceID -ne $null) -and ($workspaceID -ne '') -and ($datasetID -ne $null) -and ($datasetID -ne ''))
                                {
                                    $uri = ''
                                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceID/datasets/$datasetID/refreshSchedule"
                                    try
                                        {
                                            $results = ''
                                            $results = Invoke-PowerBIRestMethod -Method Get -Url $uri | ConvertFrom-Json
                                        }
                                    catch
                                        {
                                            $results = ''
                                        }
                                }
                            else
                                {
                                    $results = ''
                                }

                            if (($results -ne $null) -and ($results -ne ''))
                                {
                                    $days = $($results.days -join ",")
                                    $times = $($results.times -join ",")
                                    $enabled = $($results.enabled)
                                    $localTimeZoneId = $($results.localTimeZoneId)
                                    $notifyOption = $($results.notifyOption)
                                    $record | Add-Member -NotePropertyName "Days" -NotePropertyValue $days
                                    $record | Add-Member -NotePropertyName "Times" -NotePropertyValue $times
                                    $record | Add-Member -NotePropertyName "Enabled" -NotePropertyValue $enabled
                                    $record | Add-Member -NotePropertyName "LocalTimeZoneID" -NotePropertyValue $localTimeZoneId
                                    $record | Add-Member -NotePropertyName "NotifyOption" -NotePropertyValue $notifyOption
                                }

                                $all += $record
                            }
                        Write-Host "Found Datasets:"$($workspace.Name)
                        Start-Sleep -Seconds 10
                    }
                else
                    {
                        Write-Host "No Datasets:"$($workspace.Name)
                        Start-Sleep -Seconds 3
                    }
            }

        if(Test-Path $exportFilepath)
            {
                Clear-Content $exportFilepath
            }

        $all | Export-Csv -NoTypeInformation $exportFilepath
        Start-Sleep -Seconds 7

        powershell.exe $scriptPath

        Disconnect-PowerBIServiceAccount
    }
catch
    {
        # SMTP Details for Notifications
        $from = 'srv_PowerBI@eversana.com'
        $smtpServer = 'smtp.office365.com'
        $smtpPort = 587
        $subject = "Error Adding srv_PowerBI to Workspace from DCOBUTIL01"
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
                The "Get-RefreshSchedules" script on DCOBUTIL01 has encountered an error. Please investigate and respond accordingly.<br/>
                <br/>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@
        Send-MailMessage `
            -From $from `
            -To $to `
            -Subject $subject `
            -Body $body `
            -BodyAsHtml `
            -UseSsl `
            -SmtpServer $SmtpServer `
            -Port $SmtpPort `
            -credential $powerBICredential
    }