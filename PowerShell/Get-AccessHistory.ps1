#Author: Dave Jaynes
#Last Modified: 01/15/22
#Summary: Get Access History from the Power BI REST API

# Install the MicrosoftPowerBIMgmt module first

# Designate path to second script that requires Powershell 5
$scriptPath = 'C:\PowerShell\PowerBI\Set-AccessHistory.ps1'
$exportFilepath = 'C:\PowerShell\PowerBI\AccessHistory.csv'

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "greg.warner@eversana.com"
[string[]]$to = $recipients.Split(',')

$powerBIUser = "srv_PowerBI@eversana.com"
$powerBIPass = Get-Content "C:\PowerShell\PowerBI\srv_PowerBI.txt" | ConvertTo-SecureString
$powerBICredential = New-Object System.Management.Automation.PSCredential($powerBIUser,$powerBIPass)
Connect-PowerBIServiceAccount -Credential $powerBICredential

try 
    {
        $yesterday = $(Get-Date).addDays(-1)
        $7DaysAgo = $yesterday.addDays(-7)

        # Get all possible dates
        $dates = @()
        $increment = $7DaysAgo
        do
            {
                $dates += $increment.ToString('yyyy-MM-dd')
                $increment = $increment.AddDays(1)
            }
        until ($increment -gt $yesterday)

        $all = @()
        foreach ($date in $dates)
            {
                [string]$hour = 0
                do
                    {
                        [string]$hour = $([string]$hour).padLeft(2,'0')
                        $($date + "T" + $hour + ":00:00")
                        $events = ''
                        $events = Get-PowerBIActivityEvent -StartDateTime $($date + "T" + $hour + ":00:00") -EndDateTime $($date + "T" + $hour + ":59:59") | ConvertFrom-JSON | Where-Object {(($_.Activity -eq "ViewReport") -or ($_.Activity -eq "ViewDashboard") -or ($_.Activity -eq "ExportReport") -or ($_.Activity -eq "ExportArtifact")) -and ($_.WorkSpaceName -notlike "PersonalWorkspace*")}
                        $all += $events
                        Start-Sleep -Seconds 3
                        [int]$hour += 1
                    }
                until ($hour -gt 23)
            }

        if(Test-Path $exportFilepath)
            {
                Clear-Content $exportFilepath
            }

        $all | Export-Csv -NoTypeInformation $exportFilepath -Force -Append
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