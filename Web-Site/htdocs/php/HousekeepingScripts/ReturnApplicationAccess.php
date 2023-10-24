<?php

/*
		Program Name: ReturnApplicationAccess.php
		Date Written: June 22nd, 2023
		  Written By: Dave Jaynes
  Function Called By: UpdateUserSettings()
			 Purpose: Retrieves the user's application access settings.
*/

include("DBWebConnection.php");

$EmpID = $_POST['EmpID'];
$Application = $_POST['Application'];

$TestingFile = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/GetApplicationAccess_TestingFile.txt";
if (file_exists($TestingFile)) { unlink($TestingFile); }
$fh = fopen($TestingFile, "a");

$txt = "EmpID = [$EmpID]\n";
fwrite($fh,$txt);
$txt = "Application = [$Application]\n";
fwrite($fh,$txt);
fclose($fh);

$sql = "select $Application from WebUserRoles where EmplID  = '$EmpID'";
$result = odbc_exec($conn,$sql);
print $result;
?>
