<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "oddstats" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3,$item4)
{
    $output = '';
    $output = '{ "'
    . "pctdone"
    . '":"'
    . $item1
    . '", '
	. '"'
    . "msg"
    . '":"'
    . $item2
    . '", '	
	. '"'
    . "msg1"
    . '":"'
    . $item3
    . '", '	
	. '"'
    . "msg2"
    . '":"'
    . $item4
    . '"'
    . " }";
    return $output;
}

$sql="select * from WebStatusOfODDProgress;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$NumRecords = 1;
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$PctDone = odbc_result($rs,"pctdone");
	$MSG = odbc_result($rs,"msg");
	$MSG1 = odbc_result($rs,"msg1");
	$MSG2 = odbc_result($rs,"msg2");
	$thisRow = get_item_html($PctDone,$MSG,$MSG1,$MSG2);
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
