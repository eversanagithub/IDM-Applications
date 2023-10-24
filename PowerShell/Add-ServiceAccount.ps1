#Author: Gregory Warner
#Last Modified: 8/25/20
#Summary: Add a specified user to all non-personal cloud Power BI workspaces


###############################################################
#    Step 1: Assign various local variables.                  #
###############################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw

# Define SQL information
$SQLServer = "10.241.36.13"
$SQLDatabase = "encryptedpasswords"
$SQLTable = "encryptedpasswords"

# Designate User(s) To Receive Error Notifications (Separate multiple users with a comma)
$recipients = "dave.jaynes@eversana.com"
[string[]]$to = $recipients.Split(',')

###############################################################
#    Step 2: Define the SQL Read and Write functions.         #
###############################################################

# Set up the SQL Read single field function
function SQLRead    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\Connector NET 8.0\Assemblies\v4.5.2\\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$SQLDatabase;pooling=false"
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

$currentUser = $env:UserName
$serviceAccountUserName = Get-Content "C:\PowerShell\credentials\PowerBI_UserName.txt"
$EncryptedPasswordFile = SQLRead -SQLCommand "select filepath from $SQLTable where currentUser = '$currentUser' and serviceAcct = '$serviceAccountUserName'"
$serviceAccountPassword = Get-Content $EncryptedPasswordFile | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential($serviceAccountUserName,$serviceAccountPassword)
Connect-PowerBIServiceAccount -Credential $credentials

###############################################################
#    Step 4: Check each PBI account for the srv_powerbi acct  #
###############################################################

Try
{
	$serviceAccount = "srv_PowerBI@eversana.com"
	$workspaces = Get-PowerBIWorkspace -Scope Organization -All | Where-Object {($_.Name -notlike "PersonalWorkspace*") -and ($_.Type -eq "Workspace")}

	foreach ($workspace in $workspaces)
	{
		$workspaceID = ''
		$workspaceID = $workspace.Id.Guid
		$url = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceID/users"
		$members = ''
		$members = (Invoke-PowerBIRestMethod -Url $url -Method Get | ConvertFrom-Json).value.emailAddress
		# Check if group members contain designated account
		if (($members -notcontains $serviceAccount) -or ($members -eq $null))
		{
			Add-PowerBIWorkspaceUser -Scope Organization -Id $workspaceID -UserPrincipalName $serviceAccount -AccessRight Admin
			Write-Host "Add srv_PowerBI to:"$($workspace.Name)
		}
	}
	Disconnect-PowerBIServiceAccount
}
Catch
{
	# SMTP Details for Notifications
	$from = 'srv_PowerBI@eversana.com'
	$smtpServer = 'smtp.office365.com'
	$smtpPort = 587
	$subject = "Error Adding srv_PowerBI to Workspace from DCOBUTIL01"
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
                The "Add-ServiceAccount" script on DCOBUTIL01 has encountered an error. Please investigate and respond accordingly.<br/>
                <br/>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@
	Send-MailMessage `
		-From $from `
		-To $to `
		-Subject $subject `
		-Body $body `
		-BodyAsHtml `
		-UseSsl `
		-SmtpServer $SmtpServer `
		-Port $SmtpPort `
		-credential $powerBICredential
}