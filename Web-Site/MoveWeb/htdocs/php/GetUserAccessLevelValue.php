<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetUserAccessLevelValue.php                                                                 |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves the users AccessLevel value.                |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "GetApplicationURL" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$EmplID = $_POST['EmplID'];
// $application = 'OneDriveDelegation';

// Get record count
$CountNumRecords = "select count(*) from WebNewUsers where EmpID = '$EmplID';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebNewUsers where EmpID = '$EmplID';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$AccessLevel = odbc_result($rs,"AccessLevel");
	print "$AccessLevel";
}
odbc_close($conn);
?>
