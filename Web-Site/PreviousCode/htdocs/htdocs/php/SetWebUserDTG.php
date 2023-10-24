<?php
/*
	Program Name: SetWebUserDTG.php
	Date Written: May 23th, 2023
	Written By: Dave Jaynes
	Function Called By: ExecuteTermination()
	Purpose: Updates the 'webUserDTG' variable in the 'WebLatestWebUserDTG' SQL table to
			 reflect the value of the user who is currently running the DetailedListing.pl script.
*/

include("DBWebConnection.php");
$webUserDTG = $_POST['webUserDTG'];
$sql = "update WebLatestWebUserDTG set webUserDTG = '$webUserDTG'";
odbc_exec($conn,$sql);
?>
