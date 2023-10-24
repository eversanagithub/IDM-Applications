<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_DepartmentCode" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2)
{
	$Description = $item2 . " (" . $item1 . ")";
	$output = '';
	$output = '{ "'
		. "code"
		. '":"'
		. $item1
		. '", '
		. '"'
		. "description"
		. '":"'
		. $Description
		. '"'
		. " }";
	return $output;
}

// Get record count
$CountNumRecords = "select count(*) from HR_Departments;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select * from HR_Departments order by description;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$code = odbc_result($rs,"code");
	$description = odbc_result($rs,"description");
	$thisRow = get_item_html($code,$description);
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
