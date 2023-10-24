<?php

/*
        Program Name: PassEncryptedValue.php
        Date Written: June 1st, 2023
          Written By: Dave Jaynes
  Function Called By: CreateADACHTMLResponse() function
             Purpose: Passes the encrypted key to the DecryptKey.exe script
					  and captures the unencrypted value returned by DecryptKey.exe.
*/
include("ProdDBWebConnection.php");
$Count = '';
$EmpID = $_POST['EmpID'];
$EncryptedKey = $_POST['EncryptedKey'];
$DecryptScript = "C:/Apache24/cgi-bin/DecryptKey.exe";
$CreateEncryptedKey = "c:/Apache24/cgi-bin/Applications/CreateEncryptedKey.exe";
shell_exec("$CreateEncryptedKey");
$UnEncryptedKey = shell_exec("$DecryptScript $EncryptedKey");
$UnEncryptedKey = Trim($UnEncryptedKey);
echo "UnEncryptedKey = [$UnEncryptedKey]";

$CountNumRecords = "select count(*) from WebEncryptedKeys where EmpID = '$EmpID';";

$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
print "\n\nNumRecords = [$NumRecords]\n\n";
$sql="select * from WebEncryptedKeys where EmpID = '$EmpID';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$UnEncryptedKey = odbc_result($rs,"UnEncryptedKey");
	print "$UnEncryptedKey";
}
odbc_close($conn);
?>