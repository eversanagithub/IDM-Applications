<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: DisplayPromotionProgress.php                                                                |
|    Date Written: July 17th, 2023                                                                             |
|      Written By: Dave Jaynes                                                                                 |
|         Purpose: Retrieves fields from the Web Code promotion process.                                       |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "PromotionData" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($status,$task,$message,$percentage,$started,$completed,$Header1,$Header2,$Header3,$Header4,$Header5,$MainHeader)
{
    $output = '';
    $output = '{ "'
    . "status"
    . '":"'
    . $status
    . '", '
    . '"'
    . "task"
    . '":"'
    . $task
    . '", '
    . '"'
    . "message"
    . '":"'
    . $message
    . '", '
    . '"'
    . "percentage"
    . '":"'
    . $percentage
    . '", '
    . '"'
    . "started"
    . '":"'
    . $started
    . '", '
    . '"'
    . "completed"
    . '":"'
    . $completed
    . '", '
		. '"'
    . "Header1"
    . '":"'
    . $Header1
    . '", '
		. '"'
    . "Header2"
    . '":"'
    . $Header2
    . '", '
		. '"'
    . "Header3"
    . '":"'
    . $Header3
    . '", '
		. '"'
    . "Header4"
    . '":"'
    . $Header4
    . '", '
		. '"'
    . "Header5"
    . '":"'
    . $Header5
    . '", '
    . '"'
    . "MainHeader"
    . '":"'
    . $MainHeader
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebPromoteToProd;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebPromoteToProd;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$status  = odbc_result($rs,"status");
	$task  = odbc_result($rs,"task");
	$message  = odbc_result($rs,"message");
	$percentage  = odbc_result($rs,"percentage");
	$started = odbc_result($rs,"started");
	$completed  = odbc_result($rs,"completed");
	$Header1  = odbc_result($rs,"Header1");
	$Header2  = odbc_result($rs,"Header2");
	$Header3  = odbc_result($rs,"Header3");
	$Header4  = odbc_result($rs,"Header4");
	$Header5  = odbc_result($rs,"Header5");
	$MainHeader  = odbc_result($rs,"MainHeader");
	$thisRow = get_item_html($status,$task,$message,$percentage,$started,$completed,$Header1,$Header2,$Header3,$Header4,$Header5,$MainHeader);
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
