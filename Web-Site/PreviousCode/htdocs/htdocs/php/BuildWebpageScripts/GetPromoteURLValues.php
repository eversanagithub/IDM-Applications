<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetPromoteURLValues.php                                                                     |
|    Date Written: July 17th, 2023                                                                             |
|      Written By: Dave Jaynes                                                                                 |
|         Purpose: Retrieves the URL value for the particular button clicked in the Promote code application.  |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "GetApplicationURL" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$application = $_POST['application'];
// $application = 'Promote';

// Get record count
$CountNumRecords = "select count(*) from WebPromoteApplicationURL where application = '$application';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebPromoteApplicationURL where application = '$application';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$applicationURL = odbc_result($rs,"applicationURL");
	print "$applicationURL";
}
odbc_close($conn);
?>
