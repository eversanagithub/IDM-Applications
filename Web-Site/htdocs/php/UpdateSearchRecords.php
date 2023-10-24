<?php

/*
				Program Name: UpdateSearchRecords.php
				Date Written: May 8th, 2023
					Written By: Dave Jaynes
	Function Called By: Set_EmployeeID_In_Table()
						 Purpose: Updates the selectedEmployeeID field within the AutoTermedRecords
											SQL table to reflect the current AssocID selected for termination.
*/

include("DBWebConnection.php");

$EmpID = $_POST['EmpID'];
$SrchAssocID = $_POST['SrchAssocID'];

/*
$EmpID = "103257";
$SrchAssocID = "102";
*/

// This will store the latest employee ID search string when looking for employees to terminate.
$sql = "update WebSearchFields set srchAssocID = '$SrchAssocID' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

// This will tell the ProcessTermination.pl script who the last user was that selected a record for deletion.
$sql = "update WebWhoAmI set WhoAmi = '$EmpID'";
odbc_exec($conn,$sql);
/*

$webUserDTG = $_POST['webUserDTG'];
$srchAssocID = $_POST['srchAssocID'];

$sql = "update WebSearchFields set srchAssocID = '$srchAssocID' where webUserDTG = '$webUserDTG'";
odbc_exec($conn,$sql);

$myFile = fopen("UpdateAutoTermedRecordSQLStatement.txt", "w");
$txt = "update WebSearchFields set srchAssocID = '" . $srchAssocID . "' where webUserDTG = '" . $webUserDTG . "';";
fwrite($myFile,$txt);
fclose($myFile);
*/
?>
