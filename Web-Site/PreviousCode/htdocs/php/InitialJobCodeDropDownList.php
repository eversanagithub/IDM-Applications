<?php

/*
----------------------------------------------------------------------------------------------------------------
|    Program Name: InitialJobCodeDropDownList.php                                                              |
|    Date Written: September 11th, 2023                                                                        |
|      Written By: Dave Jaynes                                                                                 |
|       Called By: Displays the initial job code drop down list.                                               |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$BeginJSONHeader = '{ "JSON_JobCode" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($jobCode,$countryCode,$jobFamilyCode,$longDescription)
{
    $output = '';
    $output = '{ "'
    . "longDescription"
    . '":"'
    . $longDescription . ';' . $jobFamilyCode . ';' . $countryCode . ';' . $jobCode
		. '"'	
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from HR_Jobcodes where isActive = 'true';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);


$sql="select jobCode,countryCode,jobFamilyCode,longDescription from HR_Jobcodes where isActive = 'true' order by longDescription;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$jobCode = odbc_result($rs,"jobCode");
	$countryCode = odbc_result($rs,"countryCode");
	$jobFamilyCode = odbc_result($rs,"jobFamilyCode");
	$longDescription = odbc_result($rs,"longDescription");
	$thisRow = get_item_html($jobCode,$countryCode,$jobFamilyCode,$longDescription);
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
$RegisterOldUserData = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/JobCodeInfo.txt";
if (file_exists($RegisterOldUserData)) { unlink($RegisterOldUserData); }
$OldUserData = fopen($RegisterOldUserData, "a");
$txt = "$JSONData";
fwrite($OldUserData,$txt);
fclose($OldUserData);
odbc_close($conn);
?>
