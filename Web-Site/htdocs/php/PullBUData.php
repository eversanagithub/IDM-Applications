<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: PullBUData.php                                                                    |
|    Date Written:                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves users attributes from the 'IDM_Website_Profile' SQL table based on the current    |
|                  users 'WebPageDTG' Local Storage variable.                                                  |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "ListOfBUNumbers" : [';
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
    . "BUName"
    . '":"'
    . $item1
    . '", '
    . '"'
    . "BUNumber"
    . '":"'
    . $item2
    . '"'
    . " }";
    return $output;
}

$NumRecords = 0;
$sql="select BU, count(*) as Number from Profile where Active = 'A' and BU is not null and BU != '' group by BU order by BU;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$NumRecords++;
}

$sql="select BU, count(*) as Number from Profile where Active = 'A' and BU is not null and BU != '' group by BU order by BU;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$BUName = odbc_result($rs,"BU");
	$BUNumber = odbc_result($rs,"Number");
	$thisRow = get_item_html($BUName,$BUNumber);
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
