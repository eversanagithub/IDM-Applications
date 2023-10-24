<#
		Program Name: ServiceNowToSharePoint.ps1
		Date Written: July 25th, 2022
		  Written By: Dave Jaynes
		 Description: Transmits newly added In-Touch employee information from the 
									ServiceNow 'u_stage_itg_onboarding' table into the SharePoint
									'DevNewHireTracking' table so it may be processed by the In-Touch
									Pulse application for employee onboarding purposes.
#>

# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set SQL connection parameters
$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw

# Define SQL table names
$SQLTable = "SNtoSPDevandProdValues"
$DevOrProd = "SNtoSPDevOrProd"
$SharePointFieldNames = "sharepoint_newhire_fieldnames"
$SharePointRecordInfo = "SharePointRecordInfo"

# Set up the SQL Read single field function
function SQLQuery    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.26\Assemblies\v4.5.2\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=10.241.36.13;user id=$SQLUserName;password=$SQLPassword;database=sntosp;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$SQLReturnValue = while($myreader.Read()){ $myreader.GetString($field) }
	$myconnection.Close()
	$SQLReturnValue
}

# Pull URLs, Table Names, Content Type and Query String from the 'SNtoSPDevandProdValues' SQL table.
# The 'DevProd' field in the 'SNtoSPDevOrProd' table will return either 'Dev' or 'Prod' which
# will then dictate the tier level for the seven REST API attributes below.
$SharePointURL = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'SharePointURL' and DevProd = (select DevProd from $DevOrProd)"
$ServiceNowURL = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'ServiceNowURL' and DevProd = (select DevProd from $DevOrProd)"
$ServiceNowStagingTable = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'ServiceNowStagingTable' and DevProd = (select DevProd from $DevOrProd)"
$SNTable = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'SNTable' and DevProd = (select DevProd from $DevOrProd)"
$ListName = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'ListName' and DevProd = (select DevProd from $DevOrProd)"
$Query = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'Query' and DevProd = (select DevProd from $DevOrProd)"
$ContentType = SQLQuery -SQLCommand "select APIValue from $SQLTable where TypeValue = 'ContentType' and DevProd = (select DevProd from $DevOrProd)"

# Load the SharePoint table field names from the 'sharepoint_newhire_fieldnames' SQL table.
$NewHireName = SQLQuery -SQLCommand "select NewHireName from $SharePointFieldNames"
$JobTitle = SQLQuery -SQLCommand "select JobTitle from $SharePointFieldNames"
$Department = SQLQuery -SQLCommand "select Department from $SharePointFieldNames"
$Manager = SQLQuery -SQLCommand "select Manager from $SharePointFieldNames"
$SeatLocation = SQLQuery -SQLCommand "select SeatLocation from $SharePointFieldNames"
$Client = SQLQuery -SQLCommand "select Client from $SharePointFieldNames"
$Brand = SQLQuery -SQLCommand "select Brand from $SharePointFieldNames"
$NameOfReferral = SQLQuery -SQLCommand "select NameOfReferral from $SharePointFieldNames"
$AdditionalInfo = SQLQuery -SQLCommand "select AdditionalInfo from $SharePointFieldNames"
$Portofolio = SQLQuery -SQLCommand "select Portofolio from $SharePointFieldNames"
$ShareAccessNeeded = SQLQuery -SQLCommand "select ShareAccessNeeded from $SharePointFieldNames"
$D365RoleID = SQLQuery -SQLCommand "select D365RoleID from $SharePointFieldNames"
$ServiceNowNum = SQLQuery -SQLCommand "select ServiceNowNum from $SharePointFieldNames"
$Team = SQLQuery -SQLCommand "select Team from $SharePointFieldNames"
$ServicingOffice = SQLQuery -SQLCommand "select ServicingOffice from $SharePointFieldNames"
$Affiliates = SQLQuery -SQLCommand "select Affiliates from $SharePointFieldNames"
$Status = SQLQuery -SQLCommand "select Status from $SharePointFieldNames"
$WorkplaceOption = SQLQuery -SQLCommand "select WorkplaceOption from $SharePointFieldNames"
$Pronouns = SQLQuery -SQLCommand "select Pronouns from $SharePointFieldNames"
$EmployeeLocation = SQLQuery -SQLCommand "select EmployeeLocation from $SharePointFieldNames"
$TrainingRequested = SQLQuery -SQLCommand "select TrainingRequested from $SharePointFieldNames"
$StartingDate = SQLQuery -SQLCommand "select StartDate from $SharePointFieldNames"
$AccessToInflight = SQLQuery -SQLCommand "select AccessToInflight from $SharePointFieldNames"

# Initialize the Service Now Records array to hold all processed records.
$ServiceNowRecords = @()

# Add DLL files and Snap-Ins
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

# Initialize the HTML output file
$HTMLFile = 'C:\PowerShell\ServiceNowToSharePoint\ServiceNowToSharePoint.html'
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }

# Ensure the Found Records variable is initially set to 'No'.
$FoundRecordsToProcess = "No"

# Create encrypted credential variables.
$ServiceNowUserName = Get-Content "C:\PowerShell\credentials\ServiceNowUserName.txt"
$ServiceNowPassword = Get-Content "C:\PowerShell\credentials\ServiceNowPassword.txt" | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PSCredential($ServiceNowUserName,$ServiceNowPassword)
$O365_user = Get-Content "C:\PowerShell\credentials\srv_O365_UserName.txt"
$O365_Password = Get-Content "C:\PowerShell\credentials\EncryptedO365Password.txt" | ConvertTo-SecureString
$AzureADCredential = New-Object System.Management.Automation.PSCredential($O365_user,$O365_Password)
exit
#$PulseInTouch_User = Get-Content "C:\PowerShell\credentials\PulseIntouchsolUserName.txt"
#$PulseInTouch_Password = Get-Content "C:\PowerShell\credentials\PulseIntouchsolPassword.txt" | ConvertTo-SecureString
#$Cred = New-Object System.Management.Automation.PSCredential($PulseInTouch_User,$PulseInTouch_Password)
$Eversana_Sharepoint_User = Get-Content "C:\PowerShell\credentials\Eversana_Sharepoint_Username.txt"
$Eversana_Sharepoint_Password = Get-Content "C:\PowerShell\credentials\Eversana_Sharepoint_Password.txt" | ConvertTo-SecureString
$Cred = New-Object System.Management.Automation.PSCredential($Eversana_Sharepoint_User,$Eversana_Sharepoint_Password)
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SharePointURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
#C:\PowerShell\credentials\Eversana_Sharepoint_Username.txt
#################################################
#			Function Defination Area			#
#################################################

# Create the 'SharePointRecordInfo' table if it does not already exist
function RecreateSharePointRecordInfo
{
	SQLQuery -SQLCommand "create table if not exists $SharePointRecordInfo(NewHireName varchar(60),JobTitle varchar(80),Department varchar(80),Manager varchar(60),SeatLocation varchar(40),Client varchar(200),Brand varchar(200) ,NameOfReferral varchar(60),AdditionalInfo varchar(200),Portofolio varchar(60),ShareAccessNeeded varchar(120),D365RoleID varchar(80),ServiceNowNum varchar(20),Team varchar(60),Location varchar(120),Affiliates varchar(60),Status varchar(60),WorkplaceOption varchar(40),Pronouns varchar(30),EmployeeLocation varchar(200),TrainingRequested varchar(300),StartDate varchar(30),AccessToInflight varchar(6))"
}

# Add record to 'SharePointRecordInfo' SQL table
function AddRecToSharePointRecordInfo
{
	param(
		[string]$NewHireName,
		[string]$JobTitle,
		[string]$Department,
		[string]$Manager,
		[string]$SeatLocation,
		[string]$Client,
		[string]$Brand,
		[string]$NameOfReferral,
		[string]$AdditionalInfo,
		[string]$Portofolio,
		[string]$ShareAccessNeeded,
		[string]$D365RoleID,
		[string]$ServiceNowNum,
		[string]$Team,
		[string]$Location,
		[string]$Affiliates,
		[string]$Status,
		[string]$WorkplaceOption,
		[string]$Pronouns,
		[string]$EmployeeLocation,
		[string]$TrainingRequested,
		[string]$StartDate,
		[string]$AccessToInflight
	)
	$thisEmployeeLocation = $EmployeeLocation -replace '\\','' -replace 'u0027','''' -replace 'u0026',"&" -replace "'","''" -replace "`t|`n|`r"," "
	$thisSeatLocation = $SeatLocation -replace '\\','' -replace 'u0027','''' -replace 'u0026',"&" -replace "'","''" -replace "`t|`n|`r"," "
	$thisShareAccessNeeded = $ShareAccessNeeded -replace '\\','' -replace 'u0027','''' -replace 'u0026',"&" -replace "'","''" -replace "`t|`n|`r"," "
	$thisAdditionalInfo = $AdditionalInfo -replace '\\','' -replace 'u0027','''' -replace 'u0026',"&" -replace "'","''" -replace "`t|`n|`r"," "
	$thisTrainingRequested = $TrainingRequested -replace '\\','' -replace 'u0027','''' -replace 'u0026',"&" -replace "'","''" -replace '\|',';' -replace "`t|`n|`r"," "
	if($thisTrainingRequested.Length -gt 290)
	{
		$thisTrainingRequested = "Line too long"
	}

	SQLQuery -SQLCommand "insert into $SharePointRecordInfo(NewHireName,JobTitle,Department,Manager,SeatLocation,Client,Brand ,NameOfReferral,AdditionalInfo,Portofolio,ShareAccessNeeded,D365RoleID,ServiceNowNum,Team,Location,Affiliates,Status,WorkplaceOption,Pronouns,EmployeeLocation,TrainingRequested,StartDate,AccessToInflight) values ('$NewHireName','$JobTitle','$Department','$Manager','$thisSeatLocation','$Client','$Brand' ,'$NameOfReferral','$thisAdditionalInfo','$Portofolio','$thisShareAccessNeeded','$D365RoleID','$ServiceNowNum','$Team','$Location','$Affiliates','$Status','$WorkplaceOption','$Pronouns','$thisEmployeeLocation','$thisTrainingRequested','$StartDate','$AccessToInflight')"
}

# Create HTML Heading function
function CreateHTMLHeading    
{
	param(
		[string]$HTMLFile
	)  
	Add-Content -Path "$HTMLFile" -Value "<html>"
	Add-Content -Path "$HTMLFile" -Value "<head>"
	Add-Content -Path "$HTMLFile" -Value "<link rel='stylesheet' href='http://ansible-web/css/styles.css'>"
	Add-Content -Path "$HTMLFile" -Value "</head>"
	Add-Content -Path "$HTMLFile" -Value "<body>"
	Add-Content -Path "$HTMLFile" -Value "<center>"
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "  <tr>"
	Add-Content -Path "$HTMLFile" -Value "    <td align='center'><img src='http://ansible-web/ServiceNow/images/SharePoint.jpg' width='450' height='200'></td>"
	Add-Content -Path "$HTMLFile" -Value "  </tr>"
	Add-Content -Path "$HTMLFile" -Value "  <tr>"
	Add-Content -Path "$HTMLFile" -Value "    <th>"
	Add-Content -Path "$HTMLFile" -Value "     <br>"
	Add-Content -Path "$HTMLFile" -Value "      <p class='H2_BlueViolet_Center_Underline'><i>SharePoint New Hire Record Entry File</i></font>"
	Add-Content -Path "$HTMLFile" -Value "     </br>"
	Add-Content -Path "$HTMLFile" -Value "    </th>"
	Add-Content -Path "$HTMLFile" -Value "  </tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "</center>"
}

# Add HTML column headers function
function AddHTMLRecordHeaders    
{
	param(
		[string]$HTMLFile
	)  
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "     <br>"
	Add-Content -Path "$HTMLFile" -Value "  <tr>"
	Add-Content -Path "$HTMLFile" -Value "    <th>"
	Add-Content -Path "$HTMLFile" -Value "      <p class='Detail_Black_Center_Italic'>Listed below are the latest ServiceNow new hire records which have been processed this hour.</p>"
	Add-Content -Path "$HTMLFile" -Value "    </th>"
	Add-Content -Path "$HTMLFile" -Value "  </tr>"
	Add-Content -Path "$HTMLFile" -Value "</table>"
	Add-Content -Path "$HTMLFile" -Value "     <br>"
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "  <tr>"
	Add-Content -Path "$HTMLFile" -Value "    <th><p class='H2_BlueViolet_Center_Underline'>New Hire Name</p></th>"
	Add-Content -Path "$HTMLFile" -Value "      <th><p class='H2_BlueViolet_Center_Underline'>Manager</p></th>"
	Add-Content -Path "$HTMLFile" -Value "    <th><p class='H2_BlueViolet_Center_Underline'>Department</p></th>"
	Add-Content -Path "$HTMLFile" -Value "      <th><p class='H2_BlueViolet_Center_Underline'>Start Date</p></th>"
	Add-Content -Path "$HTMLFile" -Value "  </tr>"
}

# No records found HTML function
function NoRecordsFoundHTMLMessage
{
	param(
		[string]$HTMLFile
	)  
	Add-Content -Path "$HTMLFile" -Value "<table width=100%>"
	Add-Content -Path "$HTMLFile" -Value "     <br>"
	Add-Content -Path "$HTMLFile" -Value "  <tr>"
	Add-Content -Path "$HTMLFile" -Value "    <th>"
	Add-Content -Path "$HTMLFile" -Value "      <p class='Detail_Black_Center'><i>No records found to process this hour.</i></font>"
	Add-Content -Path "$HTMLFile" -Value "    </th>"
	Add-Content -Path "$HTMLFile" -Value "  </tr>"
}
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
		Credential = $Credential
	}
	$thisResult = Invoke-RestMethod @Params
}

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
	if ($Query) {
		$Body.sysparm_query = $Query
	}

	# Use the 'sysparm_fields' property if we were looking to only pull back certain columns from the SN table.
	if ($Properties) {
		$Body.sysparm_fields = ($Properties -join ',').ToLower()
	}

	# Build the fully populated $Uri variable.
	$Uri = $ServiceNowURL + "/table/$SNTable"

	# Combine all REST API parameters within the $Params array.
	$Params = @{
		Method = "GET"
		Uri = $Uri
		Body = $Body
		ContentType = $ContentType
		Credential = $Credential
	}

	# Kick off the REST API call to ServiceNow.
	$ServiceNowRecords = (Invoke-RestMethod @Params).Result

	# Return the API call results to the function call command.
	return $ServiceNowRecords
}

########## End of Function Definitions ##########

######## Main Processing Section Begins #########

# Ensure the SharePointRecordInfo table exists.
RecreateSharePointRecordInfo

# Write the HTML heading to the $HTMLFile file.
#CreateHTMLHeading -HTMLFile $HTMLFile

# Call the 'Get-ServiceNowTable' function with required parameters.
$ServiceNowRecords = Get-ServiceNowTable -Table $SNTable -Query $Query -ServiceNowURL $ServiceNowURL

# Walk through the API return payload and process the data accordingly.
$ServiceNowRecords | %{
	$SNR = $_
	$SNR
	exit
	$SysID = $SNR.sys_id
	$SNNum = $SNR.u_requested_item
	$RecordUpdated = $SNR.u_sharepoint_updated
	$NewEmployeeNameName = $SNR.u_new_hire_name
	$ManagerName = $SNR.u_manager
	$DepartmentName = $SNR.u_department
	$StartDate = $SNR.u_start_date
	
	# If '$RecordUpdated' is set to 'false', this is newly added record.
	if($RecordUpdated -eq "false")
	{
		# Using the 'CheckIfHireDetailExist' function, we will attempt to add a new record
		# to the SharePoint table. The '$RecAddResult' variable will receive 'Yes' if successful,
		# 'No' if a transmission error occurs, or 'Exists' if the employee already exist in the 
		# SharePoint table. If the update is successful, the 'u_sharepoint_updated' column will  
		# be updated to 'true' in the 'u_stage_itg_onboarding' ServiceNow table and the $HTMLFile 
		# file will be appended with the employee name.
		
		#$RecAddResult = CheckIfHireDetailExist -SNNUmber $SNNum
		
		# Now we analyze the return value of the '$RecAddResult' variable.
		
		# Case #1: A value of 'Yes' is returned:
		# The record was successfully processed and added to the SharePoint table.
		if($RecAddResult -eq "Yes")
		{
			UpdateRecord -SysID $SysID
			if($FoundRecordsToProcess -eq "No")
			{
				$FoundRecordsToProcess = "Yes"
				AddHTMLRecordHeaders -HTMLFile $HTMLFile
			}
		
			# Write summary fields to HTML file.
			Add-Content -Path "$HTMLFile" -Value "  <tr>"
			Add-Content -Path "$HTMLFile" -Value "    <td><p class='Detail_Black_Center'>$NewEmployeeNameName</p></td>"
			Add-Content -Path "$HTMLFile" -Value "      <td><p class='Detail_Black_Center'>$ManagerName</p></td>"
			Add-Content -Path "$HTMLFile" -Value "    <td><p class='Detail_Black_Center'>$DepartmentName</p></td>"
			Add-Content -Path "$HTMLFile" -Value "      <td><p class='Detail_Black_Center'>$StartDate</p></td>"
			Add-Content -Path "$HTMLFile" -Value "  </tr>"
		}

		# Case #2: A value of 'No' is returned.
		# For some reason the data from the record was not transimtted to the SharePoint table
		# correctly and an error message is returned to the console.
		if($RecAddResult -eq "No")
		{
			Write-Host -f Red "Error:" $_.Exception.Message
		}
		
		# Case #3: A value of 'Exists' is returned:
		# There may be times when employees have previously been successfully entered into the 
		# SharePoint table, but for some reason the matching 'u_sharepoint_updated' column in the 
		# ServiceNow table for that employee still reads 'false' when it should be set to 'true'. 
		# This may happen if that ServiceNow record could have accidently had the 'u_sharepoint_updated' 
		# field reset to 'false'. To ensure this record does not get processed again, we will reset
		# that particular 'u_sharepoint_updated' column back to 'true' for this employee without
		# having it re-added to the SharePoint table.
		if($RecAddResult -eq "Exists")
		{
			#UpdateRecord -SysID $SysID
			$AA = 0
		}
	}
}

# If no records were found to process, insert that message into the $HTMLFile file.
if($FoundRecordsToProcess -eq "No")
{
	NoRecordsFoundHTMLMessage -HTMLFile $HTMLFile
}

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
	
# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }