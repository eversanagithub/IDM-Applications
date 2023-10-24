<?php
/*
	Program Name: UpdateUserSettings.php
	Date Written: June 15th, 2023
	Written By: Dave Jaynes
	Purpose: Updates the attributes fields in the WebNewUsers table.
*/

include("DBWebConnection.php");

$EmpID = $_POST['EmpID'];
$ODDAccessLevel = $_POST['ODDAccessLevel'];
$ADACAccessLevel = $_POST['ADACAccessLevel'];
$TERMAccessLevel = $_POST['TERMAccessLevel'];
$Authorized = $_POST['Authorized'];
$AdminAccess = $_POST['AdminAccess'];
// Use if statements to test ODDAccessLevel,ADACAccessLevel and TERMAccessLevel values
// to see if they should be set to 'Yes' or 'No' in the 'WebUserRoles' table.

$TestingFile = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/UpdateUserSettingsTestingFile.txt";
//if (file_exists($TestingFile)) { unlink($TestingFile); }
$fh = fopen($TestingFile, "a");
$EmpID = $_POST['EmpID'];
$ODDAccessLevel = $_POST['ODDAccessLevel'];
$ADACAccessLevel = $_POST['ADACAccessLevel'];
$TERMAccessLevel = $_POST['TERMAccessLevel'];
$Authorized = $_POST['Authorized'];
$AdminAccess = $_POST['AdminAccess'];

$txt = "EmpID = [$EmpID]\n";
fwrite($fh,$txt);
$txt = "ODDAccessLevel = [$ODDAccessLevel]\n";
fwrite($fh,$txt);
$txt = "ADACAccessLevel = [$ADACAccessLevel]\n";
fwrite($fh,$txt);
$txt = "TERMAccessLevel = [$TERMAccessLevel]\n";
fwrite($fh,$txt);
$txt = "Authorized = [$Authorized]\n";
fwrite($fh,$txt);
$txt = "AdminAccess = [$AdminAccess]\n";
fwrite($fh,$txt);
fclose($fh);
/*
$sql = "update WebNewUsers set AccessLevel = cast('$AccessLevel' as int) where EmpID = '$EmpID'";
odbc_exec($conn,$sql);
$sql = "update WebNewUsers set Authorized = '$Authorized' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);
$sql = "update WebNewUsers set AdminAccess = '$AdminAccess' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);
*/
?>
