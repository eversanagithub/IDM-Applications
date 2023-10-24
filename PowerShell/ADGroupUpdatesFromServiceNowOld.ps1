<#
		Program Name: ServiceNowToSharePoint.ps1
		Date Written: July 25th, 2022
		  Written By: Dave Jaynes
		 Description: Transmits newly added In-Touch employee information from the 
									ServiceNow 'u_stage_itg_onboarding' table into the SharePoint
									'DevNewHireTracking' table so it may be processed by the In-Touch
									Pulse application for employee onboarding purposes.
#>

###############################################################
#    Step 1: Assign various local variables.                  #
###############################################################

# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define SQL table names
$SQLServer = "10.241.36.13"
$ServiceNowTable = "SNAPICreds"
$EnvironmentTable = "SNEnv"
$SharePointFieldNames = "sharepoint_newhire_fieldnames"
$SharePointRecordInfo = "SharePointRecordInfo"
$EncryptionSQLDatabase = "encryptedpasswords"
$EncryptionSQLTable = "encryptedpasswords"
$UnauthorizedList = "UnauthorizedList"
$Script = "ServiceNowToSharePoint.ps1"

# Initialize the HTML output file
$HTMLFile = 'C:\PowerShell\ServiceNowToSharePoint\ServiceNowToSharePoint.html'
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }

# Ensure the Found Records variable is initially set to 'No'.
$FoundRecordsToProcess = "No"

###############################################################
#    Step 2: Define the SQL Read and Write functions.         #
###############################################################

function SQLWrite
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update $SAP set msg = 'No associate name selected',msg1 = 'Please select associate name'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

function SQLQuery {
	Param (
		[string]$SQLCommand
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select DelegatedURL from $DAP where Owner = '$Employee'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQLCommand, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$APIValue = $rdr["APIValue"]
	}
	$rdr.Close()
	$con.Close()
	return $APIValue
}

###############################################################
#             Step 3: Load ServiceNow variables.              #
###############################################################

# Pull URLs, Table Names, Content Type and Query String from the 'SNtoSPDevandProdValues' SQL table.
# The 'DevProd' field in the 'SNtoSPDevOrProd' table will return either 'Dev' or 'Prod' which
# will then dictate the tier level for the seven REST API attributes below.

$ServiceNowURL = "https://eversanadev.service-now.com/u_stage_sc_request_list.do"
$ServiceNowURL = SQLQuery -SQLCommand "select APIValue from $ServiceNowTable where TypeValue = 'ServiceNowStagingTable' and DevProd = (select Env from $EnvironmentTable where Active = 'Yes')"
$SNTable = SQLQuery -SQLCommand "select APIValue from $ServiceNowTable where TypeValue = 'SNTable' and DevProd = (select Env from $EnvironmentTable where Active = 'Yes')"
$Query = SQLQuery -SQLCommand "select APIValue from $ServiceNowTable where TypeValue = 'Query' and DevProd = (select Env from $EnvironmentTable where Active = 'Yes')"
$ContentType = SQLQuery -SQLCommand "select APIValue from $ServiceNowTable where TypeValue = 'ContentType' and DevProd = (select Env from $EnvironmentTable where Active = 'Yes')"

$ServiceNowURL = "https://eversanadev.service-now.com/u_stage_sc_request_list.do"
$ContentType = "application/json"

###############################################################
#    Step 4: Perform the REST API call into the ServiceNow    #
###############################################################

$serviceAccountUserName2 = Get-Content "C:\PowerShell\credentials\PowerShell_Integration_UserName.txt"
$serviceAccountPassword2 = Get-Content "C:\PowerShell\credentials\EncryptedPowershellIntegrationPassword_dave_jaynes.txt" | ConvertTo-SecureString
$PS_Integ_Credential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Function to perform the REST API call into the ServiceNow 'u_stage_itg_onboarding' table.
function Get-ServiceNowTable {
	[OutputType([System.Management.Automation.PSCustomObject])]
	[CmdletBinding(DefaultParameterSetName, SupportsPaging)]
	Param (
		# Name of the table to be queried against in ServiceNow.
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Table,

		# Define conditional field-value queries to reduce overall payload return
		[Parameter(Mandatory = $false)]
		[string]$Query,

		# Maximum number of records to return; in this case all of them as this parameter is not passed.
		[Parameter(Mandatory = $false)]
		[int]$Limit,

		# Whether or not to show human readable display values instead of machine values
		[Parameter(Mandatory = $false)]
		[ValidateSet('true', 'false', 'all')]
		[string]$DisplayValues = 'true',

		# Specify the actual REST API URL to be called by the Invode-RestMethod CmdLet.
		[Parameter(ParameterSetName = 'SpecifyConnectionFields', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[Alias('Url')]
		[string]$ServiceNowURL
	)

	# Initialize the Invoke-RestMethod Body object.
	$Body = @{'sysparm_display_value' = $DisplayValues}
	
	# Populate the Body 'sysparm_query' property with the 'SharePoint Updated' column looking for a 'false' value.
	#if ($Query) {
	#	$Body.sysparm_query = $Query
	#}

	# Use the 'sysparm_fields' property if we were looking to only pull back certain columns from the SN table.
	if ($Properties) {
		$Body.sysparm_fields = ($Properties -join ',').ToLower()
	}

	# Build the fully populated $Uri variable.
	#$Uri = $ServiceNowURL + "/table/$SNTable"
	$Uri = $ServiceNowURL

	# Combine all REST API parameters within the $Params array.
	$Params = @{
		Method = "GET"
		Uri = $Uri
		Body = $Body
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}

	# Kick off the REST API call to ServiceNow.
	$ServiceNowRecords = (Invoke-RestMethod @Params).Result

	# Return the API call results to the function call command.
	return $ServiceNowRecords
}

###############################################################
#           Step 4: Connect to Azure Storage Tables.          #
###############################################################

$servicenowCredentials = Import-Clixml "C:\PowerShell\ServiceNow-Orchestration-OnPrem\ServiceNow_Powershell.xml"
        $servicenowUser = $servicenowCredentials.UserName
        $servicenowPass = $servicenowCredentials.GetNetworkCredential().Password
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $servicenowUser,$servicenowPass)))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/json')
				
exit

###############################################################
#           Step 4: Connect to Azure Storage Tables.          #
###############################################################

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

#$jobs = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true' and Processed eq 'false'"
$jobs = Get-AzTableRow -table $table
<#
$uri = "https://131d4571-d5a9-4760-bbd0-04be6ef811c0.webhook.eus.azure-automation.net/webhooks?token=WCo2cvV0qUU6GrHvOoYvRJJr%2bBMAOD6psyCNVHMfbwc%3d"
$requestBody  = @{NAME='Larry Wheat';PERSONNELNUMBER='103251';MANAGER='Jerry Locke'}
$body = ConvertTo-Json -Depth 9 -InputObject $requestBody
$header = @{message="Service-NowPull"}
$response = Invoke-WebRequest -Method GET -Uri $uri -Body $body -Headers $header
$response
#>

###############################################################
#              Step 5: Process Active SN Records.             #
###############################################################

$Counter = 0
<#
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
		$Counter++
		Write-Host "Counter = [$Counter], instance = [$instance], requestItem = [$requestItem], catalogTask = [$catalogTask], sysID = [$sysID]"
		#>
		Get-ServiceNowTable -Table $SNTable -ServiceNowURL $ServiceNowURL
		#$ServiceNowRecords = Get-ServiceNowTable -Table $SNTable -ServiceNowURL $ServiceNowURL

		# Walk through the API return payload and process the data accordingly.
		$ServiceNowRecords | %{
			$SNR = $_
			$CatalogItemName = $SNR.u_catalog_item_name
			$RequestedItems = $SNR.u_requested_items
			$ReturnCode = $SNR.u_return_code
			$Variables = $SNR.u_variables
			$WebhookSent = $SNR.u_webhook_sent
			$WebhookSentOn = $SNR.u_webhook_sent_on

			#Write-Host "CatalogItemName = [$CatalogItemName]"
			#Write-Host "RequestedItems = [$RequestedItems]"
			#Write-Host "ReturnCode = [$ReturnCode]"
			#Write-Host "Variables = [$Variables]"
			#Write-Host "WebhookSent = [$WebhookSent]"
			#Write-Host "WebhookSentOn = [$WebhookSentOn]"
		}
		<#
	}
	catch
	{
		Write-Host "An error occurred"
	}
}
exit

#################################################################
#    Step 8: Update u_sharepoint_updated column                 #
#################################################################

# Set the 'u_sharepoint_updated' column within ServiceNow to 'True' once the SN data is recorded into SharePoint.
function UpdateRecord    
{
	param(
		[string]$SysID
	)

	$Body = @{
		u_sharepoint_updated = "true"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = "$ServiceNowStagingTable/$SysID"
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
}


#################################################################
#    Step 13: Send E-Mail and finish up                         #
#################################################################

# Finish up $HTMLFile file.
Add-Content -Path "$HTMLFile" -Value "</table>"
Add-Content -Path "$HTMLFile" -Value "</body>"
Add-Content -Path "$HTMLFile" -Value "</html>"

# Finally, send out e-mail to show which users were processed this hour.
$from = 'srv_O365@eversana.com'
$fromError = 'AzureAutomation@eversana.com'
$recipients = "dave.jaynes@eversana.com,abhijeet.rathod@eversana.com"
[string[]]$to = $recipients.Split(',')
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$subject = "ServiceNow New Employee Processing Hourly Report"
$body = Get-Content $HTMLFile -Raw

Send-MailMessage `
	-From $from `
	-To $to `
	-Subject $subject `
	-Body $body `
	-BodyAsHtml `
	-UseSsl `
	-SmtpServer $SmtpServer `
	-Port $SmtpPort `
	-credential $AzureADCredential
	
#>
# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }