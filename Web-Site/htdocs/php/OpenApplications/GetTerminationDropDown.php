<?php

/*
	Progran Name: GetTerminationDropDown.php
	Date Written: October 17th, 2023
	  Written By: Dave Jaynes
	     Purpose: Returns a listing of terminated users for the Compliance Notifications Web Page.
*/

// Gather connection details for the database.
include("DBWebConnection.php");

// Declare local variables.
$BeginJSONHeader = '{ "JSON_TerminationDropDown" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = 'count';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($Email)
{
    $output = '';
    $output = '{ "'
    . "Email"
    . '":"'
    . $Email
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) as count from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Terminated' and u.TerminationDate > DATEADD(day, -30, GETDATE()) and p.Email is not NULL;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select lower(Email) as Email from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where u.PositionStatus = 'Terminated' and u.TerminationDate > DATEADD(day, -30, GETDATE()) and p.Email is not NULL order by Email;";

$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Email = odbc_result($rs,"Email");
	$thisRow = get_item_html($Email);
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
