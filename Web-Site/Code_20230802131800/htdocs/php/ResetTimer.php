<?php
/*
				Program Name: ResetTimer.php
				Date Written: May 8th, 2023
					Written By: Dave Jaynes
	Function Called By: ExecuteTermination()
						 Purpose: Resets the current time in the LastLogin field within the WebNewUsers SQL table.
								  This table is used to track if a session is stale or now due to inactivity.
*/

include("DBWebConnection.php");
$ResetTime = $_POST['ResetTime'];
$EmpID = $_POST['EmpID'];
$sql = "update WebNewUsers set LastLogin = '$ResetTime' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);
odbc_close($conn);
?>
