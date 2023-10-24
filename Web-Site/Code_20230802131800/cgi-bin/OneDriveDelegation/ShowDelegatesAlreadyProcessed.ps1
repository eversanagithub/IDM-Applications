[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
}
$connection.Close()