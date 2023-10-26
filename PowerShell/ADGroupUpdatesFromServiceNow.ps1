<#
		Program Name: ADGroupUpdatesFromServiceNow.ps1
		Date Written: September 8th, 2023
		  Written By: Dave Jaynes
		 Description: Processes a Service-Now request to add/remove members to/from an Service-Now AD Group.
                      There are 19 modules and 14 functions that constitute for functionality of this script.
#>

####################################################################
#   Module 1: Assign various variables and TLS settings.           #
####################################################################
# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$TotADGroupRequests = @()
$Process = ""
$DisplayValue = ""
$Link = ""
$TimeStamp = Get-Date -Format("yyyyMMddHHmmss")
$Logfile = "C:\IDM\IDM-Applications\PowerShell\Logs\Junkfile_$TimeStamp"
$Reportfile  = "C:\IDM\IDM-Applications\PowerShell\Reports\Service-Now_AD_Group\Service-Now_AD_Group_Modifications_$TimeStamp.txt"
$DoesFileExist = Test-Path $Reportfile
if($DoesFileExist -eq "True") { Remove-Item $Reportfile }

####################################################################
#   Module 2: Define the SQL Write function.                       #
####################################################################
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

####################################################################
#   Module 3: Load ServiceNow variables.                           #
####################################################################
$ServiceNowDevURL = "https://eversanadev.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowTestURL = "https://eversanatest.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowProdURL = "https://eversana.service-now.com/api/now/table/u_stage_sc_request"
$ServiceNowURL = $ServiceNowDevURL
$SNTable = "u_stage_sc_request"
$Query = "u_status=Not_processed"
$ContentType = "application/json"

####################################################################
#   Module 4: Pull credentials based on user running script.       #
####################################################################
# Create the credentials for ServiceNow PowerShell Integration
$serviceAccountUserName1 = Get-Content "C:\IDM\IDM-Applications\PowerShell\credentials\PowerShell_Integration_UserName.txt"
$serviceAccountPassword1 = Get-Content "C:\IDM\IDM-Applications\PowerShell\credentials\EncryptedPowershellIntegrationPassword.txt" | ConvertTo-SecureString
$PS_Integ_Credential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

# Create the credentials for AzAccount
$serviceAccountUserName2 = Get-Content "C:\IDM\IDM-Applications\PowerShell\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\IDM\IDM-Applications\PowerShell\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$AzureADCredential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)
Connect-AzAccount -Credential $AzureADCredential|Out-File -FilePath $Logfile

####################################################################
#   Module 5: Return Error Message                                 #
####################################################################
function DetermineErrorCode
{
	param(
		[string]$ErrorCode
	)  
	$Message = ""
	switch($ErrorCode)
	{
			 1	{	$Message = "E-Mail address is not valid" }
			 2	{	$Message = "Domain name is not correct"	}
			 3	{	$Message = "E-Mail address and Domain name are not correct"	}
			 4	{	$Message = "User GUID returned NULL value"	}
			 5	{	$Message = "User GUID returned NULL value and E-Mail address not valid"	}
			 6	{	$Message = "User GUID returned NULL value and Domain name not valid"	}
			 7	{	$Message = "User GUID returned NULL value and E-Mail address and Domain name are not correct"	}
			 8	{	$Message = "Group GUID returned NULL value"	}
			 9	{	$Message = "Group GUID returned NULL value and E-Mail address not valid"	}
			10	{	$Message = "Group GUID returned NULL value and Domain name is not correct"	}
			11	{	$Message = "Group GUID returned NULL value and E-Mail address and Domain name are not correct"	}
			12	{	$Message = "Group GUID returned NULL value and User GUID returned NULL value"	}
			13	{	$Message = "Group GUID returned NULL value, User GUID returned NULL value and E-Mail address is not valid"	}
			14	{	$Message = "Group GUID returned NULL value, User GUID returned NULL value and Domain name is not correct"	}
			15	{	$Message = "Group GUID returned NULL value, User GUID returned NULL value, E-Mail address is not valid and Domain name is not correct" }
			16  {	$Message = "Error occurred during the addition of removal of user from the AD account" }
			17  {	$Message = "Invalid Action. Only Add and Remove are allowed" }
			18  {	$Message = "User is not currently active so record cannot be processed" }
		}
		return $Message
}

####################################################################
#   Module 6: Return Users's GUID                                  #
####################################################################
function FindUserGUID
{
	param(
		[string]$EMailAddress
	)  
	try{ $GUID = (Get-ADUser -filter {UserPrincipalName -eq $EMailAddress}).ObjectGUID } catch { $GUID = $null }
	return $GUID
}

####################################################################
#   Module 7: Return Group's GUID                                  #
####################################################################
function FindGroupGUID
{
	param(
		[string]$GroupName
	)  
	try{ $GUID = (Get-ADGroup -Filter 'Name -eq $GroupName').ObjectGUID } catch { $GUID = $null }
	return $GUID
}

####################################################################
#   Module 8: Add member to AD Group                               #
####################################################################
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
		SQLWrite -SQLCommand $Command
		$Result = 200
	}
	catch
	{
		$Result = 404
	}
	return $Result
}

####################################################################
#   Module 9: Remove member from AD Group                          #
####################################################################
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
		SQLWrite -SQLCommand $Command
		$Result = 200
	}
	catch
	{
		$Result = 404
	}
	return $Result
}

####################################################################
#   Module 10: Update the date field                               #
####################################################################
function UpdateProcessingDateField    
{
	param(
		[string]$ServiceNowURL,
		[string]$SysID
	)
	$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
	$Body = @{
		u_processed = "$date"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#   Module 11: Update the Return Code field with the action result #
####################################################################
function UpdateReturnCode    
{
		param(
		[string]$ServiceNowURL,
		[string]$SysID,
		[string]$Result
	)

	$Body = @{
		u_return_code = "$Result"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#    Module 12: Update SN Record to Processed                      #
####################################################################
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
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#    Module 13: Update SN Record to Processing                     #
####################################################################
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
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#    Module 14: Update Status Message field                        #
####################################################################
function UpdateStatusMessageField    
{
	param(
		[string]$ServiceNowURL,
		[string]$SysID,
		[string]$Message
	)
	$Body = @{
		u_status_message = "$Message"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#    Module 15: Record Did Not Pass Initial Check                  #
####################################################################
function RecordDidNotPassInitialCheck    
{
	param(
		[string]$ServiceNowURL,
		[string]$SysID,
		[string]$Message
	)
	
	# Set Return Code to 406
	$Body = @{
		u_return_code = "406"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
	
	# Write the message to the u_status_message field
	$Body = @{
		u_status_message = "$Message"
	}
	$JsonBody = $Body | ConvertTo-Json
	$Params = @{
		Method = "PATCH"
		Uri = $ServiceNowURL + "/" + $SysID
		Body = $JsonBody
		ContentType = $ContentType
		Credential = $PS_Integ_Credential
	}
	$thisResult = Invoke-RestMethod @Params
}

####################################################################
#   Module 16: Get status of user                                  #
####################################################################
function CheckUserStatus    
{
	param(
		[string]$UserName
	)
	$Enabled = ""
	try
	{
		$Properties = Get-aduser $UserName -Properties Enabled
		$Properties | %{
			$SNR = $_
			$Enabled = $SNR.Enabled
		}
	}
	catch
	{
		$Enabled = "NoExist"
	}
	return $Enabled
}

####################################################################
#   Module 17: Perform the REST API call into the ServiceNow       #
####################################################################
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

####################################################################
#   Module 18: Main processing area                                #
####################################################################

<#
We use the Invoke-RestMethod CmdLet to retrieve all records from the Service-Now table 'u_stage_sc_request'.
Utilizing the 'u_status' field, we filter for all records with a value of 'Not_processed'.
These records and then read into the '$ServiceNowRecords' object and parsed into individual
variables below. It is these variables which will control how the processing plays out.
#>
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
	
<#
	In the following lines of code, we do variable sanitazitation to ensure data is valid.
	We check E-Mail address, Domain Name, User and Group GUIDs, Action code and user Active status (True or False).
	If any of these checks fail, the $ErrorCode value is changed from 0 to another value and processing
	does not run for this particular record.
#>
	$ErrorCode = 0
	$Message = ""

	if($EMailAddress -notlike "*@eversana*") 
	{	
		$ErrorCode++ 
		$UpdateResult = 406
	}
	if($Domain -notlike "universal.co") 
	{ 
		$ErrorCode += 2 
		$UpdateResult = 406
	}

	$UserGUID = $null
	$UserGUID = FindUserGUID -EMailAddress $EMailAddress
	if(($UserGUID -eq $null) -or ($GroupGUID -eq "")) 
	{ 
		$ErrorCode += 4 
		$UpdateResult = 406
	}
	
	$GroupGUID = $null
	$GroupGUID = FindGroupGUID -GroupName $GroupName
	if(($GroupGUID -eq $null) -or ($GroupGUID -eq ""))
	{ 
		$ErrorCode += 8 
		$UpdateResult = 406
	}
	
	if(($Action -ne "Add") -and ($Action -ne "Remove")) 
	{ 
		$ErrorCode = 17 
		$UpdateResult = 406
	}

	$UserStatus = CheckUserStatus -UserName $UserName
	if($UserStatus -ne "True") 
	{ 
		switch($UserStatus)
		{
			NoExist
			{
				$ErrorCode = 1
				$UpdateResult = 406
				break
			}
			False
			{
				$ErrorCode = 18
				$UpdateResult = 301
			}
		}
	}
	
<#
	Now that the variable sanitazitation process has completed, we attempt to process the record
	based on the $ErrorCode variable value. A value of zero means record is good to process.
	Below we set the $ProcessedRecord variable to 'No'. If it passes the processing text
	which is indicated by the $ErrorCode variable value, then $ProcessedRecord will be
	set to 'Yes' Note that this variable for used for the summary report and has no effect on processing logic.
	
	Additionally, we set the Processing field to 'Processing'.
	Since this script runs once a minute, we don't want the next rendition of the script to
	pick up processing of it when the prior run is currently chewing on it.
	Therefore we change the processing field from 'Not_processed' to 'Processing'.
#>
	$ProcessedRecord = "No"
	UpdateRecordProcessing -ServiceNowURL $ServiceNowURL -SysID $SysID

	if($ErrorCode -eq 0)
	{
		# Call the appropriate action function
		switch($Action)
		{
			Add
			{
				$UpdateResult = AddUserToGroup -GroupName $GroupName -UserName $UserName
				if($UpdateResult -ne 200) { $ErrorCode = 16 }
				break
			}
			Remove
			{
				$UpdateResult = RemoveUserFromGroup -GroupName $GroupName -UserName $Username
				if($UpdateResult -ne 200) { $ErrorCode = 16 }
				break
			}
		}
		$ProcessedRecord = "Yes"
	}

<#
	This is the Post-Processing section.
	
	Here we will update key fields within the record just processed. These steps are:
	1. Set the Processed date field in the SN table to the current date/time.
	2. Update the return code field to depict the status of the request.
	3. Update the message field if a processing issue has occurred.
	4. Finally mark the Processing field to 'Processed', significing the end of this records process run.
#>
	UpdateProcessingDateField -ServiceNowURL $ServiceNowURL -SysID $SysID
	UpdateReturnCode -ServiceNowURL $ServiceNowURL -SysID $SysID -Result $UpdateResult
	if(($UpdateResult -ne 200) -or ($ErrorCode -ne 0))
	{ 
		$Message = DetermineErrorCode -ErrorCode $ErrorCode
		UpdateStatusMessageField -ServiceNowURL $ServiceNowURL -SysID $SysID -Message $Message 
	}
	UpdateRecordProcessed -ServiceNowURL $ServiceNowURL -SysID $SysID
		
	# Create the reporting object for a summary display which shows the status of all records.
	$TotADGroupRequest = New-Object -TypeName PSObject -Property @{
		'E-Mail Address' = $EMailAddress
		'Action' = $Action
		'Domain' = $Domain
		'Group Name' = $GroupName
		'Update Code' = $UpdateResult
		'Processed' = $ProcessedRecord
		'Message' = $Message
	}
	$TotADGroupRequests += $TotADGroupRequest
}

####################################################################
#   Module 19: Finish Up                                           #
####################################################################
# Display the formatted contents of the PS Object '$TotAzureEmpInfos'
$TotADGroupRequests | Sort-Object | Format-Table 'E-Mail Address', 'Action', 'Domain', 'Group Name', 'Update Code', 'Processed', 'Message' -AutoSize|Out-File -FilePath $Reportfile

# This command kicks off all the batched Adds and Removes of users to/from the Service-Now AD groups.
$Command = "exec msdb.dbo.sp_start_job N'IDM - AD-Adhoc AddUpdateRemove'"
SQLWrite -SQLCommand $Command

# Nuke the log file.
$DoesFileExist = Test-Path $Logfile
if($DoesFileExist -eq "True") { Remove-Item $Logfile }