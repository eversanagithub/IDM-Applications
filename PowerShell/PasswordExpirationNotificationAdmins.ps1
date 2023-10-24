#Author: Gregory Warner
#Last Modified: 10/30/19
#Summary: Notify Admins with Expiring Password
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Read-Host -Prompt "Enter your password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\PowerShell\PasswordExpirationNoticeAdmins\credentials.txt"

#Get Azure AD Admin Users
$users = get-aduser -SearchBase "OU=Administration,DC=Universal,DC=co" -Filter {enabled -eq $true} -Properties pwdLastSet,mail,extensionAttribute5

#Get Today's Date
$date = get-date

#Create Groups to Sort Users
$7day = @()
$3day = @()
$1day = @()

#Sort Users into Notification Groups
foreach ($user in $users) {
    $LastSet = $user.pwdLastSet
    $pwdLastSet = [datetime]::FromFileTime($LastSet)

    $delta = New-TimeSpan -Start $pwdLastSet -End $date
	$daysDelta = $delta.Days

    #Sort User into Notification Groups
    if ($daysDelta -eq 81) {
        #Add to Group - 7 Day Notice
        $7day += New-Object PSObject -property @{ 
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            ObjectID = $user.ObjectID
            Mail = $user.extensionAttribute5
            pwdLastSet = $pwdLastSet
         }
    } elseif ($daysDelta -eq 85) {
        #Add to Group - 3 Day Notice
        $3day += New-Object PSObject -property @{ 
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            ObjectID = $user.ObjectID
            Mail = $user.extensionAttribute5
            pwdLastSet = $pwdLastSet
         }
    } elseif ($daysDelta -eq 88) {
        #Add to Group - 1 Day Notice
        $1day += New-Object PSObject -property @{ 
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            ObjectID = $user.ObjectID
            Mail = $user.extensionAttribute5
            pwdLastSet = $pwdLastSet
         }
    } else {}
}

<#
#For testing, output the notification groups...
Write-Host "Users 7 days from password expiration."
$7day | Format-Table DisplayName,UserPrincipalName,ObjectID,pwdLastSet
Write-Host ""

Write-Host "Users 3 days from password expiration."
$3day | Format-Table DisplayName,UserPrincipalName,ObjectID,pwdLastSet
Write-Host ""

Write-Host "Users 1 day from password expiration."
$1day | Format-Table DisplayName,UserPrincipalName,ObjectID,pwdLastSet
Write-Host ""
#>

#Email Parameters
$username = "passwordexpiration@eversana.com"
$password = Get-Content "C:\PowerShell\PasswordExpirationNoticeAdmins\credentials.txt" | ConvertTo-SecureString
$SmtpCred = New-Object System.Management.Automation.PSCredential($username, $password)

$From = 'passwordexpiration@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587

# Send Emails

foreach ($record in $7day) {

$7DaySubject = "EVERSANA Admin Password Expires in Seven Days - " + $record.UserPrincipalName

$7DayBody = '
<table>
	<tbody>
		<tr>
			<td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
		</tr>
		<tr>
			<td>
                <font face="arial">
                    Please be advised that your EVERSANA admin password for <b>' + $record.UserPrincipalName + '</b> will expire in seven days. Please follow the below steps to change your password before it expires.<br/>
                    <br/>
                    New Password Must be at least 10 characters and contain 3 of the 4 items below.
                        <ul>
                            <li>Uppercase</li>
                            <li>Lowercase</li>
                            <li>Numbers</li>
                            <li>Special Characters</li>
                        </ul>
                    <b>Option one:</b><br/>
                    Login to a workstation with your admin account > Use CTRL-ALT-DEL > Select Change Password<br/>
                    You will need to type in your current password once and your new password twice.<br/>
                    <br/>
                    <b>Option two:</b><br/>
                    If you are an admin in Active Directory, reset your admin account password directly.
                </font>
            </td>
		</tr>
	</tbody>
</table>'


    $To = $record.Mail
    Send-MailMessage `
        -From $From `
        -UseSsl `
        -SmtpServer $SmtpServer `
        -Port $SmtpPort `
        -To $To `
        -Subject $7DaySubject `
        -Body $7DayBody `
        -BodyAsHtml `
        -credential $SmtpCred
}

foreach ($record in $3day) {

$3DaySubject = "EVERSANA Admin Password Expires in Three Days"

$3DayBody = '
<table>
	<tbody>
		<tr>
			<td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
		</tr>
		<tr>
			<td>
                <font face="arial">
                    Please be advised that your EVERSANA admin password for <b>' + $record.UserPrincipalName + '</b> will expire in three days. Please follow the below steps to change your password before it expires.<br/>
                    <br/>
                    New Password Must be at least 10 characters and contain 3 of the 4 items below.
                        <ul>
                            <li>Uppercase</li>
                            <li>Lowercase</li>
                            <li>Numbers</li>
                            <li>Special Characters</li>
                        </ul>
                    <b>Option one:</b><br/>
                    Login to your workstation > Connect to VPN > Use CTRL-ALT-DEL > Select Change Password<br/>
                    You will need to type in your current password once and your new password twice.<br/>
                    <br/>
                    <b>Option two:</b><br/>
                    Log into <a href="https://portal.office365.com">portal.office365.com</a> using your EVERSANA email and password. Click your user icon in the top right-hand corner then select My Account. On the left-hand side, select Security and Privacy, then Change Password.<br/>
                    <br/>
                    Once your password has been changed with one of these methods, please be aware it may take up to 30 minutes for it to sync with your legacy login.
                </font>
            </td>
		</tr>
	</tbody>
</table>'

    $To = $record.Mail
    Send-MailMessage `
        -From $From `
        -UseSsl `
        -SmtpServer $SmtpServer `
        -Port $SmtpPort `
        -To $To `
        -Subject $3DaySubject `
        -Body $3DayBody `
        -BodyAsHtml `
        -credential $SmtpCred

}

foreach ($record in $1day) {

$1DaySubject = "EVERSANA Admin Password Expires in One Day"

$1DayBody = '
<table>
	<tbody>
		<tr>
			<td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
		</tr>
		<tr>
			<td>
                <font face="arial">
                    Please be advised that your EVERSANA admin password for <b>' + $record.UserPrincipalName + '</b> will expire in one day. Please follow the below steps to change your password before it expires.<br/>
                    <br/>
                    New Password Must be at least 10 characters and contain 3 of the 4 items below.
                        <ul>
                            <li>Uppercase</li>
                            <li>Lowercase</li>
                            <li>Numbers</li>
                            <li>Special Characters</li>
                        </ul>
                    <b>Option one:</b><br/>
                    Login to your workstation > Connect to VPN > Use CTRL-ALT-DEL > Select Change Password<br/>
                    You will need to type in your current password once and your new password twice.<br/>
                    <br/>
                    <b>Option two:</b><br/>
                    Log into <a href="https://portal.office365.com">portal.office365.com</a> using your EVERSANA email and password. Click your user icon in the top right-hand corner then select My Account. On the left-hand side, select Security and Privacy, then Change Password.<br/>
                    <br/>
                    Once your password has been changed with one of these methods, please be aware it may take up to 30 minutes for it to sync with your legacy login.
                </font>
            </td>
		</tr>
	</tbody>
</table>'

    $To = $record.Mail
    Send-MailMessage `
        -From $From `
        -UseSsl `
        -SmtpServer $SmtpServer `
        -Port $SmtpPort `
        -To $To `
        -Subject $1DaySubject `
        -Body $1DayBody `
        -BodyAsHtml `
        -credential $SmtpCred

}
