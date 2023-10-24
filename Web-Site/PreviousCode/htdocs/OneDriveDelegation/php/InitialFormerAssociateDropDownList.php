<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_FormerAssociateNames" : [';
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
    . "formerAssociateNames"
    . '":"'
    . $item1
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from Ultipro_ADRpt where PositionStatus = 'Terminated' and TerminationDate > convert(varchar, getdate()-30,20) and WorkEmail is not NULL and WorkEmail != ''
;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select lower(WorkEmail) as UPN from Ultipro_ADRpt where PositionStatus = 'Terminated' and TerminationDate > convert(varchar, getdate()-30,20) and WorkEmail is not NULL and WorkEmail != '' order by WorkEmail;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Owner = odbc_result($rs,"UPN");
	$Owner = strtolower($Owner);
	if(str_contains($Owner, 'a_'))
	{
		$doNothing = "Yes";
	}
	else
	{
		$thisRow = get_item_html($Owner);
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
}
$JSONData = $BeginJSONHeader . $RunningJsonQuery . $EndingJSONHeader;
print "$JSONData";
odbc_close($conn);
?>
