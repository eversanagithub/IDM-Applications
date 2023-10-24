<?php

/*
	  Program Name: Set_EmployeeID_In_Table.php
	  Date Written: May 8th, 2023
	    Written By: Dave Jaynes
Function Called By: Set_EmployeeID_In_Table()
		   Purpose: Updates the selectedEmployeeID field within the AutoTermedRecords
					SQL table to reflect the current AssocID selected for termination.
*/

include("DBWebConnection.php");

// Called by the Set_EmployeeID_In_Table function.
// Updates the AutoTermedRecords table, setting the selectedEmployeeID field to the associateID the user selected.

$webUserDTG = $_POST['webUserDTG'];
$AssocID = $_POST['AssocID'];
$sql = "update WebSearchFields set srchAssocID = '$AssocID' where webUserDTG = '$webUserDTG'";
odbc_exec($conn,$sql);
?>
