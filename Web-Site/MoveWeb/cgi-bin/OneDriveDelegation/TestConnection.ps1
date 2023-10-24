[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Test-ODBCConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
                    HelpMessage="IDMTrust")]
                    [string]$DSN
    )
    $conn = new-object system.data.odbc.odbcconnection
    $conn.connectionstring = "DSN=IDMTrust"
    
    try {
        if (($conn.open()) -eq $true) {
            $conn.Close()
            $true
        }
        else {
            $false
			Write-Host $_.Exception.Message
        }
    } catch {
        Write-Host $_.Exception.Message
        $false
    }
}

# ODBC Driver 18 for SQL Server

#Add-OdbcDsn -Name "IDMTrust" -DriverName "SQL Server" -DsnType "System" -SetPropertyValue @("Server=iuatidmgmtsql01.universal.co", "Trusted_Connection=Yes", "Database=IAM")

$DSN = Get-OdbcDsn -Name "IDMTrust" -DsnType "System" -Platform "64-bit"

#$DSN = "IDMTrust"
Test-ODBCConnection -DSN $DSN

<#
$ServerName = "idmgmtsql01"
$databasename = "IAM";
$ConnectionString = "DRIVER={SQL Server};server=$ServerName;database=$databasename;trusted_connection=True"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $ConnectionString
$connection.Open()

#$Query = "select Owner,Manager,URL,DelegatedTo,DelegatedOn,DelegatedURL,DelegationExpires,TargetFolder,Valid,ReminderModify,ReminderSentOn from delegates_already_processed" 

$Query = "select Owner from delegates_already_processed" 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Query
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$SqlCmd.Connection = $Connection
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

foreach ($Row in $DataSet.Tables[0].Rows)
{
	$row.Owner
	#$row.Manager
	#$row.URL
	#$row.DelegatedTo
	#$row.DelegatedOn
	#$row.DelegatedURL
	#$row.DelegationExpires
	#$row.TargetFolder
	#$row.Valid
	#$row.ReminderModify
	#$row.ReminderSentOn
}
$connection.Close()
#>