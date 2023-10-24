<?php

// Gather connection details for the database.
include("ProdDBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_JobCode" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2)
{
    $output = '';
    $output = '{ "'
    . "jobCode"
    . '":"'
    . $item1
	. '", '
    . '"'
    . "longDescription"
    . '":"'
    . $item2
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from HR_JobCodes;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select * from HR_JobCodes order by longDescription;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$jobCode = odbc_result($rs,"jobCode");
	$longDescription = odbc_result($rs,"longDescription");
	$thisRow = get_item_html($jobCode,$longDescription);
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