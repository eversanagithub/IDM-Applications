<#
		Program Name: ServiceNow-Orchestration-OnPrem.ps1
		Date Written: March 1st, 2023
		  Written By: Dave Jaynes
		 Description: Connects to Azure Table to Complete Work Requested by ServiceNow 
#>

###############################################################
#    Step 1: Assign various local variables.                  #
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$SQLUserName = Get-Content 'C:\powershell\credentials\sqlusername.txt'
$SQLPassword = Get-Content 'C:\powershell\credentials\sqlpassword.txt'
$SQLServer = "10.241.36.13"
$Database = "EmployeeTransitions"
$SQLTable = "ItilUsers"
$EncryptionSQLDatabase = "encryptedpasswords"
$EncryptionSQLTable = "encryptedpasswords"
$UnauthorizedList = "UnauthorizedList"
$Script = "ServiceNow-Orchestration-OnPrem.ps1"

###############################################################
#    Step 2: Define the SQL Read Function.                    #
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
#    Step 3: Pull credentials based on user running script.   #
###############################################################

# Pull the correct encrypted credentials based on the user running this script.
$currentUser = $env:UserName

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\PowerShell\credentials\OrchestrationUsername.txt"
$EncryptedPasswordFile1 = $null
$EncryptedPasswordFile1 = SQLReadEncryption -SQLCommand "select filepath from $EncryptionSQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName1'"
if($EncryptedPasswordFile1 -eq '' -or $EncryptedPasswordFile1 -eq $null)
{
	NotAuthorized -currentUser $currentUser -Script $Script
	exit
}
$serviceAccountPassword1 = Get-Content $EncryptedPasswordFile1 | ConvertTo-SecureString
$azureCredential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)
Connect-AzAccount -Credential $azureCredential

###############################################################
#    Step 4: Designate Azure Storage Table Variables.         #
###############################################################

# Designate variables for use with Azure Storage table for recordkeeping
$resourceGroupName = "esa-dev-auto-rg"
$storageAccountName = "devautostorage"
$tableName = "OnPremOrchestration"
# $accessKey = Get-AutomationVariable -Name 'OneDriveStorageAccountAccessKey'
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$table = (Get-AzStorageTable -Context $storageAccount.context -Name $tableName).CloudTable

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "dave.jaynes@eversana.com,Abdul.Wahid@Eversana.com,Ann.Becker@eversana.com"
[string[]]$to = $recipients.Split(',')

$jobs = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true' and Processed eq 'false'"

###############################################################
#    Step 5: Process all records.                             #
###############################################################

# Begin the process
if ($jobs)
{
	# SMTP Details for Notifications
	$smtpUser = "AzureAutomation@eversana.com"
	$smtpPass = Get-Content "C:\PowerShell\ServiceNow-Orchestration-OnPrem\AzureAutomation.txt" | ConvertTo-SecureString
	$smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser,$smtpPass)
	$fromError = 'AzureAutomation@eversana.com'
	$smtpServer = 'smtp.office365.com'
	$smtpPort = 587

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

			$uriGet = ''
			$uriGet = "https://$instance.service-now.com/api/now/table/u_stage_sc_request?sysparm_query=sys_id%3D$sysID"

			$record = ''
			$record = (Invoke-RestMethod -Headers $headers -Method Get -Uri $uriGet).result
            
			# Trigger appropriate script or action based on catalogTask name
			Switch ($catalogTask)
			{
				'OnPrem'
				{
					# Get the variables
					$variables = ''
					$variables = ($record.u_variables).split("|")
					$variable1 = $variables[0]

					# Do the actions
					Write-Host "Doing the action $variable1"
                                        
					# Get current processed date
					$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

					# Update Azure storage table
					$job.Processed = 'true'
					$job | Update-AzTableRow -table $table

					# Specify request body
					$bodyJSON = '{"u_return_code":"200","u_processed":"'+$date+'"}'

					# Send HTTP request
					$uriPut = ''
					$uriPut = "https://$instance.service-now.com/api/now/table/u_stage_sc_request/$sysID" 
					Invoke-RestMethod -Headers $headers -Method Put -Uri $uriPut -Body $bodyJSON
				}
				'Mobile Device Access Request'
				{
					# Get the variables
					$variables = ''
					$variables = ($record.u_variables).split("|")
					# User variable
					$variable1 = $variables[0]

					# Group to add user
					$groupGUID = "e9f6eb0e-2a50-4f2c-910b-982641274b20"
					$groupName = "Office365_Intune_AttestationComplete"

					# Get user details
					$userGUID = ''
					$userGUID = (Get-ADUser -filter {userPrincipalName -eq $variable1}).ObjectGUID.GUID

					if (($userGUID -eq $null) -or ($userGUID -eq ''))
					{
						$userGUID = (Get-ADUser -filter {mail -eq $variable1}).ObjectGUID.GUID
					}

					# Do the actions
					Write-Host "Adding $variable1 to group $groupName"
					Write-Host "Adding $userGUID to group $groupName"

					# Get current processed date
					$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

					# Update Azure storage table
					$job.Processed = 'true'
					$job | Update-AzTableRow -table $table

					# Specify request body
					$bodyJSON = '{"u_return_code":"200","u_processed":"'+$date+'"}'

					# Send HTTP request
					$uriPut = ''
					$uriPut = "https://$instance.service-now.com/api/now/table/u_stage_sc_request/$sysID" 
					Invoke-RestMethod -Headers $headers -Method Put -Uri $uriPut -Body $bodyJSON
				}
				'DUO'
				{
					# Get variables
					$uriGet = ''
					$uriGet = "https://$instance.service-now.com/api/now/table/u_stage_sc_request?sysparm_query=sys_id%3D$sysID"
					$record = ''
					$record = (Invoke-RestMethod -Headers $headers -Method Get -Uri $uriGet).result
					# Split out variables
					$variables = $record.u_variables.split("|")
					$email = $variables[0]
					$realname = $variables[1]
					$number = $variables[2]
					$platform = $variables[3]

					$userGUID = ''
					$userGUID = (Get-ADUser -filter {(userPrincipalName -eq $email) -or (mail -eq $email)}).ObjectGUID.GUID

					$techGUIDs = (Get-ADGroupMember -Recursive 'IT Dept - All-1111362042').ObjectGUID
					if ($techGUIDs -contains $userGUID)
					{
						# Add-ADGroupMember -Identity Eversana_VPN_IT_Global -Members $userGUID -Confirm:$false
					}
					else
					{
						# Add-ADGroupMember -Identity Eversana_VPN_Employees_Global -Members $userGUID -Confirm:$false
					}

					# Update Azure storage table
					$job.Processed = 'true'
					$job | Update-AzTableRow -table $table
				}
				Default
				{
					$subject = "Unknown OnPrem Task Encountered: " + $catalogTask
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
                The "ServiceNow-Orchestration-OnPrem" script has encountered a catalog item with no processing instructions. Please investigate and respond accordingly.<br/>
                <br/>
                <hr>
                <b>Catalog Item Details</b><br/>
                    Request Item: $requestItem<br/>
                    Catalog Task: $catalogTask<br/>
                    SysID: $sysID<br/>
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
						-SmtpServer $SmtpServer `
						-Port $SmtpPort `
						-credential $SmtpCredential

					# Update Azure storage table
					$job.Processed = 'error'
					$job | Update-AzTableRow -table $table

					# Terminate the script
					Exit
				}
			}
		}
		Catch
		{
			$subject = "Error Experienced Processing OnPrem Orchestration For: " + $requestItem + "-" + $catalogTask
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
                An error has been experienced processing OnPrem Orchestation from ServiceNow. Please investigate and respond accordingly.<br/>
                <br/>
                <hr>
                <b>Catalog Item Details</b><br/>
                    Request Item: $requestItem<br/>
                    Catalog Task: $catalogTask<br/>
                    SysID: $sysID<br/>
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
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-credential $SmtpCredential

			# Update Azure storage table
			$job.Processed = 'error'
			$job | Update-AzTableRow -table $table
		}
	}
}

Disconnect-AzAccount