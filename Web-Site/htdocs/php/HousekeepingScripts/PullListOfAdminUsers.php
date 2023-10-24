<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: PullListOfAdminUsers.php                                                                    |
|    Date Written: June 15th, 2023                                                                             |
|      Written By: Dave Jaynes                                                                                 |
|         Purpose: Retrieves the list of users allowed to execute administrative housekeeping tasks.           |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "ListOfAdminUsers" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1)
{
    $output = '';
    $output = '{ "'
    . "EmpID"
    . '":"'
    . $item1
	. '"'	
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebNewUsers where AdminAccess = 'Yes';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebNewUsers where AdminAccess = 'Yes';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$EmpID = odbc_result($rs,"EmpID");
	$thisRow = get_item_html($EmpID);
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
