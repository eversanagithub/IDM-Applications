<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetNewRegisteredUserInfo.php                                                                |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves specific record from the WebNewUsers SQL table.                                   |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "NewUser" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$requesterName = $_POST['EmpEMail'];
// $requesterName = 'dave.jaynes@eversana.com';





// Format each row of SQL returns into JSON formatted text.
function get_item_html($EmpID,$PrefFName,$PrefLName,$GivenName,$SurName)
{
    $output = '';
    $output = '{ "'
    . "EmpID"
    . '":"'
    . $EmpID
    . '",'
		. '"'
    . "PrefFName"
    . '":"'
    . $PrefFName
		. '",'	
		. '"'
    . "PrefLName"
    . '":"'
    . $PrefLName
		. '",'	
		. '"'
    . "GivenName"
    . '":"'
    . $GivenName
		. '",'	
		. '"'
    . "SurName"
    . '":"'
    . $SurName
		. '"'	
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from Profile where Email = '$requesterName';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from Profile where Email = '$requesterName';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$EmpID = odbc_result($rs,"EMPLID");
	$PrefFName = odbc_result($rs,"PrefFName");
	$PrefLName = odbc_result($rs,"PrefLName");
	$GivenName = odbc_result($rs,"GIVENNAME");
	$SurName = odbc_result($rs,"SURNAME");
	$thisRow = get_item_html($EmpID,$PrefFName,$PrefLName,$GivenName,$SurName);
	$Counter++;
	if($Counter < $NumRecords)
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow . ', ';
	}
	else
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow;
	}
}

$JSONData = $BeginJSONHeader . $RunningJsonQuery . $EndingJSONHeader;
print "$JSONData";
$RegisterOldUserData = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/OldRegisteredUserInfo.txt";
if (file_exists($RegisterOldUserData)) { unlink($RegisterOldUserData); }
$OldUserData = fopen($RegisterOldUserData, "a");
$txt = "$JSONData";
fwrite($OldUserData,$txt);
fclose($OldUserData);
odbc_close($conn);
?>
