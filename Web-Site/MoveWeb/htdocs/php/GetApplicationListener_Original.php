<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetApplicationListener.php                                                                  |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves the cooresponding application URL for a passed application string.                |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "GetApplicationURL" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$application = $_POST['application'];
// $application = 'OneDriveDelegation';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1)
{
    $output = '';
    $output = '{ "'
    . "applicationURL"
    . '":"'
    . $item1
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebApplicationURL where application = '$application';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebApplicationURL where application = '$application';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$applicationURL = odbc_result($rs,"applicationURL");
	$thisRow = get_item_html($applicationURL);
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
