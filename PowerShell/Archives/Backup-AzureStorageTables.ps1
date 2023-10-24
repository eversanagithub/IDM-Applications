#Author: Gregory Warner
#Last Modified: 9/9/20
#Summary: Backup All Data from Azure Storage Account Tables Used for Production

# Designate export filepath
$exportFilepath = "C:\PowerShell\Backup-AzureStorageTables\"

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "greg.warner@eversana.com"
[string[]]$to = $recipients.Split(',')

# Connect to Azure
$user = "Srv_Orchestration@eversana.com"
$pass = Get-Content "C:\PowerShell\Backup-AzureStorageTables\Srv_Orchestration.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential($user,$pass)
Connect-AzAccount -Credential $credential

# Designate variables for use with Azure Storage table for recordkeeping
$resourceGroupName = "esa-prod-auto-rg"
$storageAccountName = "prodautostorage"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$tables = Get-AzStorageTable -Context $storageAccount.context

try
    {
        foreach ($table in $tables)
            {
                # Create directory for table if it doesn't already exist
                $path = ''
                $path = $exportFilepath + $($table.Name)
                if (-Not $(Test-Path $path))
                    {
                        New-Item -Path $exportFilepath -Name $($table.Name) -ItemType "directory"
                    }

                # Back up rows for the table
                $rows = ''
                $rows = Get-AzTableRow -table $($table.CloudTable)
                $fullPath = ''
                $fullPath = $path+"/"+$($table.Name)+"-"+$(get-date -Format yyyyMMdd)+".csv"
                $rows | Export-Csv -NoTypeInformation $fullPath

                # Delete backups older than 30 days
                Get-ChildItem –Path $path -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-30))} | Remove-Item
            }
        Disconnect-AzAccount
    }
catch
    {
          # SMTP Details for Notifications
          $smtpUser = "AzureAutomation@eversana.com"
          $smtpPass = Get-Content "C:\PowerShell\Backup-AzureStorageTables\AzureAutomation.txt" | ConvertTo-SecureString
          $smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser,$smtpPass)
          $fromError = 'AzureAutomation@eversana.com'
          $smtpServer = 'smtp.office365.com'
          $smtpPort = 587
          $subject = "Error Backing Up Tables from Azure Storage - "+$($table.Name)
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
                An error was experienced backing up table data used by Azure Automation on DCOBUTIL01.<br/>
                <br/>
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
              -SmtpServer $smtpServer `
              -Port $smtpPort `
              -credential $smtpCredential
    }