<?php
/*
				Program Name: ExecuteTermination.php
				Date Written: June 30th, 2023
					Written By: Dave Jaynes
	Function Called By: ExecuteTermination()
						 Purpose: Executes the DisablePersonAdHoc_UniversalAccountsOnly SQL Stored Procedure
											which disables the universal.co accounts linked to the 'AssocID' field.
*/

include("DBWebConnection.php");
$AssocID = $_POST['AssocID'];
// $AssocID = "103475";

$Count = 'count';

// Find out who is doing the terminating.
$sql = "select WhoAmI from WebWhoAmI;";
$rs = odbc_exec($conn,$sql);
odbc_fetch_row($rs);
$WhoAmI = odbc_result($rs,'WhoAmI');

// Get the proper names of who is doing the terminating 
// and who is being terminated for logging purposes.
$sql = "select * from Profile where EMPLID = '$WhoAmI';";
$rs = odbc_exec($conn,$sql);
$Terminator_FN = odbc_result($rs,"PrefFName");
$Terminator_LN = odbc_result($rs,"PrefLName");
$sql = "select top 1 * from RawADs_VW where EmployeeNumber = '$AssocID';";
$rs = odbc_exec($conn,$sql);
$Terminatee_FN = odbc_result($rs,"GivenName");
$Terminatee_LN = odbc_result($rs,"sn");

// Ensure another associate is not currently being processed.
$TotalRecords = 10;
$TotalApproved = 0;
$TotalProcessing = 10;
while($TotalRecords > 0)
{
  //$CountNumRecords = "select count(*) as count from adhoc_request where Status = 'Approved';";
  //$rs = odbc_exec($conn,$CountNumRecords);
  //odbc_fetch_row($rs);
  //$TotalApproved = odbc_result($rs,'count');
  
  $CountNumRecords = "select count(*) as count from adhoc_request where Status = 'Processing';";
  $rs = odbc_exec($conn,$CountNumRecords);
  odbc_fetch_row($rs);
  $TotalProcessing = odbc_result($rs,'count');
  
  $TotalRecords = $TotalApproved + $TotalProcessing;
  
  // Log the waiting for other associate to end getting processed.
  if($TotalRecords > 0)
  {
    $timeNow = date("Y-m-d H:i:s");
    $sql = "insert into WebIDMWebsiteLoggedEvents(ExecutedBy,application,time_of_execution,description) values ('$WhoAmI','Associate Termination','$timeNow','Waiting on $TotalRecords record(s) to finish processing before kicking off termination.';";
    odbc_exec($conn,$sql);
  }
  
  sleep(2);
}

// Perform the actual termination.
$DisableSQL = "exec DisablePersonAdHoc_Accounts $AssocID; WAITFOR DELAY '00:00:05';exec msdb.dbo.sp_start_job N'IDM - AD-Adhoc Account Provisioning - DIS/SDIS'";
odbc_exec($conn,$DisableSQL);

// Log the event.
$timeNow = date("Y-m-d H:i:s");
$PlainExplaination = "$Terminator_FN $Terminator_LN is preparing to terminate associate $Terminatee_FN $Terminatee_LN ($AssocID).";
$LoggedSQL = "SQL Command Submitted: exec DisablePersonAdHoc_Accounts $AssocID; WAITFOR DELAY 00:00:05;exec msdb.dbo.sp_start_job IDM - AD-Adhoc Account Provisioning - DIS/SDIS";
$sql = "insert into WebIDMWebsiteLoggedEvents(ExecutedBy,application,time_of_execution,description) values ('$WhoAmI','Associate Termination','$timeNow','$PlainExplaination');";
odbc_exec($conn,$sql);
$timeNow = date("Y-m-d H:i:s");
$sql = "insert into WebIDMWebsiteLoggedEvents(ExecutedBy,application,time_of_execution,description) values ('$WhoAmI','Associate Termination','$timeNow','$LoggedSQL');";
odbc_exec($conn,$sql);

?>
