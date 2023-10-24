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

# Set SQL connection parameters
$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw

# Define SQL table names
$SQLServer = "10.241.36.13"
$SQLTable = "SNtoSPDevandProdValues"
$DevOrProd = "SNtoSPDevOrProd"
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

# Set up the SQL Encryption Read function
function SQLReadEncryption   
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\Connector NET 8.0\Assemblies\v4.5.2\\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$EncryptionSQLDatabase;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$SQLReturnValue = while($myreader.Read()){ $myreader.GetString($field) }
	$myconnection.Close()
	$SQLReturnValue
}

# Set up the SQL Read single field function
function SQLQuery    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\Connector NET 8.0\Assemblies\v4.5.2\\MYSql.Data.dll")
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

# Report unauthorized user trying to run this script.
function NotAuthorized    
{
	param(
		[string]$currentUser,
		[string]$Script
	) 
	$DTG = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Host "currentUser = [$currentUser], Script = [$Script], DTG = [$DTG]"
	SQLReadEncryption -SQLCommand "insert into $UnauthorizedList(CurrentUser,Script,DTG) values ('$currentUser','$Script','$DTG')"
}

###############################################################
#    Step 3: Load ServiceNow/SharePoint variables.            #
###############################################################

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

###############################################################
#    Step 4: Pull credentials based on user running script.   #
###############################################################

# Pull the correct encrypted credentials based on the user running this script.
$currentUser = $env:UserName

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\PowerShell\credentials\O365UserName.txt"
$EncryptedPasswordFile1 = $null
$EncryptedPasswordFile1 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName1'"
if($EncryptedPasswordFile1 -eq '' -or $EncryptedPasswordFile1 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword1 = Get-Content $EncryptedPasswordFile1 | ConvertTo-SecureString
$AzureADCredential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

# Create the credentials for ServiceNow PowerShell Integration
$serviceAccountUserName2 = Get-Content "C:\PowerShell\credentials\PowerShell_Integration_UserName.txt"
$EncryptedPasswordFile2 = $null
$EncryptedPasswordFile2 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName2'"
if($EncryptedPasswordFile2 -eq '' -or $EncryptedPasswordFile2 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword2 = Get-Content $EncryptedPasswordFile2 | ConvertTo-SecureString
$PS_Integ_Credential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Create the credentials for SharePoint
$serviceAccountUserName3 = Get-Content "C:\PowerShell\credentials\Eversana_Sharepoint_Username.txt"
$EncryptedPasswordFile3 = $null
$EncryptedPasswordFile3 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName3'"
if($EncryptedPasswordFile3 -eq '' -or $EncryptedPasswordFile3 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword3 = Get-Content $EncryptedPasswordFile3 | ConvertTo-SecureString
$Cred = New-Object System.Management.Automation.PSCredential($serviceAccountUserName3,$serviceAccountPassword3)
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SharePointURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

#################################################################
#    Step 5: Create the 'SharePointRecordInfo' table if missing #
#################################################################

function RecreateSharePointRecordInfo
{
	SQLQuery -SQLCommand "create table if not exists $SharePointRecordInfo(NewHireName varchar(60),JobTitle varchar(80),Department varchar(80),Manager varchar(60),SeatLocation varchar(40),Client varchar(200),Brand varchar(200) ,NameOfReferral varchar(60),AdditionalInfo varchar(200),Portofolio varchar(60),ShareAccessNeeded varchar(120),D365RoleID varchar(80),ServiceNowNum varchar(20),Team varchar(60),Location varchar(120),Affiliates varchar(60),Status varchar(60),WorkplaceOption varchar(40),Pronouns varchar(30),EmployeeLocation varchar(200),TrainingRequested varchar(300),StartDate varchar(30),AccessToInflight varchar(6))"
}

#################################################################
#    Step 6: Add record to 'SharePointRecordInfo' SQL table     #
#################################################################

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

#################################################################
#    Step 7: Create the HTML E-Mail files                       #
#################################################################

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
#    Step 9: Perform the REST API call into the ServiceNow      #
#################################################################

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
		Credential = $PS_Integ_Credential
	}

	# Kick off the REST API call to ServiceNow.
	$ServiceNowRecords = (Invoke-RestMethod @Params).Result

	# Return the API call results to the function call command.
	return $ServiceNowRecords
}

##################################################################
#    Step 10: Check If Hire Detail Exist within SharePoint table #
##################################################################

function CheckIfHireDetailExist{
	Param(
		$SNNUmber
	)
	$Exists = "Exists"

	#Get the List
	$List=$Ctx.Web.Lists.GetByTitle($ListName)

	$date = [DateTime]"07/26/2022" # Should this be $SNR.ConfirmedStartDate
	$StartDate = $date.ToString("yyyy-MM-ddTHH:mm:ssZ")
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$Query.ViewXml = "@
		<View>
			<Query>
				<Where>
					<Eq>
						<FieldRef Name='ServiceNowNumber' />
						<Value Type='Text'>$SNNUmber</Value>
					</Eq>
				</Where>
			</Query>
		</View>"
 
	#Get List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
 
	if($ListItems.count -eq 0)
	{
		AddToList
	}
	else
	{
		return $Exists
	}
}

#################################################################
#    Step 11: Add ServiceNow data to SharePoint list table      #
#################################################################

function AddToList{
	$Success = "Yes"
	$Unsuccessful = "No"
	Try 
	{
		$startDateStr = $SNR.u_start_date
		$StartDate = [datetime]"$startDateStr 00:00:00 -6:00"
		$TrainingRequestedArray = $SNR.u_training_requested -split "\|"
		$AllTrainingRequestedOptions = @($TrainingRequestedArray)
		$thisD365Role_ID = $SNR.u_d365_role_id
		$thisOtherRole = $SNR.u_other_role
		$thisWorkFront = $SNR.u_workfront_access_needed
		if($thisD365Role_ID -eq '' -or $thisD365Role_ID -eq $null)
		{
			$thisD365Role_ID = $thisOtherRole
		}
		if($thisWorkFront -eq "Yes")
		{
			$BWF = 'true'
		}
		else
		{
			$BWF = 'false'
		}
		
		# Assign ServiceNow field values to local variables
		$thisNewHireName = $SNR.u_new_hire_name 						# New Hire Name
		$thisJobTitle = $SNR.u_job_title   								# Job Title
		$thisDepartment = $SNR.u_service_line   							# Department
		$thisManager = $SNR.u_manager  									# Manager
		$thisSeatLocation = $SNR.u_seat_location    					# Seat Location
		$thisClient = $SNR.u_client  									# Client
		$thisBrand = $SNR.u_brand  										# Brand
		$thisNameOfReferral = $SNR.u_name_of_referral  					# Name of referral
		$thisAdditionalInfo = $SNR.u_additional_information				# Notes
		$thisPortofolio = $SNR.u_portfolio  							# Portfolio
		$thisShareAccessNeeded = $SNR.u_creative_share_access_needed  	# Creative Share Access Needed
		$thisD365RoleID = $SNR.u_d365_role_id  							# D365RoleID
		$thisServiceNowNum = $SNR.u_requested_item  					# ServiceNow Number
		$thisTeam = $SNR.u_team  										# Team
		$thisServicingOffice = $SNR.u_servicing_office  				# Servicing Office / Location
		$thisAffiliates = $SNR.u_affiliate  							# Intouch Division/Email Domain
		$thisStatus = $SNR.u_user_status  								# Status
		$thisWorkplaceOption = $SNR.u_workplace_option  				# Workplace Option
		$thisPronouns = $SNR.u_pronouns  								# Pronouns
		$thisEmployeeLocation = $SNR.u_employee_location  				# Employee Location

		#Get the List
		$List=$Ctx.Web.Lists.GetByTitle($ListName)
		
		#Add list item
		$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
		$ListItem = $List.AddItem($ListItemInfo)
		
		#Set Column Values
		$ListItem[$NewHireName] = $thisNewHireName
		$ListItem[$JobTitle] = $thisJobTitle
		$ListItem[$Department] = $thisDepartment
		$ListItem[$Manager] = $thisManager
		$ListItem[$SeatLocation] = $thisSeatLocation
		$ListItem[$Client] = $thisClient
		$ListItem[$Brand] = $thisBrand
		$ListItem[$NameOfReferral] = $thisNameOfReferral
		$ListItem[$AdditionalInfo] = $thisAdditionalInfo
		$ListItem[$Portofolio] = $thisPortofolio
		$ListItem[$ShareAccessNeeded] = $thisShareAccessNeeded
		$ListItem[$D365RoleID] = $thisD365RoleID
		$ListItem[$ServiceNowNum] = $thisServiceNowNum
		$ListItem[$Team] = $thisTeam

		#Set Choice Field value
		$ListItem[$ServicingOffice] = $thisServicingOffice
		$ListItem[$Affiliates] = $thisAffiliates
		$ListItem[$Status] = $thisStatus
		$ListItem[$WorkplaceOption] = $thisWorkplaceOption
		$ListItem[$Pronouns] = $thisPronouns
		$ListItem[$EmployeeLocation] = $thisEmployeeLocation
		$ListItem[$TrainingRequested] = $AllTrainingRequestedOptions
        
		#Set Date Fields
		$ListItem[$StartingDate] = $StartDate

		# Set WorkFront Field
		$ListItem[$AccessToInflight] = $BWF
     
		#Apply changes to list
		$ListItem.Update()
		$Ctx.ExecuteQuery()
		
		# Add these fields to the SharePointRecordInfo SQL table
		AddRecToSharePointRecordInfo -NewHireName $thisNewHireName `
									 -JobTitle $thisJobTitle `
									 -Department $thisDepartment `
									 -Manager $thisManager `
									 -SeatLocation $thisSeatLocation `
									 -Client $thisClient `
									 -Brand $thisBrand `
									 -NameOfReferral $thisNameOfReferral `
									 -AdditionalInfo $thisAdditionalInfo `
									 -Portofolio $thisPortofolio `
									 -ShareAccessNeeded $thisShareAccessNeeded `
									 -D365RoleID $thisD365RoleID `
									 -ServiceNowNum $thisServiceNowNum `
									 -Team $thisTeam `
									 -Location $thisServicingOffice `
									 -Affiliates $thisAffiliates `
									 -Status $thisStatus `
									 -WorkplaceOption $thisWorkplaceOption `
									 -Pronouns $thisPronouns `
									 -EmployeeLocation $thisEmployeeLocation `
									 -TrainingRequested $AllTrainingRequestedOptions `
									 -StartDate $StartDate `
									 -AccessToInflight $BWF
							 
		return $Success
	}
	Catch 
	{
		Write-Host -f Red "Error:" $_.Exception.Message
		return $Unsuccessful
	}
}

#################################################################
#    Step 12: Main processing area                              #
#################################################################

# Ensure the SharePointRecordInfo table exists.
RecreateSharePointRecordInfo

# Write the HTML heading to the $HTMLFile file.
CreateHTMLHeading -HTMLFile $HTMLFile

# Call the 'Get-ServiceNowTable' function with required parameters.

$ServiceNowRecords = Get-ServiceNowTable -Table $SNTable -Query $Query -ServiceNowURL $ServiceNowURL
# Walk through the API return payload and process the data accordingly.
$ServiceNowRecords | %{
	$SNR = $_
	$SysID = $SNR.sys_id
	$SNNum = $SNR.u_requested_item
	$RecordUpdated = $SNR.u_sharepoint_updated
	$NewEmployeeNameName = $SNR.u_new_hire_name
	$ManagerName = $SNR.u_manager
	$DepartmentName = $SNR.u_service_line
	$StartDate = $SNR.u_start_date
	Write-Host "SysID = [$SysID], RecordUpdated = [$RecordUpdated]"
	# If '$RecordUpdated' is set to 'false', this is newly added record.
	if($RecordUpdated -eq "false")
	{
		# Using the 'CheckIfHireDetailExist' function, we will attempt to add a new record
		# to the SharePoint table. The '$RecAddResult' variable will receive 'Yes' if successful,
		# 'No' if a transmission error occurs, or 'Exists' if the employee already exist in the 
		# SharePoint table. If the update is successful, the 'u_sharepoint_updated' column will  
		# be updated to 'true' in the 'u_stage_itg_onboarding' ServiceNow table and the $HTMLFile 
		# file will be appended with the employee name.
		
		$RecAddResult = CheckIfHireDetailExist -SNNUmber $SNNum
		
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
			UpdateRecord -SysID $SysID
		}
	}
}

# If no records were found to process, insert that message into the $HTMLFile file.
if($FoundRecordsToProcess -eq "No")
{
	NoRecordsFoundHTMLMessage -HTMLFile $HTMLFile
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
	
# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }