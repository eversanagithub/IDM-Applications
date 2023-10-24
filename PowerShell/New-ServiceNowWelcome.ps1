<#
		Program Name: New-ServiceNowWelcome.ps1
		Date Written: August 2nd, 2023
		  Written By: Dave Jaynes
		 Description: Automated Process to Welcome Users to ServiceNow 
									Assigned the "ITIL" Role for the First Time.
#>

###############################################################
#    Step 0: Assign various local variables.                  #
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$HTMLFile = "C:\temp\HTMLFile2.txt"
$SN_Welcome_Msg = "C:\UtilityScripts\Reports\ServiceNow_Welcome_Message.docx"
$SQLTable = "itilusers"
$Dash = '-'

#########################################################################
#    Step 1: Ensure the user's full name has first letter in caps.      #
#########################################################################
function ConfirmNameInProperFormat
{
	Param (
		[string]$UserID
	)
	# Parse out the terminated employee's first and last name for aesthetics purposes.
	$firstName = $UserID.split("@")[0].split(".")[0]
	$lastName = $UserID.split("@")[0].split(".")[1]
	$space = ' '
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$niceLastName = ''
	for($i=0;$i -lt $lastName.length;$i++)
	{
		$x = $lastName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceLastName = $niceLastName + $x
	}
	$niceEmployeeName = $niceFirstName + $space + $niceLastName
	return $niceEmployeeName
}
	
###############################################################
#    Step 2: Set up HTML E-Mail message file.                 #
###############################################################

function BaseEMailMessage
{
	param(
		[string]$NiceName
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
	Add-Content -Path $HTMLFile -Value "p.Arial_Black_24 {"
	Add-Content -Path $HTMLFile -Value "  font-family: Arial;"
	Add-Content -Path $HTMLFile -Value "        color: black;"
	Add-Content -Path $HTMLFile -Value "    font-size: 24px;"
	Add-Content -Path $HTMLFile -Value "   font-style: normal;"
	Add-Content -Path $HTMLFile -Value "  font-weight: bold;"
	Add-Content -Path $HTMLFile -Value "}"
	Add-Content -Path $HTMLFile -Value "p.Arial14 {"
	Add-Content -Path $HTMLFile -Value "  font-family: Arial;"
	Add-Content -Path $HTMLFile -Value "        color: black;"
	Add-Content -Path $HTMLFile -Value "    font-size: 18px;"
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
	Add-Content -Path $HTMLFile -Value "<tr><td><img src='http://iuatidmgmtapp01/images/service-now-Logo.jpg' width='545' height='85'></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</center>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table width='100%'>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='Arial_Black_24'>Welcome to ServiceNow, $NiceName!</p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table>"
	Add-Content -Path $HTMLFile -Value "<tr><td><p class='Arial14'>You have been added to a ServiceNow support group granting you 'fulfiller' access. </p></td></tr>"
	Add-Content -Path $HTMLFile -Value "</table>"
	Add-Content -Path $HTMLFile -Value "</br>"
	Add-Content -Path $HTMLFile -Value "<table width='100%'>"
}

###############################################################
#    Step 3: List Groups user is being added to               #
###############################################################

function DisplayGroups {
	Param (
		[string]$UserID,
		[string]$GroupName
	)
	Add-Content -Path $HTMLFile -Value "<tr><td><li><p class='Arial14'>$GroupName</p></li></td></tr>"
}

###############################################################
#    Step 4: Fill in the HTML file with template.             #
###############################################################

function WriteHTMLBody
{
	$contents = Get-Content -Path C:\UtilityScripts\Reports\New-ServiceNowWelcome_HTML.txt
	$contents.forEach({
		$line = $_
		Add-Content -Path $HTMLFile -Value $line
	})
}

###############################################################
#    Step 5: Set up generic SQL read and write functions      #
###############################################################

function SQLRead    
{
	param(
		[string]$SQLCommand
	)  
	$connStr = @"
	DSN=DBWebConnection;
"@
	$users = @()
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$cmd = New-Object System.Data.Odbc.OdbcCommand $SQLCommand, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$user = $rdr["itiluser"]
		$users += $user
	}
	$rdr.Close()
	$con.Close()
	return $users
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
#    Step 6: Pull credentials based on user running script.   #
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
#    Step 7: Connect to Azure services.                       #
###############################################################

# Connect to AzAccount for access to Storage Tables
Connect-AzAccount -Credential $credential1|Out-File -Filepath C:\temp\junk22.txt

# Connect to Azure Active Directory
Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\temp\junk22.txt

###############################################################
#    Step 8: Build Auth Header and Request for ServiceNow API #
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
#    Step 9: Process ITIL users and send applicable notifies  #
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
			$TotalItilGroups = 0
			# Get all ITIL groups for the specific user to notify
			$groups = @()
			$userSysID = $notify.sys_id
			$NiceName = $notify.name
			
			# Remove $HTMLFile file so this user gets a clean page.
			$DoesFileExist = Test-Path $HTMLFile
			if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }
			
			# Create the heading of the HTML file
			BaseEMailMessage -NiceName $NiceName
			
			#$NiceName = ConfirmNameInProperFormat -UserID $fullName
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
						$TotalItilGroups++
						$thisUPN = $UPN -replace("'","''")
						DisplayGroups -UserID $thisUPN -GroupName $group
					}
				}
			}
			WriteHTMLBody
			
			if($TotalItilGroups -ne 0)
			{
				# Set the recipient and body of the email
				#$to = $notify.user_name
				$to = 'ted.schuette@eversana.com'
				$body = Get-Content $HTMLFile -Raw
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
			}
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
#   Step 10: Disconnect from services.                        #
###############################################################

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk22.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk22.txt

# Remove $HTMLFile file and exit.
$DoesFileExist = Test-Path $HTMLFile
if($DoesFileExist -eq "True") { Remove-Item $HTMLFile }