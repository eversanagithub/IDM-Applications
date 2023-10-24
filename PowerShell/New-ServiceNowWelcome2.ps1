<#
		Program Name: ServiceNowToSharePoint.ps1
		Date Written: February 9th, 2023
		  Written By: Dave Jaynes
		 Description: Automated Process to Welcome Users to ServiceNow 
									Assigned the "ITIL" Role for the First Time.
#>

###############################################################
#    Step 1: Assign various local variables.                  #
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$HTMLFile = "C:\temp\HTMLFile.txt"
$SQLTable = "itilusers"
$Dash = '-'

# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }

###############################################################
#    Step 2: Set up HTML E-Mail message file.                 #
###############################################################

function BaseEMailMessage
{
	param(
		[string]$firstName,
		[string[]]$groups
	)  
	Add-Content -Path $HTMLFile -Value "<html>"
	Add-Content -Path $HTMLFile -Value "<head>"
	Add-Content -Path $HTMLFile -Value "<style>"
	Add-Content -Path $HTMLFile -Value "p.NameText {"
	Add-Content -Path $HTMLFile -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path $HTMLFile -Value "        color: black;"
	Add-Content -Path $HTMLFile -Value "    font-size: 17px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: normal;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.Highlight {"
	Add-Content -Path $HTMLFile -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path $HTMLFile -Value "        color: blue;"
	Add-Content -Path $HTMLFile -Value "    font-size: 17px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: normal;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.AlertText {"
	Add-Content -Path $HTMLFile -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path $HTMLFile -Value "        color: red;"
	Add-Content -Path $HTMLFile -Value "    font-size: 17px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: normal;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.SummaryText {"
	Add-Content -Path $HTMLFile -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path $HTMLFile -Value "        color: green;"
	Add-Content -Path $HTMLFile -Value "    font-size: 20px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: normal;"
	Add-Content -Path $HTMLFile -Value "text-decoration: underline;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.DetailText {"
	Add-Content -Path $HTMLFile -Value "  font-family: 'Times New Roman', Times, serif;"
	Add-Content -Path $HTMLFile -Value "        color: black;"
	Add-Content -Path $HTMLFile -Value "    font-size: 16px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: normal;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.HeaderText {"
	Add-Content -Path $HTMLFile -Value "  font-family: Arial, Helvetica, sans-serif;"
	Add-Content -Path $HTMLFile -Value "        color: Black;"
	Add-Content -Path $HTMLFile -Value "    font-size: 30px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: bold;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "</style>"
	Add-Content -Path $HTMLFile -Value "</head>"
	Add-Content -Path $HTMLFile -Value "<body>"
	Add-Content -Path $HTMLFile -Value "<center>"
	Add-Content -Path $HTMLFile -Value "<table width=100%>"
	Add-Content -Path $HTMLFile -Value "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</center>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='NameText'>$firstName,</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='Highlight'>Welcome to the ServiceNow platform!</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>You have been successfully added to the requested ServiceNow support group</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>Group(s): $groups</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='SummaryText'>What Is It?</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>To our customers (EVERSANA Business) the tool is the IT Service Desk portal.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>To you and I, the 'doers' (more commonly called ITIL Fulfiller), it is often just referred to as ServiceNow.</p></td></tr>" 
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>This platform serves as the mechanism for us to service our customers (EVERSANA Business) for all their application and technology needs, primarily IT support.</p></td></tr>"  
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>ServiceNow is used as our overall (ITSM) IT Service Management solution for all IT Changes, Incidents and Requests.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>ITSM / ITIL is more than just ServiceNow.  You will be expected to understand ITSM / ITIL and how ServiceNow plays a role in our operational support model.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='SummaryText'>How Do I Get Training?</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>Training will be provided via ComplianceWire NEW hire training sessions and / or renewed annually as a refresher course.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>EVERSANA IT Service Management (foundations) is a (3) part courses containing:</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"

	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'><ul><li><b>EVERSANA IT Service Management $Dash ITSM and ITIL Overview (Foundation) (ITSM 1)</b></li></ul></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'><ul><li><b>EVERSANA IT Service Management $Dash Introduction to Incident Management (ITSM 2)</b></li></ul></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'><ul><li><b>EVERSANA IT Service Management $Dash Introduction to Change Control (ITSM 3)</b></li></ul></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>Prior to performing specific aspects of your role, you will be required to complete these courses.</p></td></tr>"  

	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>If you have not received this training for your role regarding Incident or Change, please email compliancewire@eversana.com and request the ITSM package to be assigned.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='SummaryText'>What Role Will I Have?</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>You are identified as an ITIL Fulfiller, you have been given access to the 'backend' of the platform.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>This role allows you to open, modify and close various types of Requests, Incidents and Changes.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='SummaryText'>Links To Access ServiceNow Platform</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'><ul><li>As an ITIL Fulfiller, you will need access to backend of platform:" 
	Add-Content -Path $HTMLFile -Value "<a href='https://eversana.service-now.com/'>"
	Add-Content -Path $HTMLFile -Value "https://eversana.service-now.com/</a></li></ul></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'><ul><li>As a customer, you can access our customer portal:"
	Add-Content -Path $HTMLFile -Value "<a href='https://eversana.service-now.com/sp'>"
	Add-Content -Path $HTMLFile -Value "https://eversana.service-now.com/sp</a></li></ul></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='DetailText'>Feel free to use the IT Service Desk Portal for additional resources and assistance.</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='NameText'>Thank you and welcome aboard the team that strives for top notch customer service!</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='Highlight'><b>ServiceNow Support Team</b></p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</body>"
	Add-Content -Path $HTMLFile -Value "</html>"
}

function SQLRead    
{
	param(
		[string]$SQLCommand
	)  
	$connStr = @"
	DSN=ProdDBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQLCommand, $con
	$rdr = $cmd.ExecuteReader()
	$rdr
}

function SQLWrite
{
	param(
		[string]$SQLCommand
	)
	$connStr = @"
	DSN=ProdDBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQLCommand, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

###############################################################
#    Step 4: Pull credentials based on user running script.   #
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
#    Step 5: Connect to Azure services.                       #
###############################################################

# Connect to AzAccount for access to Storage Tables
Connect-AzAccount -Credential $credential1|Out-File -Filepath C:\temp\junk.txt

# Connect to Azure Active Directory
Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\temp\junk.txt

###############################################################
#    Step 6: Build Auth Header and Request for ServiceNow API #
###############################################################

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
			
	# Get previous list of ITIL users
	[String[]]$itilUsersPrevious = SQLRead -SQLCommand "select itiluser from $SQLTable"
	if ($itilUsersPrevious -eq $null)
	{
		throw new Exception('The $itilUsersPrevious variable is null.')
	}

	$notifies = @()

	foreach ($itilUser in $itilUsers)
	{
		if ($itilUsersPrevious -notcontains $itilUser)
		{
			$notifies += $($results | Where-Object {$_.user_name -eq $itilUser})
		}
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
					$groups += $group
				}
			}
			
			$groups = $groups | Sort-Object
			if ($groups.count -gt 1)
			{
				$groups = $groups -join ", " | Out-String
			}
			else 
			{
				$groups = $groups | Out-String
			}

			# Load up the HTML file
			BaseEMailMessage -firstName $firstName -groups $groups
			
			# Set the recipient and body of the email
			$to = $notify.user_name
			$body = Get-Content $HTMLFile -Raw
			<#
			Send-MailMessage `
				-From $from `
				-UseSsl `
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-To $to `
				-Subject $subject `
				-Body $body `
				-BodyAsHtml `
				-credential $SmtpCredential
			#>
		}
	}
	# Add this user to the itilusers SQL table so they will not receive this message again.
	#SQLWrite -SQLCommand "insert into $SQLTable(itiluser) values ('$UPN')"
}
Catch
{
	$AA = 0
}

###############################################################
#   Step 8: Disconnect from services.                        #
###############################################################

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk.txt

