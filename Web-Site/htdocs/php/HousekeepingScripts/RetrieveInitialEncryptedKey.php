<?php

/*
        Program Name: RetrieveInitialEncryptedKey.php
        Date Written: June 1st, 2023
          Written By: Dave Jaynes
  Function Called By: RegisterNewUser() (In the SetCookie_functions.js file).
             Purpose: Gets the newly created Encrypted for the user so it can be 
					  written as a cookie value on the users laptop along with
					  the user's Employee ID cookie value.
*/
include("DBWebConnection.php");
$Count = '';
$EmpID = $_POST['EmplID'];
$TestFile = "C:/apache24/htdocs/php/HousekeepingScripts/TestFile.txt";
if (file_exists($TestFile)) { unlink($TestFile); }
$fh = fopen($TestFile, "w");
$txt = "EmpID = [$EmpID]\n";
fwrite($fh,$txt);
fclose($fh);

$CountNumRecords = "select count(*) from WebEncryptedKeys where EmpID = '$EmpID';";

$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
$sql="select EncryptedKey from WebEncryptedKeys where EmpID = '$EmpID';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$EncryptedKey = odbc_result($rs,"EncryptedKey");
	print "$EncryptedKey";
}
odbc_close($conn);
?>
