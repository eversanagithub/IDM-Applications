<?php

// Gather connection details for the database.
include("ProdDBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_TextTracking" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3)
{
    $output = '';
    $output = '{ "'
    . "lastName"
    . '":"'
    . $item1
	. '", '
    . '"'
    . "firstName"
    . '":"'
    . $item2
    . '", '
    . '"'
    . "phoneNumber"
    . '":"'
    . $item3
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebRegisteredUsers;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select * from WebRegisteredUsers order by firstName;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$lastName = odbc_result($rs,"lastName");
	$firstName = odbc_result($rs,"firstName");
	$phoneNumber = odbc_result($rs,"phoneNumber");
	$thisRow = get_item_html($lastName,$firstName,$phoneNumber);
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