<#
		Program Name: RemoveStaleAzureDeviceEntries.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Provides the option to view, disable or remove devices registered within 
									Azure what have not logged in within a specificed period of time.
#>

#################################################
#    Step 1: Define Prerequisite Variables      #
#################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "EmployeeTransitions"
$SQLTable = "StaleAzureDeviceLoginOptions"
$EncryptionSQLDatabase = "encryptedpasswords"
$EncryptionSQLTable = "encryptedpasswords"
$UnauthorizedList = "UnauthorizedList"
$Script = "RemoveStaleAzureDevicesEntries.ps1"
$ProcessRecord = "Yes"
$Extension = ".xlsx"
$US = "_"

#################################################
#    Step 2: Function Defination Area           #
#################################################

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

function SQLWrite    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MYSQL\Connector NET 8.0\Assemblies\v4.5.2\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$myconnection.Close()
}

function SQLRead    
{
 param(
  [string]$SQLCommand
 )  
 [void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MYSQL\Connector NET 8.0\Assemblies\v4.5.2\MYSql.Data.dll")
 $myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
 $myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
 $myconnection.Open()
 $mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
 $mycommand.Connection = $myconnection
 $mycommand.CommandText = "$SQLCommand"
 $myreader = $mycommand.ExecuteReader()
 $a = while($myreader.Read()){ $myreader.GetString($field) }
 $myconnection.Close()
 $a
}

# Report unauthorized user trying to run this script.
function NotAuthorized    
{
	param(
		[string]$currentUser,
		[string]$Script
	) 
	$DTG = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	SQLReadEncryption -SQLCommand "insert into $UnauthorizedList(CurrentUser,Script,DTG) values ('$currentUser','$Script','$DTG')"
}

###############################################################
#    Step 3: Pull credentials based on user running script.   #
###############################################################

# Pull the correct encrypted credentials based on the user running this script.
$currentUser = $env:UserName

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\PowerShell\credentials\PowerBIUserName.txt"
$EncryptedPasswordFile1 = $null
$EncryptedPasswordFile1 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName1'"
if($EncryptedPasswordFile1 -eq '' -or $EncryptedPasswordFile1 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword1 = Get-Content $EncryptedPasswordFile1 | ConvertTo-SecureString
$UserCreds = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

#################################################
#    Step 4: Ensure SQL Table Exists            #
#################################################

# These commands will only be executed in the rare instance that the 'StaleAzureDeviceLoginOptions' might have been deleted.
# These commands should never be run if the 'StaleAzureDeviceLoginOptions' already exists.
SQLWrite -SQLCommand "create table if not exists $SQLTable(Action varchar(30),ThresholdDays int,WorkSheetBaseName varchar(50),ExcelSpreadsheetFileName varchar(50),ExcelSpreadsheetFileLocation varchar(100),Selected bool)"
$NumRecords = SQLRead -SQLCommand "select count(*) from $SQLTable"
# Set up the 'StaleAzureDeviceOptions' table with defailt options if it was deleted.
if($NumRecords -eq 0)
{
	SQLWrite -SQLCommand "insert into $SQLTable(Action,ThresholdDays,WorkSheetBaseName,ExcelSpreadsheetFileName,ExcelSpreadsheetFileLocation,Selected) values ('VerifyAllStaleDevices',200,'All Stale Device Login Records Review','ReviewAllDeviceLogins','C:\\UtilityScripts\\Reports\\',1)"
	SQLWrite -SQLCommand "insert into StaleAzureDeviceLoginOptions(Action,ThresholdDays,WorksheetBaseName,ExcelSpreadsheetFileName,ExcelSpreadsheetFileLocation,Selected) values ('VerifyDisabledStaleDevices',200,'Disabled Stale Device Login Records Review','ReviewDisabledDeviceLogins','C:\\UtilityScripts\\Reports\\',0)"
	SQLWrite -SQLCommand "insert into StaleAzureDeviceLoginOptions(Action,ThresholdDays,WorksheetBaseName,ExcelSpreadsheetFileName,ExcelSpreadsheetFileLocation,Selected) values ('DisableStaleDevices',200,'Disable All Stale Device Login Records','DisableAllStaleLoginRecords','C:\\UtilityScripts\\Reports\\',0)"
	SQLWrite -SQLCommand "insert into StaleAzureDeviceLoginOptions(Action,ThresholdDays,WorksheetBaseName,ExcelSpreadsheetFileName,ExcelSpreadsheetFileLocation,Selected) values ('RemoveStaleDevices',200,'Remove All Stale Device Login Records','RemoveAllStaleLoginRecords','C:\\UtilityScripts\\Reports\\',0)"
}

#################################################
#    Step 5: Connect to Services                #
#################################################

Connect-MsolService -Credential $UserCreds -ErrorAction SilentlyContinue
$statuscode = (Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc).statuscode
if ($statuscode -ne 200)
{
	Write-Host "No connection ... exiting"
	exit
}

#################################################
#    Step 6: Gather Profile Information         #
#################################################

$ThresholdDays = 0
$WorkSheetBaseName = "All Devices"
$lastLogon = [datetime](get-date).AddDays(- $ThresholdDays)
$Date=("{0:s}" -f (get-date)).Split("T")[0] -replace "-", ""
$Time=("{0:s}" -f (get-date)).Split("T")[1] -replace ":", ""
$date2=("{0:s}" -f ($lastLogon)).Split("T")[0] -replace "-", ""
$ExcelSpreadsheetFileName = $ExcelSpreadsheetFileName + $US + $date2 + $Extension
$FilePath = "C:\\UtilityScripts\\Reports\\AllDevices.xlsx"

#################################################
#    Step 7: Perform Report/Disable/Clean Tasks #
#################################################

#Write-Host "Processing VerifyAllStaleDevices Module"
$DeviceQuery = Get-MsolDevice -all -ReturnRegisteredOwners -LogonTimeBefore $lastLogon|select Enabled, ObjectId, DeviceId, DisplayName, DeviceOsType, DeviceOsVersion, DeviceTrustType, DeviceTrustLevel, ApproximateLastLogonTimestamp, DirSyncEnabled, LastDirSyncTime, @{Name='Registeredowners';Expression={[string]::join(";", ($_.Registeredowners))}}
$DeviceQuery | Export-Excel -workSheetName $WorkSheetBaseName -path $FilePath -ClearSheet -FreezeTopRow -TableName "AADDevicesTable" -TableStyle Medium16 -AutoSize

