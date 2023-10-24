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
    #Connect-MicrosoftTeams -Credential $teamsCredential

    foreach ($sctask in $scTasks) 
    {
		#$sctask
		$requestItems = ''
		$requestItems = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scTask.request_item.link)).result
		foreach ($requestItem in $requestItems)
		{
			$Requests = $requestItem.request
			#$Requests

			Write-Host "=============================================================================================="
			$Requests2 = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($Requests.link)).result
			foreach ($Request2 in $Requests2)
			{
				$sysId = $Request2.sys_id
				$sysUpdatedBy = $Request2.sys_updated_by
				$sysCreatedOn = $Request2.sys_created_on
				$sysUpdatedOn = $Request2.sys_updated_on
				$requestItem = $Request2.request_item
				Write-Host "sysId = [$sysId], sysUpdatedBy = [$sysUpdatedBy], sysCreatedOn = [$sysCreatedOn], sysUpdatedOn = [$sysUpdatedOn], requestItem = [$requestItem]"
			}
		}
		#$requestItem
	}
	$variableOwnershipURI = "https://$instance.service-now.com/api/now/table/sc_item_option_mtom"
	$variables = (Invoke-RestMethod -Headers $headers -Method $method -Uri $variableOwnershipURI).result
	$variables

    #Disconnect from Microsoft Teams
    #Disconnect-MicrosoftTeams
}

