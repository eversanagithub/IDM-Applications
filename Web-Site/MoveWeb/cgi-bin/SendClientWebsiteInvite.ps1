<#
		Program Name: SendClientWebsiteInvite.ps1
		Date Written: May 28th, 2023
		  Written By: Dave Jaynes
		 Description: Send designated client e-mail invite to IDM website
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$EMailAddress = $args[0]
$FirstName = $args[1]
$LastName = $args[2]
$MailAdmin = 'dave.jaynes@eversana.com'
$HTMLFile = "C:\temp\HTMLInviteFile.txt"
$HTMLFailedFile = "C:\temp\HTMLInviteFailedFile.txt"
$from = 'srv_OneDriveRetention@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587

$serviceAccountUserName2 = Get-Content "C:\Apache24\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\Apache24\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)
#Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\temp\junk.txt
Connect-AzureAD -Credential $credential2
exit

try
{
	$ErrorActionPreference = 'SilentlyContinue'
	$addAccessSubjectLine = "IDM Website Admin Portal Access for " + $FirstName + " " + $LastName
	$body = Get-Content $HTMLFile -Raw
	$recipients = "$managerUPN"
	[string[]]$to = $EMailAddress.Split(',')
	Send-MailMessage `
		-From $from `
		-To $to `
		-Subject $addAccessSubjectLine `
		-Body $body `
		-BodyAsHtml `
		-UseSsl `
		-SmtpServer $SmtpServer `
		-Port $SmtpPort `
		-credential $credential2
}
catch
{
	$ErrorActionPreference = 'SilentlyContinue'
	$addAccessSubjectLine = "IDM Website Admin Portal Access failed to send for " + $Name
	$body = Get-Content $HTMLFailedFile -Raw
	$recipients = $MailAdmin
	[string[]]$admins = $recipients.Split(',')
	Send-MailMessage `
		-From $from `
		-To $admins `
		-Subject $addAccessSubjectLine `
		-Body $body `
		-BodyAsHtml `
		-UseSsl `
		-SmtpServer $SmtpServer `
		-Port $SmtpPort `
		-credential $credential2				
}
Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt