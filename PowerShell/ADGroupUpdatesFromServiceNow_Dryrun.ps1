<#
		Program Name: ADGroupUpdatesFromServiceNow.ps1
		Date Written: September 8th, 2023
		  Written By: Dave Jaynes
		 Description: Processes a Service-Now request to add a member to an AD Group 
#>

###############################################################
#   Step 1: Assign various variables and TLS settings.        #
###############################################################
# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$TotADGroupRequests = @()
$Process = ""
$DisplayValue = ""
$Link = ""
$TimeStamp = Get-Date -Format("yyyyMMddHHmmss")
$Logfile = "C:\UtilityScripts\Logs\Junkfile_$TimeStamp"

###############################################################
#   Step 2: Define the SQL Write function.                    #
###############################################################
function SQLWrite {
	Param (
		[string]$SQLCommand
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQLCommand, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

###############################################################
#   Step 3: Load ServiceNow variables.                        #
###############################################################
$ServiceNowDevURL = "https://eversanadev.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowTestURL = "https://eversanatest.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowProdURL = "https://eversana.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowURL = $ServiceNowDevURL
$SNTable = "u_stage_sc_request"
$Query = "u_status=Not_processed"
$ContentType = "application/json"

###############################################################
#   Step 4: Pull credentials based on user running script.    #
###############################################################
# Create the credentials for ServiceNow PowerShell Integration
$serviceAccountUserName2 = Get-Content "C:\PowerShell\credentials\PowerShell_Integration_UserName.txt"
$serviceAccountPassword2 = Get-Content "C:\PowerShell\credentials\EncryptedPowershellIntegrationPassword_dave_jaynes.txt" | ConvertTo-SecureString
$PS_Integ_Credential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Create the credentials for AzAccount
$serviceAccountUserName3 = Get-Content "C:\PowerShell\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword3 = Get-Content "C:\PowerShell\credentials\OneDriveRetentionPassword2.txt" | ConvertTo-SecureString
$AzureADCredential3 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName3,$serviceAccountPassword3)
Connect-AzAccount -Credential $AzureADCredential3|Out-File -FilePath $Logfile

#################################################################
#   Step 5: Return Group's GUID                                 #
#################################################################
function FindGroupGUID
{
	param(
		[string]$GroupName
	)  
	try{ $GUID = (Get-ADGroup -Filter 'Name -eq $GroupName').ObjectGUID } catch { $GUID = $null }
	return $GUID
}

#################################################################
#   Step 6: Add member to AD Group                              #
#################################################################
function AddUserToGroup
{
	param(
		[string]$GroupName,
		[string]$UserName
	)  
	$Result = 0
	try
	{
		$Command = "exec iam..AD_AdHoc_AddUpdateAttribute 'ad_universal','memberof','" + $UserName + "','" + $GroupName + "'"
		#SQLWrite -SQLCommand $Command
		$Command = "exec msdb.dbo.sp_start_job N'IDM - AD-Adhoc-AddUpdateAttribute'"
		#SQLWrite -SQLCommand $Command
		# Write-Host "Add-ADGroupMember -Identity $groupGUID -Members $userGUID -Confirm:$false"
		$Result = 200
	}
	catch
	{
		$Result = 404
	}
	return $Result
}

#################################################################
#   Step 7: Remove member from AD Group                         #
#################################################################
function RemoveUserFromGroup
{
	param(
		[string]$GroupName,
		[string]$UserName
	)  
	$Result = 0
	try
	{
		$Command = "exec iam..AD_AdHoc_RemoveAttribute 'ad_universal','memberof','$UserName','$GroupName'"
		#SQLWrite -SQLCommand $Command
		$Command = "exec msdb.dbo.sp_start_job N'IDM - AD-Adhoc-AddUpdateAttribute'"
		#SQLWrite -SQLCommand $Command
		# Write-Host "Remove-ADGroupMember -Identity $groupGUID -Members $userGUID -Confirm:$false"
		$Result = 200
	}
	catch
	{
		$Result = 404
	}
	return $Result
}

#################################################################
#   Step 8: Update the Return Code field with the action result #
#################################################################
function UpdateReturnCode    
{
	param(
		[string]$SNTable,
		[string]$SysID,
		[string]$Result
	)
	if($Result -eq "200") 
	{ 
		$Body = @{
		u_return_code = "200"
		}
	}
	else
	{ 
		$Body = @{
		u_return_code = "404"
		}
	}
	$Uri = $ServiceNowURL + "/" + $SysID
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PUT"
		Uri = $Uri
		Body = $Body
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	# Write-Host "Updating [$SNTable] with code [$Result] and Body [$Body]"
	#$thisResult = Invoke-RestMethod @Params
}

#################################################################
#    Step 9: Update SN Record to Processed                      #
#################################################################
function UpdateRecordProcessed    
{
	param(
		[string]$ServiceNowURL,
		[string]$SysID
	)
	$Body = @{
		u_status = "Processed"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	# Write-Host "Here we set the Sys ID [$SysID] to 'Processed'"
	#$thisResult = Invoke-RestMethod @Params
}

#################################################################
#    Step 10: Update SN Record to Processing                    #
#################################################################
function UpdateRecordProcessing    
{
	param(
		[string]$ServiceNowURL,
		[string]$SysID
	)
	$Body = @{
		u_status = "Processing"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	# Write-Host "Here we set the Sys ID [$SysID] to 'Processing'"
	#$thisResult = Invoke-RestMethod @Params
}

#################################################################
#   Step 11: Perform the REST API call into the ServiceNow      #
#################################################################

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
	if ($Query) {
		$Body.sysparm_query = $Query
	}

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

#################################################################
#   Step 12: Main processing area                               #
#################################################################
$ServiceNowRecords = Get-ServiceNowTable -Table $SNTable -Query $Query -ServiceNowURL $ServiceNowURL
$ServiceNowRecords | %{
	$SNR = $_
	$SysID = $SNR.sys_id
	$Status = $SNR.u_status
	$CatalogItemName = $SNR.u_catalog_item_name
	$Processed = $SNR.u_requested_item
	$RequestedItems = $SNR.u_requestedItems
	$ReturnCode = $SNR.u_return_code
	$Variables = $SNR.u_variables
	$WebhookSent = $SNR.webhook_sent
	$WebhookSentOn = $SNR.u_webhook_sent_on
	[String[]]$Payload = $Variables.Split("|")
	$EMailAddress = $Payload[0]
	$Action = $Payload[1]
	$Domain = $Payload[2]
	$GroupName = $Payload[3]
	$Processed | %{
		$Process = $_
		$RITM_Value = $Process.display_value
		$Link = $Process.link
	}
	[String[]]$User = $EMailAddress.Split("@")
	$UserName = $User[0]

	# Validate the EMail address and domain name are good.
	if($EMailAddress -like "*@eversana*")	{	$EMailGood = "Yes" } else {	$EMailGood = "No" }
	if($Domain -like "*.co*")	{	$DomainGood = "Yes" } else {	$DomainGood = "No" }
	
	# Pull in the User's GUID
	$UserGUID = $null
	try{ $UserGUID = (Get-ADUser -filter {UserPrincipalName -eq $EMailAddress}).ObjectGUID } catch {}
	
	# Pull in the Group GUID
	$GroupGUID = $null
	$GroupGUID = FindGroupGUID -GroupName $GroupName
	
	# Process the records that pass validation
	if(($UserGUID -ne $null) -and ($EMailGood -ne "No") -and ($DomainGood -ne "No"))
	{
		# Set the Processing field to 'Processing'
		UpdateRecordProcessing -ServiceNowURL $ServiceNowURL -SysID $SysID
		
		# Call the appropriate action function
		switch($Action)
		{
			Add
			{
				$UpdateResult = AddUserToGroup -GroupName $GroupName -UserName $UserName
				break
			}
			Remove
			{
				$UpdateResult = RemoveUserFromGroup -GroupGUID $GroupName -UserGUID $Username
			}
		}
		$ProcessedRecord = "Yes"
	}
	else
	{
		$ProcessedRecord = "No"
		$UpdateResult = "N/A"
	}

	# Create the reporting object for a summary display
	$TotADGroupRequest = New-Object -TypeName PSObject -Property @{
		'E-Mail Address' = $EMailAddress
		'Action' = $Action
		'Domain' = $Domain
		'Group Name' = $GroupName
		'Update Code' = $UpdateResult
		'Processed' = $ProcessedRecord
	}
	$TotADGroupRequests += $TotADGroupRequest
	
	# Update the result of the AD Group action
	UpdateReturnCode -SNTable $SNTable -SysID $SysID -Result $UpdateResult

	# Finally, set the Processing field to 'Processed'
	UpdateRecordProcessed -ServiceNowURL $ServiceNowURL -SysID $SysID
}

#################################################################
#   Step 13: Finish Up                                          #
#################################################################
# Display the formatted contents of the PS Object '$TotAzureEmpInfos'
$TotADGroupRequests | Sort-Object | Format-Table 'E-Mail Address', 'Action', 'Domain', 'Group Name', 'Update Code', 'Processed' -AutoSize

$DoesFileExist = Test-Path $Logfile
if($DoesFileExist -eq "True") { Remove-Item $Logfile }