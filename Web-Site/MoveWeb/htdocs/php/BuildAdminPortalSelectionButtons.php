<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: BuildAdminPortalSelectionButtons.php                                                        |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves the Admin Portal Button attributes so the button objects can be made.             |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "ApplicationValues" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3,$item4,$item5,$item6)
{
    $output = '';
    $output = '{ "'
    . "FunctionName"
    . '":"'
    . $item1
    . '", '
    . '"'
    . "FunctionID"
    . '":"'
    . $item2
    . '", '
    . '"'
    . "Value"
    . '":"'
    . $item3
    . '", '
    . '"'
    . "Image"
    . '":"'
    . $item4
    . '", '
    . '"'
    . "Width"
    . '":"'
    . $item5
    . '", '
    . '"'
    . "Height"
    . '":"'
    . $item6
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebBuildSelectionButtons;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebBuildSelectionButtons;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$FunctionName = odbc_result($rs,"FunctionName");
	$FunctionID = odbc_result($rs,"FunctionID");
	$Value = odbc_result($rs,"Value");
	$Image = odbc_result($rs,"Image");
	$Width = odbc_result($rs,"Width");
	$Height = odbc_result($rs,"Height");

	$thisRow = get_item_html($FunctionName,$FunctionID,$Value,$Image,$Width,$Height);
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
