$SAP = "StatusOfODDProgress"

function Completed {
	Param (
		[string]$Action,
		[string]$Requester,
		[string]$Employee
	)
	# Generate nice associate name
	$firstName = $Employee.split("@")[0].split(".")[0]
	$lastName = $Employee.split("@")[0].split(".")[1]
	$space = ' '
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$niceLastName = ''
	for($i=0;$i -lt $lastName.length;$i++)
	{
		$x = $lastName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceLastName = $niceLastName + $x
	}
	$niceEmployeeName = $niceFirstName + $space + $niceLastName
	
	# Generate nice requster name
	$firstName = $Requester.split("@")[0].split(".")[0]
	$lastName = $Requester.split("@")[0].split(".")[1]
	$space = ' '
	$niceFirstName = ''
	for($i=0;$i -lt $firstName.length;$i++)
	{
		$x = $firstName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceFirstName = $niceFirstName + $x
	}
	$niceLastName = ''
	for($i=0;$i -lt $lastName.length;$i++)
	{
		$x = $lastName.substring($i,1)
		if($i -eq 0) { $x = $x.ToUpper() } else { $x = $x.ToLower() }
		$niceLastName = $niceLastName + $x
	}
	$niceRequesterName = $niceFirstName + $space + $niceLastName
	
	$connStr = @"
	DSN=IDMTrust;
"@
	$con = New-Object System.Data.Odbc.OdbcConnection $connStr
	$con.Open()
	
	if($Action -eq 'ADD')
	{
		$sql = "update $SAP set pctdone = '100%',msg = 'Delegation Process has Completed Successfully!',msg1 = 'Access has been granted to $niceRequesterName for the OneDrive files formally owned by $niceEmployeeName',msg2 = 'An E-Mail message has been sent to $niceRequesterName with a link providing direct access to this OneDrive site'"
	}
	else
	{
		$sql = "update $SAP set pctdone = '100%',msg = 'Sending out E-Mail to Requester',msg1 = 'Access to ${Employee}'s One-Drive Site has been removed from ${niceRequesterName}',msg2 = 'An E-Mail message has been sent to $niceRequesterName informing the associate of the access removal action'"
	}
	$cmd = New-Object System.Data.Odbc.OdbcCommand $sql, $con
	$rdr = $cmd.ExecuteNonQuery()
	$con.Close()
}

$Action = "ADD"
$Requester = "dave.jaynes@eversana.com"
$Employee = "simon.andrews@eversana.com"
Completed -Action $Action -Requester $Requester -Employee $Employee
