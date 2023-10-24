<?php

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_FormerAssociateNames" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = 'count';

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
$CountNumRecords = "select count(*) as count from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Terminated' and u.TerminationDate > DATEADD(day, -45, GETDATE()) and p.Email is not NULL;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select lower(p.Email) as Email from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Terminated' and u.TerminationDate > DATEADD(day, -45, GETDATE()) and p.Email is not NULL order by u.FirstName,u.LastName;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Owner = odbc_result($rs,"Email");
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
