<?php
/*
	Program Name: UpdateApplicationSettings.php
	Date Written: June 15th, 2023
	Written By: Dave Jaynes
	Purpose: Updates the application access level fields in the WebAdminPortalApplicationURL table.
	         This access level controls which users can access the application based on each users
			 own access level rights. For instance, a user who has access level rights of '1' can
			 only execute applications which have a access level of '1' as well. Users who have an
			 access level of '2' can execute application which have an access level of '1' or '2'.
			 The highest access level is '3'.
*/

include("DBWebConnection.php");

$Application = $_POST['Application'];
$AccessLevel = $_POST['AccessLevel'];

$sql = "update WebAdminPortalApplicationURL set level = cast('$AccessLevel' as int) where Application = '$Application'";
odbc_exec($conn,$sql);
?>
