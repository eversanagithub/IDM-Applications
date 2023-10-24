# This code lives on the IDMGMTAPP01 production server.

function CopyCurrentCode    
{
	param(
		[string]$Source,
		[string]$Destination
	)  
	Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}


function Update    
{
	param(
		[string]$File
	)  
	(Get-Content $File) | ForEach-Object { $_ -replace "http://iuatidmgmtapp01", "http://idmgmtapp01" } | Set-Content $File
	(Get-Content $File) | ForEach-Object { $_ -replace "Development Site", "Production Site" } | Set-Content $File
	(Get-Content $File) | ForEach-Object { $_ -replace "DevEncryptedKey", "ProdEncryptedKey" } | Set-Content $File
	(Get-Content $File) | ForEach-Object { $_ -replace "DevEmpID", "ProdEmpID" } | Set-Content $File
}

function GetPromotionStatus
{
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "select status from WebPromoteToProd"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteReader()
	while ($rdr.Read())
	{
		$DTG = $rdr["status"]
	}
	$rdr.Close()
	$con.Close()
	return $DTG
}

function UpdatePromotionProgress {
	Param (
		[string]$Status,
		[string]$Task,
		[string]$Message,
		[datetime]$Started,
		[datetime]$Completed,
		[string]$Header1,
		[string]$Header2,
		[string]$Header3,
		[string]$Header4,
		[string]$Header5,
		[string]$MainHeader
	)
	$connStr = @"
	DSN=DBWebConnection;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	$sql = "update WebPromoteToProd set status = '$Status', task = '$Task', message = '$Message', started = '$Started', completed = '$Completed', Header1 = '$Header1', Header2 = '$Header2', Header3 = '$Header3', Header4 = '$Header4', Header5 = '$Header5', MainHeader = '$MainHeader'"
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

$PromotionStatus = GetPromotionStatus
if($PromotionStatus -eq "Waiting")
{
	$StartDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	$MainHeading = "Step 2 of 2: Converting Development files to Production format"
	
	UpdatePromotionProgress -Status "Running" -Task "Initializing Promotion Process" -Message "Promotion Process has Started" -Started $StartDate -Completed $StartDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message" -Header5 "N/A" -MainHeader $MainHeading
	$TotalFiles = 0
	$TotalFiles = (Get-ChildItem -Recurse C:\Apache24\htdocs\| Measure-Object).Count
	$TotalFiles += (Get-ChildItem -Recurse C:\Apache24\cgi-bin\| Measure-Object).Count

	UpdatePromotionProgress -Status "Running" -Task "Starting Promotion" -Message "Compilation of script listing completed. Commencing with Production Code Promotion" -Percentage "htdocs" -Started $StartDate -Completed $StartDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message" -Header5 "N/A" -MainHeader $MainHeading
	
	sleep 2

	$FileCount = 0
	Get-ChildItem -Path "c:\Apache24\htdocs" -Recurse |Foreach-Object {
		$File = $_.FullName
		$extn = [IO.Path]::GetExtension($File)
		$size = $File.Length
		switch($extn)
		{
			".html"
			{
				Update -File $File
			}
			".htm"
			{
				Update -File $File
			}
			".pl"
			{
				Update -File $File
			}
			".php"
			{
				Update -File $File
			}
			".js"
			{
				Update -File $File
			}
		}
		$FileCount++
		$Percentage = (($FileCount / $TotalFiles) * 100)
		$Percentage = [math]::Round($Percentage,1)
		$RunningDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		$FileArray   = $File.split('\')
		$FileName = $FileArray | Select-Object -Last 1
		$StringPercentage = $Percentage.ToString()
		$StringPercentageArray = $StringPercentage.split('.')
		$StringPercentage = $StringPercentageArray | Select-Object -First 1
		if($FileName.Length -gt 30) 
		{ 
			$DisplayFileName = $FileName.substring(0,30)
		}
		else
		{
			$DisplayFileName = $FileName
		}
		UpdatePromotionProgress -Status "Running" -Task "Updating htdocs files" -Message "$StringPercentage%" -Started $StartDate -Completed $RunningDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message" -Header5 $DisplayFileName -MainHeader $MainHeading
	}

	Get-ChildItem -Path "c:\Apache24\cgi-bin" -Recurse |Foreach-Object {
		$File = $_.FullName
		$extn = [IO.Path]::GetExtension($File)
		$size = $File.Length
		switch($extn)
		{
			".html"
			{
				Update -File $File
			}
			".htm"
			{
				Update -File $File
			}
			".pl"
			{
				Update -File $File
			}
			".php"
			{
				Update -File $File
			}
			".js"
			{
				Update -File $File
			}
		}
		$FileCount++
		$Percentage = (($FileCount / $TotalFiles) * 100)
		$Percentage = [math]::Round($Percentage,2)
		$RunningDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		$FileArray = $File.split('\')
		$FileName = $FileArray | Select-Object -Last 1
		$StringPercentage = $Percentage.ToString()
		$StringPercentageArray = $StringPercentage.split('.')
		$StringPercentage = $StringPercentageArray | Select-Object -First 1
		if($FileName.Length -gt 30) 
		{ 
			$DisplayFileName = $FileName.substring(0,30)
		}
		else
		{
			$DisplayFileName = $FileName
		}
		UpdatePromotionProgress -Status "Running" -Task "Updating cgi-bin files" -Message "$StringPercentage%" -Started $StartDate -Completed $RunningDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message" -Header5 $DisplayFileName -MainHeader $MainHeading
	}
	
	Copy-Item "C:\Apache24\htdocs\images\ProductionSite.jpg" -Destination "C:\Apache24\htdocs\images\ThisSite.jpg" -Force
	
	$CompletedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	
	UpdatePromotionProgress -Status "Complete" -Task "Promotion Process Completed"  -Message "100%" -Percentage "N/A" -Started $StartDate -Completed $CompletedDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message"  -Header5 "N/A" -MainHeader $MainHeading
	
	sleep 3
	
	UpdatePromotionProgress -Status "Complete" -Task "Promotion Process Completed"  -Message "The promotion of development code to production has successfully completed!" -Percentage "N/A" -Started $StartDate -Completed $CompletedDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message"  -Header5 "N/A" -MainHeader $MainHeading
	
	sleep 4
	
	UpdatePromotionProgress -Status "Complete" -Task "Promotion Process Completed"  -Message "You may now use the updated production IDM Website!" -Percentage "N/A" -Started $StartDate -Completed $CompletedDate -Header1 "Start Time" -Header2 "Completion Time" -Header3 "File Being Processed" -Header4 "Status Message"  -Header5 "N/A" -MainHeader $MainHeading
}