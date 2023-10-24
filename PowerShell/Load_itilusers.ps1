<#
		Program Name: Load_Feed_ServiceNow_UsersGroups.ps1
		Date Written: August 2nd, 2023
		  Written By: Dave Jaynes
		 Description: Automated Process to Welcome Users to ServiceNow 
									Assigned the "ITIL" Role for the First Time.
#>

###############################################################
#    Step 1: Assign various local variables.                  #
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$HTMLFile = "C:\temp\HTMLFile2.txt"
$SN_Welcome_Msg = "C:\UtilityScripts\Reports\ServiceNow_Welcome_Message.docx"
$SQLTable = "itilusers"
$Dash = '-'

###############################################################
#    Step 2: Pull credentials based on user running script.   #
###############################################################

# Create the credentials for AzAccount
$serviceAccountUserName1 = Get-Content "C:\PowerShell\credentials\PowerBIUserName.txt"
$serviceAccountPassword1 = Get-Content "C:\PowerShell\credentials\EncryptedPowerBiPassword_dave_jaynes.txt" | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName1,$serviceAccountPassword1)

# Create the credentials for AzureAD
$serviceAccountUserName2 = Get-Content "C:\PowerShell\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\PowerShell\credentials\EncryptedOneDriveRetentionPassword_dave_jaynes.txt" | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)

# Connect to AzAccount for access ServiceNow
$serviceAccountUserName3 = Get-Content "C:\PowerShell\credentials\PowerShell_Integration_UserName.txt"
$serviceAccountPassword3 = Get-Content "C:\PowerShell\credentials\EncryptedPowershellIntegrationPassword_dave_jaynes.txt" | ConvertTo-SecureString
$apiCredential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName3,$serviceAccountPassword3)

# Credentials for SMTP Mail authentication.
$serviceAccountUserName4 = Get-Content "C:\PowerShell\credentials\AzureAutomationUserName.txt"
$serviceAccountPassword4 = Get-Content "C:\PowerShell\credentials\EncryptedAzureAutomationPassword_dave_jaynes.txt" | ConvertTo-SecureString
$SmtpCredential = New-Object System.Management.Automation.PSCredential($serviceAccountUserName4,$serviceAccountPassword4)

###############################################################
#    Step 3: Clear out Feed_Service_UsersGroups               #
###############################################################

function ClearServiceNowTable {
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "delete from itilusers"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

###############################################################
#    Step 4: Load Feed_Service_UsersGroups                    #
###############################################################

function LoadServiceNowTable {
	Param (
		[string]$UserID,
		[string]$GroupName
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "insert into itilusers(itiluser) values ('$UserID')"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

###############################################################
#    Step 5: Connect to Azure services.                       #
###############################################################

# Connect to AzAccount for access to Storage Tables
Connect-AzAccount -Credential $credential1|Out-File -Filepath C:\temp\junk22.txt

# Connect to Azure Active Directory
Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\temp\junk22.txt

###############################################################
#    Step 6: Build Auth Header and Request for ServiceNow API #
###############################################################

ClearServiceNowTable  # Remove all rows
$user = $apiCredential.UserName
$pass = $apiCredential.GetNetworkCredential().Password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
# Specify instance
$instance = "eversana"
# Specify endpoint uri to get ITIL users
$uri = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=roles%3Ditil"
# Specify HTTP method
$method = "get"

### Designate variables for notification
#$from = 'EVERSANA Service Desk <noReply@Eversana.com>'
$fromError = 'AzureAutomation@eversana.com'
$from = 'EVERSANA Service Desk <AzureAutomation@eversana.com>'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587
$subject = "Welcome To ServiceNow!"

###############################################################
#    Step 7: Process ITIL users and send applicable notifies  #
###############################################################

### Begin process to analyze ITIL users and send any applicable notifications
try
{
	# Send HTTP request
	$response = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
	$results = $response.result | Where-Object {$_.user_name -like "*@eversana*"}
	$itilUsers = $results.user_name | Select-Object -Unique $_
	
	$notifies = @()

<#
LoadServiceNowTable -UserID @{calendar_integration=1; country=; last_login_time=2023-08-14 07:14:57; source=; sys_updated_on=2023-05-05 14:33:59; building=; web_service_access_only=false; notification=2; enable_multifactor_authn=false; sys_updated_by=AzureADSSO; sso_sour
ce=; sys_created_on=2021-01-22 15:32:18; sys_domain=; state=; vip=false; sys_created_by=AzureADSSO; u_local_admin=false; zip=; home_phone=; time_format=; last_login=2023-08-14; active=true; sys_domain_path=/; u_ismanager=Yes; cost_center=; phone=; name=Vivek Rathod; empl
oyee_number=120152; u_department=D&A Integrated; gender=; city=; failed_attempts=0; user_name=Vivek.Rathod@eversana.com; roles=; u_user_status=FTE|; title=Associate Director; sys_class_name=sys_user; sys_id=12763fe21b756010c49ca9bfbd4bcbb2; internal_integration_user=fals
e; mobile_phone=; street=; company=; department=; first_name=Vivek; email=Vivek.Rathod@Eversana.com; introduction=; preferred_language=; manager=; sys_mod_count=50; last_name=Rathod; photo=; avatar=; middle_name=; sys_tags=; time_zone=IST; schedule=; date_format=; locati
on=; u_location=India; u_business_unit_ref=; u_business_unit=Data & Analytics} -GroupName Data & Analytics - Dashboards
#>

	foreach ($itilUser in $itilUsers)
	{
		$notifies += $($results | Where-Object {$_.user_name -eq $itilUser})
	}

	if ($notifies.count -gt 0)
	{
		# Get a list of all ITIL groups
		$itilGroups = @()
		$itilGroupsURI = "https://$instance.service-now.com/api/now/table/sys_group_has_role?sysparm_query=role.name%3Ditil"
		$itilGroupLinks = (Invoke-RestMethod -Headers $headers -Method $method -Uri $itilGroupsURI).result.group.Link
		foreach ($itilGroupLink in $itilGroupLinks)
		{
			$itilGroup = (Invoke-RestMethod -Headers $headers -Method $method -Uri $itilGroupLink).result.name
			$itilGroups += $itilGroup
		}
		$itilGroups = $itilGroups | Sort-Object

		foreach ($notify in $notifies)
		{
			# Get all ITIL groups for the specific user to notify
			$groups = @()
			$userSysID = $notify.sys_id
			$firstName = $notify.first_name
			$UPN = $notify.user_name
			$groupsURI = "https://$instance.service-now.com/api/now/table/sys_user_grmember?sysparm_query=user%3D$userSysID"
			$groupLinks = (Invoke-RestMethod -Headers $headers -Method $method -Uri $groupsUri).result.group.link
			foreach ($groupLink in $groupLinks)
			{
				$group = ''
				$group = (Invoke-RestMethod -Headers $headers -Method $method -Uri $groupLink).result.name
				if ($itilGroups -contains $group)
				{
					if($notify -ne '' -and $notify -ne $null -and $group -ne '' -and $group -ne $null)
					{
						$thisUPN = $UPN -replace("'","''")
						LoadServiceNowTable -UserID $thisUPN -GroupName $group
					}
				}
			}
		}
	}
}
Catch
{
	$AA = 0
}

###############################################################
#   Step 8: Disconnect from services.                        #
###############################################################

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk2.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk2.txt

# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }