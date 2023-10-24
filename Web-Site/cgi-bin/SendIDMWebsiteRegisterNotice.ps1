<#
		Program Name: SendIDMWebsiteRegisterNotice.ps1
		Date Written: May 28th, 2023
		  Written By: Dave Jaynes
		 Description: Send designated client e-mail invite to IDM website
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$EMailAddress = $args[0]
$FirstName = $args[1]
$LastName = $args[2]
$MailAdmin = 'dave.jaynes@eversana.com,ted.schuette@eversana.com,nicole.bartelt@eversana.com,sweety.panpatte@eversana.com,reddirani.tr@eversana.com'
$IDM_EMail_HTMLFile = "C:\Apache24\cgi-bin\HTMLRegistrationIDMInfo.txt";
$HTMLFailedFile = "C:\temp\HTMLInviteFailedFile.txt"
$from = 'srv_OneDriveRetention@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587

$serviceAccountUserName2 = Get-Content "C:\Apache24\credentials\OneDriveRetentionUserName.txt"
$serviceAccountPassword2 = Get-Content "C:\Apache24\credentials\EncryptedOneDriveRetentionPassword.txt" | ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($serviceAccountUserName2,$serviceAccountPassword2)
Connect-AzureAD -Credential $credential2|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt
try
{
	$ErrorActionPreference = 'SilentlyContinue'
	$addAccessSubjectLine = "IDM Website Admin Portal Access request for " + $FirstName + " " + $LastName
	$body = Get-Content $IDM_EMail_HTMLFile -Raw
	[string[]]$to = $MailAdmin.Split(',')
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
Disconnect-AzureAD|Out-File -Filepath C:\Apache24\cgi-bin\WorkingTextFiles\junk.txt