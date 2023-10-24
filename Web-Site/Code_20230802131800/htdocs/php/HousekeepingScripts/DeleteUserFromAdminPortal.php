<?php

/*
		Program Name: DeleteUserFromAdminPortal.php
		Date Written: June 22nd, 2023
		  Written By: Dave Jaynes
  Function Called By: UpdateUserSettings()
			 Purpose: Deletes users from the Admin Portal registered user listing.
*/

include("DBWebConnection.php");

$EmpID = $_POST['EmpID'];

$sql = "delete from WebNewUsers where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

$sql = "delete from WebUserRoles where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

$sql = "delete from WebEncryptedKeys where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

$sql = "delete from WebSearchFields where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

$sql = "delete from WebRegisteredUsers where userID = '$EmpID'";
odbc_exec($conn,$sql);

?>
