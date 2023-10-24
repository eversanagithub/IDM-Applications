<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: BuildPromoteSelectionButtons.php                                                            |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: Retrieves the Promote Button attributes so the button objects can be made.                  |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "ApplicationValues" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($FunctionName,$FunctionID,$OnClick,$MouseOver,$MouseLeave,$Image,$Width,$Height)
{
    $output = '';
    $output = '{ "'
    . "FunctionName"
    . '":"'
    . $FunctionName
    . '", '
    . '"'
    . "FunctionID"
    . '":"'
    . $FunctionID
    . '", '
    . '"'
    . "OnClick"
    . '":"'
    . $OnClick
    . '", '
    . '"'
    . "MouseOver"
    . '":"'
    . $MouseOver
    . '", '
    . '"'
    . "MouseLeave"
    . '":"'
    . $MouseLeave
    . '", '
    . '"'
    . "Image"
    . '":"'
	. $Image
    . '", '
    . '"'
    . "Width"
    . '":"'
	. $Width
    . '", '
    . '"'
    . "Height"
    . '":"'
    . $Height
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebBuildPromoteButtons;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebBuildPromoteButtons;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$FunctionName = odbc_result($rs,"FunctionName");
	$FunctionID = odbc_result($rs,"FunctionID");
	$OnClick = odbc_result($rs,"OnClick");
	$MouseOver = odbc_result($rs,"MouseOver");
	$MouseLeave = odbc_result($rs,"MouseLeave");
	$Image = odbc_result($rs,"Image");
	$Width = odbc_result($rs,"Width");
	$Height = odbc_result($rs,"Height");

	$thisRow = get_item_html($FunctionName,$FunctionID,$OnClick,$MouseOver,$MouseLeave,$Image,$Width,$Height);
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
