#Author: Gregory Warner
#Last Modified: 10/29/19
#Summary: Notify When Intune Device Changes from "Personal" to "Corporate"

#Read-Host -Prompt "Enter your password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\PowerShell\IntuneMonitoring\credentials.txt"

####################################################
#Authorization Process -

function Get-AuthToken {

<#
.SYNOPSIS
This function is used to authenticate with the Graph API REST interface
.DESCRIPTION
The function authenticate with the Graph API Interface with the tenant name
.EXAMPLE
Get-AuthToken
Authenticates you with the Graph API interface
.NOTES
NAME: Get-AuthToken
#>

[cmdletbinding()]

param
(
    [Parameter(Mandatory=$true)]
    $User,
    $Password
)

$userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User

$tenant = $userUpn.Host

Write-Host "Checking for AzureAD module..."

    $AadModule = Get-Module -Name "AzureAD" -ListAvailable

    if ($AadModule -eq $null) {

        Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable

    }

    if ($AadModule -eq $null) {
        write-host
        write-host "AzureAD Powershell module not installed..." -f Red
        write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
        write-host "Script can't continue..." -f Red
        write-host
        exit
    }

# Getting path to ActiveDirectory Assemblies
# If the module count is greater than 1 find the latest version

    if($AadModule.count -gt 1){

        $Latest_Version = ($AadModule | select version | Sort-Object)[-1]

        $aadModule = $AadModule | ? { $_.version -eq $Latest_Version.version }

            # Checking if there are multiple versions of the same module found

            if($AadModule.count -gt 1){

            $aadModule = $AadModule | select -Unique

            }

        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    }

    else {

        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    }

[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

$clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"

$redirectUri = "urn:ietf:wg:oauth:2.0:oob"

$resourceAppIdURI = "https://graph.microsoft.com"

$authority = "https://login.microsoftonline.com/$Tenant"

    try {

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
    # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession

    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"

    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")

        if($Password -eq $null){

            $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId).Result

        }

        else {

            if(test-path "$Password"){

            $UserPassword = get-Content "$Password" | ConvertTo-SecureString

            $userCredentials = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $userUPN,$UserPassword

            $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $clientid, $userCredentials).Result;

            }

            else {

            Write-Host "Path to Password file" $Password "doesn't exist, please specify a valid path..." -ForegroundColor Red
            Write-Host "Script can't continue..." -ForegroundColor Red
            Write-Host
            break

            }

        }

        if($authResult.AccessToken){

        # Creating header for Authorization token

        $authHeader = @{
            'Content-Type'='application/json'
            'Authorization'="Bearer " + $authResult.AccessToken
            'ExpiresOn'=$authResult.ExpiresOn
            }

        return $authHeader

        }

        else {

        Write-Host
        Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
        Write-Host
        break

        }

    }

    catch {

    write-host $_.Exception.Message -f Red
    write-host $_.Exception.ItemName -f Red
    write-host
    break

    }

}

####################################################
# SPECIFY SERVICE ACCOUNT USER AND PASSWORD IN TWO VARIABLES BELOW!

#region Authentication

$User = "a_Srv_IntuneReport@eversana.com"
$Password = "C:\PowerShell\IntuneMonitoring\credentials.txt"

write-host

# Checking if authToken exists before running authentication
if($global:authToken){

    # Setting DateTime to Universal time to work in all timezones
    $DateTime = (Get-Date).ToUniversalTime()

    # If the authToken exists checking when it expires
    $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

        if($TokenExpires -le 0){

        write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
        write-host

            # Defining Azure AD tenant name, this is the name of your Azure Active Directory (do not use the verified domain name)

            if($User -eq $null -or $User -eq ""){

            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host

            }

        $global:authToken = Get-AuthToken -User $User -Password "$Password"

        }
}

# Authentication doesn't exist, calling Get-AuthToken function

else {

    if($User -eq $null -or $User -eq ""){

    $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
    Write-Host

    }

# Getting the authorization token
$global:authToken = Get-AuthToken -User $User -Password "$Password"

}

#endregion

####################################################

#Write-Host
####################################################

#Get that Intune data!

$data = Invoke-RestMethod "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" `
    -method Get `
    -Headers @{'Authorization' = $global:authToken.Authorization}

$devices = $data.value

$deviceUsers = $data.value.userPrincipalName

#Select Intune devices that are "Corporate" owned
$devicesCorporate = $devices | Where-Object {$_.managedDeviceOwnerType -eq "company"}

$dateToday = (get-date).ToString("yyMMdd")
$dateYesterday = (get-date).AddDays(-1).ToString("yyMMdd")

$dataYesterday = Test-Path "C:\PowerShell\IntuneMonitoring\Records\devicesCorporate-$dateYesterday.csv"

if ($dataYesterday -eq $true) {
    $devicesCorporatePrevious = Import-Csv "C:\PowerShell\IntuneMonitoring\Records\devicesCorporate-$dateYesterday.csv"
} else {
    $devicesCorporatePrevious = ''
}

#Create Alerting Group for Sorting
$devicesAlert = @()

#Sort Devices into Alerting Group
if ($devicesCorporate -ne $null) {
    foreach ($device in $devicesCorporate) {
        if ($devicesCorporatePrevious.id -notcontains $device.id) {
            $devicesAlert += $device
        }
    }
}

#######

#Trigger Email Alerts!!

#In PROD, alert to Robert Muldoon, Gary Voigt, Fred Skinner, and Mark Henke

#Email Parameters
$username2 = "intune.notification@eversana.com"
$password2 = Get-Content "C:\PowerShell\IntuneMonitoring\credentials2.txt" | ConvertTo-SecureString
$SmtpCred = New-Object System.Management.Automation.PSCredential($username2, $password2)



#2/5/20 Monitoring was disabled by Greg Warner temporarily to mark corporate devices in Intune without triggering alerts.
$recipients = "greg.warner@eversana.com"

#$recipients = "robert.muldoon@eversana.com,gary.voigt@eversana.com,fred.skinner@eversana.com,mark.henke@eversana.com"
[string[]]$to = $recipients.Split(',')

$from = 'intune.notification@eversana.com'
$SmtpServer = 'smtp.office365.com'
$SmtpPort = 587

$subject = "ATTENTION: Intune Device Ownership Alert!"

foreach ($alert in $devicesAlert) {
$body = '
<table>
	<tbody>
		<tr>
			<td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
		</tr>
		<tr>
			<td>
                <font face="arial">
                   ATTENTION: A mobile device belonging to ' + $alert.userDisplayName  + ' has changed managedDeviceOwnerType from "Personal" to "Corporate". This is a potential violation of Eversana IT policy. Please investigate and respond accordingly.<br/>
                   <br/>
                   <hr>
                   <b>Device Details</b><br/>
                   deviceName: ' + $alert.deviceName + '<br/>
                   managedDeviceOwnerType: ' + $alert.managedDeviceOwnerType + '<br/>
                   operatingSystem: ' + $alert.operatingSystem + '<br/>
                   complianceState: ' + $alert.complianceState + '<br/>
                   emailAddress: ' + $alert.emailAddress + '<br/>
                   azureADDeviceId: ' + $alert.azureADDeviceId + '<br/>
                </font>
            </td>
		</tr>
	</tbody>
</table>'

    Send-MailMessage `
        -From $from `
        -UseSsl `
        -SmtpServer $SmtpServer `
        -Port $SmtpPort `
        -To $to `
        -Subject $subject `
        -Body $body `
        -BodyAsHtml `
        -credential $SmtpCred
}


#######

#Dump Today's List of Current Corporate Devices
$devicesCorporate | Export-Csv "C:\PowerShell\IntuneMonitoring\Records\devicesCorporate-$dateToday.csv" -NoTypeInformation