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
function get_item_html($TermedUser,$RequestingUser,$DateTimeProcessed,$OverallStatus,$CurrentModuleProcessing)
{
    $output = '';
    $output = '{ "'
    . "TermedUser"
    . '":"'
    . $TermedUser
    . '", '
	. '"'
    . "RequestingUser"
    . '":"'
    . $RequestingUser
    . '", '	
	. '"'
    . "DateTimeProcessed"
    . '":"'
    . $DateTimeProcessed
    . '", '	
	. '"'
    . "OverallStatus"
    . '":"'
    . $OverallStatus
    . '", '	
	. '"'
    . "CurrentModuleProcessing"
    . '":"'
    . $CurrentModuleProcessing
    . '"'
    . " }";
    return $output;
}

$sql="select * from WebAdhocODDProcess;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$NumRecords = 1;
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$TermedUser = odbc_result($rs,"TermedUser");
	$RequestingUser = odbc_result($rs,"RequestingUser");
	$DateTimeProcessed = odbc_result($rs,"DateTimeProcessed");
	$OverallStatus = odbc_result($rs,"OverallStatus");
	$CurrentModuleProcessing = odbc_result($rs,"CurrentModuleProcessing");
	$thisRow = get_item_html($TermedUser,$RequestingUser,$DateTimeProcessed,$OverallStatus,$CurrentModuleProcessing);
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
