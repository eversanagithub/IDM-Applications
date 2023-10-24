<?php

/*
		Program Name: UpdateUserApplicationSettings.php
		Date Written: June 22nd, 2023
		  Written By: Dave Jaynes
  Function Called By: UpdateUserSettings()
			 Purpose: Updates the user's application access listing so that certain app buttons are visible to them.
*/

include("DBWebConnection.php");

$EmpID = $_POST['EmpID'];
$ApplicationCheckBox = $_POST['ApplicationCheckBox'];
$ActivateButton = $_POST['ActivateButton'];

if($ApplicationCheckBox == 'Authorized' || $ApplicationCheckBox == 'AdminAccess')
{
	$sql = "update WebNewUsers set $ApplicationCheckBox = '$ActivateButton' where EmpID = '$EmpID'";
	odbc_exec($conn,$sql);
}

$sql = "update WebUserRoles set $ApplicationCheckBox = '$ActivateButton' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

?>
