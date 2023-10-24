<#

		Program Name: ServiceNow_Provision_Teams.ps1
		Date Written: January 9th, 2023
		  Written By: Dave Jaynes
		 Description: Pull All Open Tasks to Provision Teams from ServiceNow to Create New Microsoft Teams
#>

# Engage TLS1.2 for .net Security Protocol purposes 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Step 1: Set SQL connection parameters
$UserName = 'C:\powershell\credentials\sqlusername.txt'
$Password = 'C:\powershell\credentials\sqlpassword.txt'
$SQLUserName = Get-Content $UserName -Raw
$SQLPassword = Get-Content $Password -Raw
$SQLServer = "10.241.36.13"
$Database = "servicenow"
$TeamsMaster = "TeamsMaster"
$TeamsDetail = "TeamsDetail"
$API_Method = "Old"

# Step 2: Create credentials.
# Teams Admin Service Account
$TeamsUserName = Get-Content "C:\PowerShell\credentials\TeamsUserName.txt"
$TeamsPassword = Get-Content "C:\PowerShell\credentials\TeamsPassword.txt" | ConvertTo-SecureString
$teamsCredential = New-Object System.Management.Automation.PSCredential($TeamsUserName,$TeamsPassword)

# Notification Email Account
$AzureAutomationUserName = Get-Content "C:\PowerShell\credentials\AzureAutomationUserName.txt"
$AzureAutomationPassword = Get-Content "c:\powershell\credentials\AzureAutomationPassword.txt" | ConvertTo-SecureString
$SmtpCredential = New-Object System.Management.Automation.PSCredential($AzureAutomationUserName,$AzureAutomationPassword)

# ServiceNow API Account
$ServiceNowAPIUserName = Get-Content "C:\PowerShell\credentials\ServiceNowAPIUserName.txt"
$ServiceNowAPIPassword = Get-Content "C:\PowerShell\credentials\ServiceNowAPIPassword.txt" | ConvertTo-SecureString
$apiCredential = New-Object System.Management.Automation.PSCredential($ServiceNowAPIUserName,$ServiceNowAPIPassword)

# Step 3: Set up the Service-Now API Connector Credentials.
# Set up direct API Header Information
$instance = "eversana"
$URISCTask = "https://$instance.service-now.com/api/now/table/sc_task"
$URIMTOM = "https://$instance.service-now.com/api/now/table/sc_item_option_mtom"
$URISYSUsers = "https://$instance.service-now.com/api/now/table/sys_user"
$method = "GET"
$user = $apiCredential.UserName
$pass = $apiCredential.GetNetworkCredential().Password
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$Get = "GET"
$Put = "PUT"
$Result = "result"
$ResultUserName = "result.user_name"
$QueryNone = "None"
$QuerySOTasks = "short description LIKE 'New Collaboration Site Request'"

# Step 4: Set up the functions.
function SQLQueryOne    
{
	param(
		[string]$SQLCommand,
		[int]$element,
		[int]$field
	)  
	[void][System.Reflection.Assembly]::LoadFrom("c:\Program Files (x86)\MYSQL\MySQL Connector Net 8.0.26\Assemblies\v4.5.2\MYSql.Data.dll")
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

function SQLQueryMany    
{
 param(
  [string]$SQLCommand,
  [int]$element,
  [int]$field
 )  
 [void][System.Reflection.Assembly]::LoadFrom("c:\Program Files (x86)\MYSQL\MySQL Connector Net 8.0.26\Assemblies\v4.5.2\MYSql.Data.dll")
 $myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
 $myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
 $myconnection.Open()
 $mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
 $mycommand.Connection = $myconnection
 $mycommand.CommandText = "$SQLCommand"
 $myreader = $mycommand.ExecuteReader()
 $a = while($myreader.Read()){ $myreader.GetString($field) }
 $myconnection.Close()
 return $a[$element]
}


function SQLWriteData    
{
	param(
		[string]$SQLCommand
	)  
	[void][System.Reflection.Assembly]::LoadFrom("c:\Program Files (x86)\MYSQL\MySQL Connector Net 8.0.26\Assemblies\v4.5.2\MYSql.Data.dll")
	$myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$myconnection.ConnectionString = "server=$SQLServer;user id=$SQLUserName;password=$SQLPassword;database=$Database;pooling=false"
	$myconnection.Open()
	$mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
	$mycommand.Connection = $myconnection
	$mycommand.CommandText = "$SQLCommand"
	$myreader = $mycommand.ExecuteReader()
	$myconnection.Close()
}

function APICall {
	[OutputType([System.Management.Automation.PSCustomObject])]
	[CmdletBinding(DefaultParameterSetName, SupportsPaging)]
	Param (
		# Name of the table to be queried against in ServiceNow.
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$URI,

		# Define conditional field-value queries to reduce overall payload return
		[Parameter(Mandatory = $true)]
		[string]$Query,
		
		# Define conditional field-value queries to reduce overall payload return
		[Parameter(Mandatory = $true)]
		[string]$Method,		
		
		# Define conditional field-value queries to reduce overall payload return
		[Parameter(Mandatory = $true)]
		[string]$Depth
	)

	$ContentType = "application/json"
	$Credential = $apiCredential
	if($Query = "None")
	{
		$Params = @{
			Headers = $headers
			Method = $method
			Uri = $Uri
			}
		$Response = (Invoke-RestMethod @Params).$Depth
	}
	else
	{
		$Body = @{'sysparm_display_value' = $DisplayValues}
		$Body.sysparm_query = $Query
		$Params = @{
			Headers = $headers
			Body = $Body
			Method = $method
			Uri = $Uri
		}
		$Response = (Invoke-RestMethod @Params).$Depth			
	}
	return $Response
}

# Step 5: Create the SQL tables.
SQLWriteData -SQLCommand "drop table if exists $TeamsMaster"
SQLWriteData -SQLCommand "drop table if exists $TeamsDetail"
SQLWriteData -SQLCommand "create table if not exists $TeamsMaster(taskeffectivenumber varchar(30),state varchar(30),createdBy varchar(60),approval varchar(30),dueDate varchar(60),stage varchar(30),teamName varchar(100),primaryOwnerSysID varchar(100),primaryOwnerURI varchar(250),primaryOwner varchar(60),secondaryOwnerSysID varchar(100),secondaryOwnerURI varchar(250),secondaryOwner varchar(60))"
SQLWriteData -SQLCommand "create table if not exists $TeamsDetail(taskEffectiveNumber varchar(30),membertype varchar(20),member varchar(60))"

# Step 6: Set variables
$recipients = "dave.jaynes@eversana.com"
$assignee = 'e915a30c1b1fccd00203eb1cad4bcb28'
#$Query = "short description LIKE 'New Collaboration Site Request'^short description LIKE 'Team'^short description NOT LIKE 'Review'^state IN '1,2'"
#$Query = "short description LIKE 'New Collaboration Site Request'^short description LIKE 'Team'^short description NOT LIKE 'Review'"

# Step 7: Pull all the New Collaboration Site requests that are not in review status and have a state value of 1 or 2.

if ($API_Method -eq "New")
{
	Write-Host "Pulling the SOTasks request via new method"
	$scTasks = APICall -URI $URISCTask -Query $QuerySOTasks -Method $Get -Depth $Result
}
else
{
	#Write-Host "Pulling the SOTasks request via old method"
	$scTasksURI = "https://$instance.service-now.com/api/now/table/sc_task?sysparm_query=short_descriptionLIKENew%20Collaboration%20Site%20Request"
	$scTasks = (Invoke-RestMethod -Headers $headers -Method $method -Uri $scTasksURI).result
}


# Step 8: Load SQL tables from the results of the New Collaboration Site requests.
#Write-Host "scTasks = [$($scTasks.count)]"

if ($($scTasks.count) -gt 0)
{
	#Connect to Microsoft Teams
	#Connect-MicrosoftTeams -Credential $teamsCredential
	$thisItem = ''
	$taskEffectiveNumber = ''
	$state = ''
	$createdBy = ''
	$approval = ''
	$due_date = ''
	$stage = ''

	$Counter = 0
	foreach ($sctask in $scTasks) 
	{
		if ($API_Method -eq "New")
		{
			Write-Host "Pulling the request item via new method"
			$URI = $($scTask.request_item.link)
			$requestItem = APICall -URI $URI -Query $QueryNone -Method $Get -Depth $Result			
		}
		else
		{
			#Write-Host "Pulling the request item via old method"
			$requestItem = ''
			$requestItem = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scTask.request_item.link)).result			
		}

		if($requestItem -ne $null)
		{
			$requestItem | %{
				$thisItem = $_
				$taskEffectiveNumber = $thisItem.task_effective_number
				$state = $thisItem.state
				$createdBy = $thisItem.sys_created_by
				$approval = $thisItem.approval
				$due_date = $thisItem.due_date
				$stage = $thisItem.stage
			}
		}
		
		if ($API_Method -eq "New")
		{
			Write-Host "Pulling the variables via new method"
			$Query = "request_item.number=${requestItem.number}"
			$variables = APICall -URI $URIMTOM -Query $Query -Method $Get -Depth $Result
		}
		else
		{
			#Write-Host "Pulling the variables via old method"
			$variableOwnershipURI = "https://$instance.service-now.com/api/now/table/sc_item_option_mtom?sysparm_query=request_item.number%3D" + $requestItem.number
			$variables = (Invoke-RestMethod -Headers $headers -Method $method -Uri $variableOwnershipURI).result
		}


		#Clear Previous Variables
		$teamName = ''
		$primaryOwnerSysID = ''
		$secondaryOwnerSysID = ''
		$initialMembersSysID = ''
		$externalGuests = ''

		#Gather Current Variables
		# All of the values returned (Teams name, employees ...) are in the form of the UID, not the plain text name itself.
		foreach ($variable in $variables) 
		{
			if ($API_Method -eq "New")
			{
				Write-Host "Pulling the item option via new method"
				$URI = $($variable.sc_item_option.link)
				$scItemOption = APICall -URI $URI -Query $QueryNone -Method $Get -Depth $Result	
				Write-Host "Pulling the item new option via new method"
				$URI = $($scItemOption.item_option_new.link)
				$itemOptionNew = APICall -URI $URI -Query $QueryNone -Method $Get -Depth $Result			
			}
			else
			{
				#Write-Host "Pulling the item option via old method"
				$scItemOption = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($variable.sc_item_option.link)).result
				#Write-Host "Pulling the item old option via old method"
				$itemOptionNew = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scItemOption.item_option_new.link)).result
			}

			$itemOptionNewName = $itemOptionNew.name
			switch($itemOptionNewName)
			{
				approved_name_of_team_site
				{
					$teamName = $scItemOption.value
					break
				}
				primary_owner
				{
					$primaryOwnerSysID = $scItemOption.value
					break
				}
				secondary_owner
				{
					$secondaryOwnerSysID = $scItemOption.value
					break
				}
				initial_members
				{
					$initialMembersSysID = $scItemOption.value
					break
				}
				external_guests
				{
					$externalGuests = $scItemOption.value
					break
				}
			}
			
			if ($API_Method -eq "New")
			{
				Write-Host "Pulling the primary owner via new method"
				$Depth = "result.user_name"
				$Query = "sys_id=${primaryOwnerSysID}"
				$primaryOwner = APICall -URI $URISYSUsers -Query $Query -Method $Get -Depth $ResultUserName				
			}
			else
			{
				$primaryOwner = ''
				#Write-Host "Pulling the primary owner via old method"
				$primaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $primaryOwnerSysID
				$primaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $primaryOwnerURI).result.user_name
			}
			if($primaryOwner -ne '' -and $primaryOwner -ne $null)
			{
				SQLWriteData -SQLCommand "insert into $TeamsDetail(taskEffectiveNumber,membertype,member) values ('$taskEffectiveNumber','Primary','$primaryOwner')"
			}				

			if ($API_Method -eq "New")
			{
				Write-Host "Pulling the secondary owner via new method"
				$Query = "sys_id=${secondaryOwnerSysID}"
				$secondaryOwner = APICall -URI $URISYSUsers -Query $Query -Method $Get -Depth $ResultUserName				
			}
			else
			{
				$secondaryOwner = ''
				#Write-Host "Pulling the secondary owner via old method"
				$secondaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $secondaryOwnerSysID
				$secondaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $secondaryOwnerURI).result.user_name
			}
			if($secondaryOwner -ne '' -and $secondaryOwner -ne $null)
			{
				SQLWriteData -SQLCommand "insert into $TeamsDetail(taskEffectiveNumber,membertype,member) values ('$taskEffectiveNumber','Secondary','$secondaryOwner')"
			}

			$members = @()
			$initialMembersSysID = $initialMembersSysID.Split(",")

			foreach ($initialMemberSysID in $initialMembersSysID) 
			{
				if ($API_Method -eq "New")
				{
					Write-Host "Pulling the member via new method"
					$Query = "sys_id=${initialMembersSysID}"
					$member = APICall -URI $URISYSUsers -Query $Query -Method $Get -Depth $ResultUserName				
				}
				else
				{
					$member = ''
					#Write-Host "Pulling the member via old method"
					$memberURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $initialMemberSysID
                    $member = (Invoke-RestMethod -Headers $headers -Method $method -Uri $memberURI).result.user_name
				}
				if($member -ne '' -and $primaryOwner -ne $null)
				{
					SQLWriteData -SQLCommand "insert into $TeamsDetail(taskEffectiveNumber,membertype,member) values ('$taskEffectiveNumber','Member','$member')"
				}
				SQLWriteData -SQLCommand "delete from $TeamsDetail where member = ''"
				$members += $member
			}
		}
		SQLWriteData -SQLCommand "insert into $TeamsMaster(taskEffectiveNumber, state,createdBy,approval,dueDate,stage,teamName,primaryOwnerSysID,primaryOwnerURI,primaryOwner,secondaryOwnerSysID,secondaryOwnerURI,secondaryOwner) values ('$taskEffectiveNumber','$state','$createdBy','$approval','$due_date','$stage','$teamName','$primaryOwnerSysID','$primaryOwnerURI','$primaryOwner','$secondaryOwnerSysID','$secondaryOwnerURI','$secondaryOwner')"
		$Counter++
		#Write-Host "Counter = [$Counter]"
		if($Counter > 50)
		{ 
			exit 
		}
	}
}

exit
<#
#---------------------------------------------------------------------------------------------------------------------------------------------
# Function to perform the REST API call into the ServiceNow 'u_stage_itg_onboarding' table.
function Get-ServiceNowTable {
	[OutputType([System.Management.Automation.PSCustomObject])]
	[CmdletBinding(DefaultParameterSetName, SupportsPaging)]
	Param (
		# Name of the table to be queried against in ServiceNow.
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Table,

		# Define conditional field-value queries to reduce overall payload return
		[Parameter(Mandatory = $false)]
		[string]$Query,

		# Maximum number of records to return; in this case all of them as this parameter is not passed.
		[Parameter(Mandatory = $false)]
		[int]$Limit,

		# Whether or not to show human readable display values instead of machine values
		[Parameter(Mandatory = $false)]
		[ValidateSet('true', 'false', 'all')]
		[string]$DisplayValues = 'true',

		# Specify the actual REST API URL to be called by the Invode-RestMethod CmdLet.
		[Parameter(ParameterSetName = 'SpecifyConnectionFields', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[Alias('Url')]
		[string]$ServiceNowURL
	)

	# Initialize the Invoke-RestMethod Body object.
	$Body = @{'sysparm_display_value' = $DisplayValues}
	
	# Populate the Body 'sysparm_query' property with the 'SharePoint Updated' column looking for a 'false' value.
	if ($Query) {
		$Body.sysparm_query = $Query
	}

	# Use the 'sysparm_fields' property if we were looking to only pull back certain columns from the SN table.
	if ($Properties) {
		$Body.sysparm_fields = ($Properties -join ',').ToLower()
	}

	# Build the fully populated $Uri variable.
	$Uri = $ServiceNowURL + "/table/$SNTable"

	# Combine all REST API parameters within the $Params array.
	$Params = @{
		Method = "GET"
		Uri = $Uri
		Body = $Body
		ContentType = $ContentType
		Credential = $Credential
	}

	# Kick off the REST API call to ServiceNow.
	$ServiceNowRecords = (Invoke-RestMethod @Params).Result

	# Return the API call results to the function call command.
	return $ServiceNowRecords
}

#---------------------------------------------------------------------------------------------------------------------------------------------



### Get open task details & provision teams
if ($($scTasks.count) -gt 0)
{
    #Connect to Microsoft Teams
    Connect-MicrosoftTeams -Credential $teamsCredential

    foreach ($sctask in $scTasks) 
    {
            $requestItem = ''
            $requestItem = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scTask.request_item.link)).result

            #$request = ''
            #$request = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($requestItem.request.link)).result

            #Get Dependent Items from sc_item_option_mtom
            $variableOwnershipURI = "https://$instance.service-now.com/api/now/table/sc_item_option_mtom?sysparm_query=request_item.number%3D" + $requestItem.number

            $variables = (Invoke-RestMethod -Headers $headers -Method $method -Uri $variableOwnershipURI).result

            #Clear Previous Variables
                $teamName = ''
                $primaryOwnerSysID = ''
                $secondaryOwnerSysID = ''
                $initialMembersSysID = ''
                $externalGuests = ''

            #Gather Current Variables

            foreach ($variable in $variables) 
            {
                $scItemOption = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($variable.sc_item_option.link)).result
                $itemOptionNew = (Invoke-RestMethod -Headers $headers -Method $method -Uri $($scItemOption.item_option_new.link)).result
                if ($itemOptionNew.name -eq "approved_name_of_team_site") 
                {
                    $teamName = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "primary_owner") 
                {
                    $primaryOwnerSysID = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "secondary_owner") 
                {
                    $secondaryOwnerSysID = $scItemOption.value
                } 
                elseif ($itemOptionNew.name -eq "initial_members") 
                {
                    $initialMembersSysID = $scItemOption.value
                }
                elseif ($itemOptionNew.name -eq "external_guests")
                {
                    $externalGuests = $scItemOption.value
                }
            }

            $primaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $primaryOwnerSysID
            $primaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $primaryOwnerURI).result.user_name

            $secondaryOwnerURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $secondaryOwnerSysID
            $secondaryOwner = (Invoke-RestMethod -Headers $headers -Method $method -Uri $secondaryOwnerURI).result.user_name
    
            #Used to collect members' usernames
            $members = @()
            #Split string into an array
            $initialMembersSysID = $initialMembersSysID.Split(",")

                foreach ($initialMemberSysID in $initialMembersSysID) 
                {
                    $memberURI = "https://$instance.service-now.com/api/now/table/sys_user?sysparm_query=sys_id%3D" + $initialMemberSysID
                    $member = (Invoke-RestMethod -Headers $headers -Method $method -Uri $memberURI).result.user_name
                    $members += $member
                }

                
            ### Provision the team & throw an alert if an error is encountered
            Try
            {
                $teamName
                $newTeam = New-Team -DisplayName $teamName -Visibility Private
                Start-Sleep -Seconds 30
    
                $ID = ''
                $ID = $newTeam.groupId
                $ID
    
                Start-Sleep -Seconds 15
                #Add Members to Team
                foreach ($member in $members)
                {
                    $member
                    Add-TeamUser -GroupId $ID -User $member -Role Member
                    Start-Sleep -Seconds 3
                }
    
                #Add Primary Owner
                $primaryOwner
                Add-TeamUser -GroupId $ID -user $primaryOwner -Role Owner
    
                #Add Secondary Owner
                $secondaryOwner
                Add-TeamUser -GroupId $ID -user $secondaryOwner -Role Owner

             ### Close the sc_task
                if ($(Get-Team -DisplayName $teamName) -ne $null)
                {
                    # Specify endpoint uri
                    $scTaskSysID = $scTask.sys_id
                    $uri = "https://$instance.service-now.com/api/now/table/sc_task/$scTaskSysID"

                    # Specify HTTP method
                    $methodPUT = "put"

                    # Specify request body
                    $body = '{"assigned_to":"'+$assignee+'","state":"3"}'

                    # Send HTTP request
                    Invoke-RestMethod -Headers $headers -Method $methodPUT -Uri $uri -Body $body
                }
            }
            Catch
            {
                $From = 'azureautomation@eversana.com'
                $SmtpServer = 'smtp.office365.com'
                $SmtpPort = 587
                [string[]]$to = $recipients.Split(',')

                $scTaskNumber = ''
                $scTaskNumber = $scTask.number
                $Subject = "Automation Error Experienced Provisioning Team: $teamName"
                $Body = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                    An error was encountered provisioning the following team.<br/>
                    <br/>
                        <ul>
                            <li>Catalog Task: $scTaskNumber</li>
                            <li>Team Name: $teamName</li>
                            <li>Primary Owner: $primaryOwner</li>
                            <li>Secondary Owner: $secondaryOwner</li>
                            <li>Members: $members</li>
                        </ul>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@


                Send-MailMessage `
                    -From $From `
                    -UseSsl `
                    -SmtpServer $SmtpServer `
                    -Port $SmtpPort `
                    -To $To `
                    -Subject $Subject `
                    -Body $Body `
                    -BodyAsHtml `
                    -credential $SmtpCredential

            }

            #Notify if external guests need to be invited for the team
            if ($externalGuests -ne '')
            {
                $From = 'azureautomation@eversana.com'
                $SmtpServer = 'smtp.office365.com'
                $SmtpPort = 587
                [string[]]$to = $recipients.Split(',')

                $scTaskNumber = ''
                $scTaskNumber = $scTask.number
                $SubjectGuests = "Please Invite Guests for Team: $teamName"
                $BodyGuests = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                    Please invite guest users for the following team.<br/>
                    <br/>
                        <ul>
                            <li>Catalog Task: $scTaskNumber</li>
                            <li>Team Name: $teamName</li>
                            <li>Primary Owner: $primaryOwner</li>
                            <li>Secondary Owner: $secondaryOwner</li>
                            <li>Members: $members</li>
                            <li>Guests: $externalGuests</li>
                        </ul>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@

                Send-MailMessage `
                    -From $From `
                    -UseSsl `
                    -SmtpServer $SmtpServer `
                    -Port $SmtpPort `
                    -To $To `
                    -Subject $SubjectGuests `
                    -Body $BodyGuests `
                    -BodyAsHtml `
                    -credential $SmtpCredential
            }

    }

    #Disconnect from Microsoft Teams
    Disconnect-MicrosoftTeams
}

#>