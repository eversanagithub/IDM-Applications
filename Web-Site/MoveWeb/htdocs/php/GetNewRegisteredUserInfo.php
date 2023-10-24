<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetNewRegisteredUserInfo.php                                                                |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves specific record from the WebNewUsers SQL table.                                   |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "NewUser" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$EmpID = $_POST['EmpID'];
// $Name = 'Dave Jaynes';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3,$item4,$item5,$item6)
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
	. '",'	
	. '"'
    . "AccessLevel"
    . '":"'
    . $item3
	. '",'	
	. '"'
    . "Registered"
    . '":"'
	. $item4
	. '",'	
	. '"'
    . "Authorized"
    . '":"'
    . $item5
	. '",'	
	. '"'
    . "AdminAccess"
    . '":"'
    . $item6
	. '"'	
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebNewUsers where EmpID = '$EmpID';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebNewUsers where EmpID = '$EmpID' order by Name;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$EmpID = odbc_result($rs,"EmpID");
	$Name = odbc_result($rs,"Name");
	$AccessLevel = odbc_result($rs,"AccessLevel");
	$Registered = odbc_result($rs,"Registered");
	$Authorized = odbc_result($rs,"Authorized");
	$AdminAccess = odbc_result($rs,"AdminAccess");
	$thisRow = get_item_html($EmpID,$Name,$AccessLevel,$Registered,$Authorized,$AdminAccess);
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
