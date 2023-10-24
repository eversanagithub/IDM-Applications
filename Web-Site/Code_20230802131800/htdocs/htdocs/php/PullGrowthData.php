<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: PullGrowthData.php                                                                    |
|    Date Written:                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves users attributes from the 'IDM_Website_Profile' SQL table based on the current    |
|                  users 'WebPageDTG' Local Storage variable.                                                  |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "ListOfWGNumbers" : [';
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
    . "WGName"
    . '":"'
    . $item1
    . '", '
    . '"'
    . "WGNumber"
    . '":"'
    . $item2
    . '"'
    . " }";
    return $output;
}

// Get record count

$CountNumRecords = "select count(*) from IdentityCountTracking where DtInserted > '20221231235959000';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select DtInserted,ULTIPRO from IdentityCountTracking where DtInserted > '20221231235959000' order by DtInserted;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$DtInserted = odbc_result($rs,"DtInserted");
	$ULTIPRO = odbc_result($rs,"ULTIPRO");
	$thisRow = get_item_html($DtInserted,$ULTIPRO);
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
