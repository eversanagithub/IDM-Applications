<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: CreateRegisterUserDropDown.php                                                              |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves names and employee IDs from the WebNewUsers SQL table.                            |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "Register" : [';
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
    . "EmpID"
    . '":"'
    . $item1
    . '",'
	. '"'
    . "Name"
    . '":"'
    . $item2
	. '"'	
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebNewUsers where Registered = 'No';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebNewUsers where Registered = 'No' order by Name;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$EmpID = odbc_result($rs,"EmpID");
	$Name = odbc_result($rs,"Name");
	$thisRow = get_item_html($EmpID,$Name);
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
