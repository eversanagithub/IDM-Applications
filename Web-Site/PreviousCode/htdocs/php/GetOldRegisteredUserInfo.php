<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetOldRegisteredUserInfo.php                                                                |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: Retrieves data previously written by the GetNewRegisteredUserInfo.php script                |
|--------------------------------------------------------------------------------------------------------------- */

$BeginJSONHeader = '{ "OldUser" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$requesterName = $_POST['EmpEMail'];
// $requesterName = 'dave.jaynes@eversana.com';
$NewUserData = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/OldRegisteredUserInfo.txt";
$myfile = fopen($NewUserData, "r") or die("Unable to open file!");
echo fread($myfile,filesize($NewUserData));
fclose($myfile);
?>
