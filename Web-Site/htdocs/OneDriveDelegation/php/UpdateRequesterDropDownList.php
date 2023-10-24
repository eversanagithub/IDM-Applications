<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_RequesterName" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = 'count';

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
$CountNumRecords = "select count(*) as count from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Active' and p.Email is not NULL and p.Email like '%$requesterName%';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
if($requesterName == '')
{
	$sql="select lower(p.Email) as Email from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Active' and p.Email is not NULL order by u.FirstName,u.LastName;";
}
else
{
	$sql="select lower(p.Email) as Email from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Active' and p.Email is not NULL and p.Email like '%$requesterName%' order by u.FirstName,u.LastName;";
}
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$UPN = odbc_result($rs,"Email");
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
