<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_RequesterName" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

$requesterName = $_POST['requesterName'];
//$requesterName = "ja";

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1)
{
    $output = '';
    $output = '{ "'
    . "requesterNames"
    . '":"'
    . $item1
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from Feed_AD_Azure where (extensionAttribute4 like 'FTE%' or extensionAttribute4 like '%human%') and UPN not like 'srv_%' and AccountEnabled = 'True' and UPN like '%$requesterName%';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
if($requesterName == '')
{
	$sql="select * from Feed_AD_Azure where (extensionAttribute4 like 'FTE%' or extensionAttribute4 like '%human%') and UPN not like 'srv_%' and AccountEnabled = 'True' order by UPN;";
}
else
{
	$sql="select * from Feed_AD_Azure where (extensionAttribute4 like 'FTE%' or extensionAttribute4 like '%human%') and UPN not like 'srv_%' and AccountEnabled = 'True' and UPN like '%$requesterName%' order by UPN;";
}
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$UPN = odbc_result($rs,"UPN");
	$thisRow = get_item_html($UPN);
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
