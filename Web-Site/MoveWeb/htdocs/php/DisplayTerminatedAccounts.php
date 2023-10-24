<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: DisplayTerminatedAccounts.php                                                               |
|       Called By: DisplayTerminatedAccounts()                                                                 |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves fields from the RawADs_VW SQL table which will be used to display the percentage  |
|                  completed progress of the Associate Termination process.                                    |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "RawADSData" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$assocID = $_POST['AssocID'];
// $assocID = '103257';
$query = ("select * from RawADs_VW where EmployeeNumber = '$assocID';");

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3,$item4,$item5,$item6,$item7,$item8)
{
    $output = '';
    $output = '{ "'
    . "domain"
    . '":"'
    . $item1
    . '", '
    . '"'
    . "sAMAccountName"
    . '":"'
    . $item2
    . '", '
    . '"'
    . "Enabled"
    . '":"'
    . $item3
    . '", '
    . '"'
    . "sn"
    . '":"'
    . $item4
    . '", '
    . '"'
    . "GivenName"
    . '":"'
    . $item5
    . '", '
    . '"'
    . "Title"
    . '":"'
    . $item6
    . '", '
    . '"'
    . "whenCreated"
    . '":"'
    . $item7
    . '", '
    . '"'
    . "whenChanged"
    . '":"'
    . $item8
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from RawADs_VW where Domain = 'ad_universal' and EmployeeNumber = '$assocID';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from RawADs_VW where Domain = 'ad_universal' and EmployeeNumber = '$assocID';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Domain  = odbc_result($rs,"Domain");
	$sAMAccountName  = odbc_result($rs,"sAMAccountName");
	$Enabled = odbc_result($rs,"Enabled");
	$sn  = odbc_result($rs,"sn");
	$GivenName  = odbc_result($rs,"GivenName");
	$Title = odbc_result($rs,"Title");
	$whenCreated  = odbc_result($rs,"whenCreated");
	$whenChanged  = odbc_result($rs,"whenChanged");

	$thisRow = get_item_html($Domain,$sAMAccountName,$Enabled,$sn,$GivenName,$Title,$whenCreated,$whenChanged);
	$Counter++;
	if($Counter < $NumRecords)
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow . ', ';
	}
	else
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow;
	}
}

$JSONData = $BeginJSONHeader . $RunningJsonQuery . $EndingJSONHeader;
print "$JSONData";
odbc_close($conn);
?>
