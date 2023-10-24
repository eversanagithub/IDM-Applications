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

$jobs = Get-AzTableRow -table $table 

# Begin the process
if ($jobs)
{
	# SMTP Details for Notifications
	#$smtpUser = "AzureAutomation@eversana.com"
	#$smtpPass = Get-Content "C:\PowerShell\ServiceNow-Orchestration-OnPrem\AzureAutomation.txt" | ConvertTo-SecureString
	#$smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser,$smtpPass)
	#$fromError = 'AzureAutomation@eversana.com'
	#$smtpServer = 'smtp.office365.com'
	#$smtpPort = 587

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
			#$uriGet = "https://$instance.service-now.com/api/now/table/u_stage_sc_request?sysparm_query=sys_id%3D$sysID"
			$uriGet = "https://eversanadev.service-now.com/u_stage_sc_request_list.do"

			$record = ''
			$record = (Invoke-RestMethod -Headers $headers -Method Get -Uri $uriGet).result
      $record.u_variables
			exit
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
					$variable2 = $variables[1]
					$variable3 = $variables[2]
					$variable4 = $variables[3]
					Write-Host "variable1 = [$variable1], variable2 = [$variable2], variable3 = [$variable3], variable4 = [$variable4]"
				}
			}

	}
}

Disconnect-AzAccount