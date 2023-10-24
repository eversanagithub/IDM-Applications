<?php

// Gather connection details for the database.
include("ProdDBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_FormerAssociateNames" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

$assocName = $_POST['assocName'];
// $assocName = "wol";

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1)
{
    $output = '';
    $output = '{ "'
    . "formerAssociateNames"
    . '":"'
    . $item1
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebDelegatesAlreadyProcessed where Owner like '%$assocName%';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
if($assocName == '')
{
	$sql="select * from WebDelegatesAlreadyProcessed order by Owner;";
}
else
{
	$sql="select * from WebDelegatesAlreadyProcessed where Owner like '%$assocName%' order by Owner;";
}
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Owner = odbc_result($rs,"Owner");
	$thisRow = get_item_html($Owner);
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