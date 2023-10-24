[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$azureADUserName = Get-Content "C:\IDM\credentials\PowerBIUserName.txt"
$azureADPassword = Get-Content "C:\IDM\credentials\PowerBIPassword.txt"| ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PSCredential($azureADUserName,$azureADPassword)

$azureADUserName = Get-Content "C:\IDM\credentials\OneDriveRetentionUserName.txt"
$azureADPassword = Get-Content "C:\IDM\credentials\OneDriveRetentionPassword.txt"| ConvertTo-SecureString
$credential2 = New-Object System.Management.Automation.PSCredential($azureADUserName,$azureADPassword)

Connect-AzAccount -Credential $credential1
Connect-AzureAD -Credential $credential2

#Connect to SharePoint Admin
$TenantURL = 'https://eversana-admin.sharepoint.com/'
Connect-SPOService -url $TenantURL -Credential $credential2

$ServerName = "idmgmtsql01"
$databasename = "IAM";
$ConnectionString = "server=$ServerName;database=$databasename;trusted_connection=True"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $ConnectionString
$connection.Open()

$Disablesquery = "  select COALESCE(asr.FieldValue,sr.FieldValue)+'@eversana.com' as UPN
 From Request_VW r 
 left join ADHoc_SubRequest asr on (r.RequestGUID = asr.RequestGUID and r.TBL = 'ADHoc_Request' and asr.FieldName = 'username')
 left join SubRequest sr on (r.RequestGUID = sr.RequestGUID and r.TBL = 'Request' and sr.FieldName = 'username')
 where r.targetid = 'ad_universal'  and r.Status = 'Completed' and r.Action = 'DIS' and r.ProcessedDate is not null and r.requestdate > convert(varchar, getdate() - 1, 112) and requestid  = '94937 '" 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Disablesquery
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$SqlCmd.Connection = $Connection
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

foreach ($Row in $DataSet.Tables[0].Rows)
{
	$row.upn
  $disabledUsers += get-azureaduser -All $true -filter "UserPrincipalName eq $Row.UPN"
}
$disabledUsers
Disconnect-AzAccount
Disconnect-AzureAD
exit
<#
$delegates = @()
foreach ($disabledUser in $disabledUsers)
{
	$disabledUserUPN = $disabledUser.UserPrincipalName
	$delegate = $($OneDriveSites | Where-Object {$_.Owner -eq $disabledUserUPN})
	$delegateURL = $delegate.Url
	# Here is where we look into the 'OneDriveDelegation' SQL Table to see if the delegate has already been processed.
	if (($delegateURL -ne $null) -and ($($delegate.count) -eq 1))
	{
		$delegates += $delegate
	}
}

foreach ($delegate in $delegates)
{
	Try
	{
		$targetFolder = ''
		$URL = ''
		$URL = $delegate.Url
		$owner = ''
		$owner = $delegate.Owner
		$ownerUpper = $owner.ToUpper()
		$ownerAzureAD = Get-AzureADUser -filter "UserPrincipalName eq `'$owner`'"
		$ownerDirectReports = (Get-AzureADUserDirectReport -ObjectID $($ownerAzureAD.ObjectID)).count

		# Get Manager Details
		$manager = Get-AzureADUserManager -ObjectID $((Get-AzureADUser -filter "userPrincipalName eq `'$owner`'").ObjectID)
		$managerUPN = $manager.UserPrincipalName
		$managerEnabled = $manager.AccountEnabled

		if($managerUPN -eq '' -or $managerUPN -eq $null) 
		{ 
			$managerUPN = 'robert.muldoon@eversana.com' 
			$ProcessRecord = "No"
		}
                
		# We need to service account 'srv_OneDriveRetention@eversana.com' as a Site Collection Admin for this account
		# so it has the rights to scan, read and copy files from the ex-delegates folder to the managers folders.
		if($ProcessRecord -eq "Yes")
		{
			Set-SPOUser -site $URL -LoginName $secondaryAdmin -IsSiteCollectionAdmin $True
		}

		#Connect to SharePoint Site Directly
		Add-Content -Path "$RunningLogFile" -Value ""
		Add-Content -Path "$RunningLogFile" -Value "Connecting to PnPOnline for URL [$URL]"
		Connect-PnPOnline -Url $URL -Credentials $credential2

		#Get folders only in root Documents directory
		$web = Get-PnPWeb
		$relativeUrl = $web.ServerRelativeUrl + "/Documents/"
		$foldersDraft = ((Get-PnPListItem -List Documents -Fields ID,Title,GUID).FieldValues | Where-Object {($_.FileRef -notlike "$relativeUrl*.*") -and ($_.FileRef -notlike "$relativeUrl*/*")}).FileRef
 
		$folders = @()
		foreach ($folderDraft in $foldersDraft)
		{
			$start = ($relativeUrl.Length) - 10
			$end = ($folderDraft.length) - $start
			$substring = $folderDraft.Substring($start,$end)
			$folders += $substring
		}

		$termName = $(($($owner.split("@"))[0]).ToUpper())
		$termDate = Get-Date -Format yyyMMdd
		$folderName = "TERM-"+$termDate+"-"+$termName
		$targetFolder = "Documents/"+$folderName
		
		if($ProcessRecord -eq "Yes")
		{
			try 
			{
				$folderAdd = Add-PNPFolder -Name $folderName -Folder Documents
			}
			catch
			{
				Write-Host "Main Folder [$folderName] already exists."
			}
			foreach ($folder in $folders)
			{
				try
				{
					$folderMove = Move-PnpFolder -Folder $folder -TargetFolder $targetFolder
				}
				catch
				{
					Write-Host "Sub Folder [$folderName] does not exist."
				}
			}
		}

		# Get remaining files to move into new folder
		$filesAll = (Get-PnPListItem -List Documents -Fields ID,Title,GUID).FieldValues
		$files = $filesAll | Where-Object {$_.FileRef -notlike "*$folderName*"}

		foreach ($file in $files)
		{
			$sourceFile = $file.FileRef
			$filepathIndex = $($sourceFile.indexOf("Documents/")) + 10
			$filepathExtract = $sourceFile.Substring(0,$filepathIndex)
			$targetFile = $filepathExtract+$folderName+"/"+$file.FileLeafRef
			if($ProcessRecord -eq "Yes")
			{	
				try
				{
					$fileMove = Move-PnpFile -ServerRelativeUrl $sourceFile -TargetURL $targetFile -Force
				}
				catch
				{
					Write-Host "File [$sourceFile] does not exist."
				}
			}
		}

		# Build the shared OneDrive URL
		$baseUrl = $web.Url
		$urlID = $relativeUrl + $folderName
		$urlID = [System.Web.HTTPUtility]::UrlEncode($urlID)
		$urlID = $urlID.Replace("_","%5F")
		$urlID = $urlID.Replace(".","%2E")
		$urlID = $urlID.Replace("-","%2D")
		$oneDriveURL = $baseUrl + "/_layouts/15/onedrive.aspx?id=" + $urlID

		# Generate email content
		$dateFuture = ((Get-Date).AddDays(30)).ToUniversalTime()
		$subject = "OneDrive Files for Terminated User: " + $ownerUpper

		if (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -eq 0))
		{
			###############################################################
			#		In this decision branch, the delegate was a manager.			#
			#		There were no terminated delegates with non-expired files	#
			#		reporting to this manager at time of termination.					#
			###############################################################
			
			if($ProcessRecord -eq "Yes")
			{
				Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
			}
			$recipients = "$managerUPN,$me"
			[string[]]$to = $recipients.Split(',')
			Send-MailMessage `
				-From $from `
				-To $to `
				-Subject $subject `
				-Body $body `
				-BodyAsHtml `
				-UseSsl `
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-credential $credential2
			# Add record to the table

			$dateFormat = 'yyyy-MM-dd'
			$Today = (Get-Date).AddDays(0)
			$Thirty = (Get-Date).AddDays(30)
			$TempDate = Get-Date -Date $Today -Format $dateFormat
			$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
			[string]$SQLDate = $TempDate.ToString()
			[string]$SQL30Date = $Temp30Date.ToString()
		}
		elseif (($managerUPN -ne $null) -and ($managerEnabled -eq $true) -and ($ownerDirectReports -gt 0))
		{
			###############################################################
			#		In this decision branch, the delegate was a manager.			#
			#		There were terminated delegates with non-expired files		#
			#		reporting to this manager who quit (or was terminated)		#
			#		so we need to loop through and re-assign those files to		#
			#		this terminated manager's manager. (Director most likely)	#
			###############################################################
			
			# Give read-only permission to the manager
			if($ProcessRecord -eq "Yes")
			{
				Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
			}
			# Check records for delegated access belonging to owner less than 30 days old
			$accounts = Get-AzTableRow -table $table -CustomFilter "Valid eq 'true'" | Where-Object {$_.DelegatedTo -eq $owner}
			if (1 -eq 1)
			{
				$bodyAdd = ''
				$accountCounter=0
				$TotalAccounts = $accounts.count
				$UPNArrayList.Clear
				$URLArrayList.Clear
				foreach ($account in $accounts)
				{
					# Disconnect
					Disconnect-PnPOnline
					# Reshare existing delegated OneDrives with manager's manager if access has not expired
					$bodyAddInsert = ''
					$accountDelegationExpires = ''
					$accountDelegationExpires = $account.DelegationExpires
					if ([datetime]$accountDelegationExpires -gt $((Get-Date).ToUniversalTime()))
					{
						$accountGUID = ''
						$accountGUID = $account.RowKey
						$accountManagerUPN = ''
						$accountManagerUPN = $account.DelegatedTo
						$accountOneDriveURL = ''
						$accountOneDriveURL = $account.DelegatedURL
						$accountOwner = ''
						$accountOwner = $account.Owner
						$accountTargetFolder = ''
						$accountTargetFolder = $account.TargetFolder
						$accountURL = ''
						$accountURL = $account.URL
						$Junk = $UPNArrayList.Add($accountManagerUPN)
						$Junk = $URLArrayList.Add($accountOneDriveURL)
						
						Connect-PnPOnline -Url $accountURL -Credentials $credential2
						# Re-delegate access to new manager
						if($ProcessRecord -eq "Yes")
						{
							Set-PnPFolderPermission -List 'Documents' -Identity $accountTargetFolder -User $managerUPN -AddRole 'Read'
						}
					}
				}
				# Notify manager with the extended email containing the termed user's OneDrive folder and any unexpired OneDrive accounts for which the user received delegated access
				$bodyManager = Get-Content $HTMLFile -Raw
				$recipients = "$managerUPN,$me"
				[string[]]$to = $recipients.Split(',')
				Send-MailMessage `
					-From $from `
					-To $to `
					-Subject $subject `
					-Body $bodyManager `
					-BodyAsHtml `
					-UseSsl `
					-SmtpServer $SmtpServer `
					-Port $SmtpPort `
					-credential $credential2      
			}
			else
			{
				if($ProcessRecord -eq "Yes")
				{
					Set-PnPFolderPermission -List 'Documents' -Identity $targetFolder -User $managerUPN -AddRole 'Read'
				}
				# Notify manager with an email containing the termed user's OneDrive folder
				$body = ''
				$recipients = "$managerUPN,$me"
				[string[]]$to = $recipients.Split(',')
				Send-MailMessage `
					-From $from `
					-To $to `
					-Subject $subject `
					-Body $body `
					-BodyAsHtml `
					-UseSsl `
					-SmtpServer $SmtpServer `
					-Port $SmtpPort `
					-credential $credential2
				# Add record to the table

				$dateFormat = 'yyyy-MM-dd'
				$Today = (Get-Date).AddDays(0)
				$Thirty = (Get-Date).AddDays(30)
				$TempDate = Get-Date -Date $Today -Format $dateFormat
				$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
				[string]$SQLDate = $TempDate.ToString()
				[string]$SQL30Date = $Temp30Date.ToString()
			}
		}
		else
		{
			###############################################################
			#		In this decision branch, this is a non-manager delegate.	#
			#		This decision branch will most certainly be used most.		#
			###############################################################

			Add-Content -Path "$HTMLFile" -Value "</body>"
			Add-Content -Path "$HTMLFile" -Value "</html>"
			$body = Get-Content $HTMLFile -Raw
			$recipients = "$managerUPN,$me"
			[string[]]$to = $recipients.Split(',')
			Send-MailMessage `
				-From $from `
				-To $to `
				-Subject $subject `
				-Body $body `
				-BodyAsHtml `
				-UseSsl `
				-SmtpServer $SmtpServer `
				-Port $SmtpPort `
				-credential $credential2
				
			# Add record to the table
			#$managerUPN = 'dave.jaynes@eversana.com'

			# Write record to SQL
			$dateFormat = 'yyyy-MM-dd'
			$Today = (Get-Date).AddDays(0)
			$Thirty = (Get-Date).AddDays(30)
			$TempDate = Get-Date -Date $Today -Format $dateFormat
			$Temp30Date = Get-Date -Date $Thirty  -Format $dateFormat
			[string]$SQLDate = $TempDate.ToString()
			[string]$SQL30Date = $Temp30Date.ToString()
		}
		# Disconnect
		Disconnect-PnPOnline
	}
	Catch
	{
		Add-Content -Path "$RunningLogFile" -Value ""
		Add-Content -Path "$RunningLogFile" -Value "Ran into an error. Error is:"
		Add-Content -Path "$RunningLogFile" -Value "$($PSItem.ToString())"
		$PSItem.InvocationInfo | Format-List *
		# Notify support with an email containing the user for which delegation triggered an error
		$fromError = "AzureAutomation@eversana.com"
		$recipients = "dave.jaynes@eversana.com"
		[string[]]$to = $recipients.Split(',')
		$subject = "Error Experienced Delegating OneDrive for Terminated User: " + $ownerUpper
	
		$body = ''
		Send-MailMessage `
			-From $fromError `
			-To $to `
			-Subject $subject `
			-Body $body `
			-BodyAsHtml `
			-UseSsl `
			-SmtpServer $SmtpServer `
			-Port $SmtpPort `
			-credential $credentialsError

		# Disconnect
		Disconnect-PnPOnline
	}
}
#>

Disconnect-AzureAD|Out-File -Filepath C:\temp\junk.txt
Disconnect-SPOService|Out-File -Filepath C:\temp\junk.txt
Disconnect-AzAccount|Out-File -Filepath C:\temp\junk.txt