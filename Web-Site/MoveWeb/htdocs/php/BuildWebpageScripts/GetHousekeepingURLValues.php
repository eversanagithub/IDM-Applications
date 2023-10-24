<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: WebHousekeepingApplicationURL.php                                                           |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves the PHP script that will be creating the HTML code for sending an                 |
|                  E-Mail invite to a user for access to the Admin Portal.                                     |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "GetApplicationURL" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$application = $_POST['application'];
// $application = 'AddUserToPortal';

// Get record count
$CountNumRecords = "select count(*) from WebHousekeepingApplicationURL where application = '$application';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebHousekeepingApplicationURL where application = '$application';";
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
