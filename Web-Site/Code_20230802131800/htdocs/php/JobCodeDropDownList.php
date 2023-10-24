<?php

/*

        Program Name: JobCodeDropDownList.php
		Date Written: July 11th, 2023
		  Written By: Dave Jaynes
		     Purpose: Creates the Job Title drop-down list for the Active Directory Associate Creation application.
*/

// Gather connection details for the database.
include("DBWebConnection.php");

// Modify the $Cutoff value below to show the lowest number of current job
// positions in the drop-down box that are currently held within the company.
// Note: To show all the currently held job positions, use: $Cutoff = 0;
$Cutoff = 3;

// Declare local variables.
$BeginJSONHeader = '{ "JSON_JobCode" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($njobtitlecode,$longDescription,$jobFamilyCode,$countryCode,$jobEEOCategory)
{
	$SP = ' ';
	$HY = '-';
	$PositionName = $longDescription . $SP . $HY . $SP . $jobFamilyCode . $SP . $HY . $SP . $jobEEOCategory;
    $output = '';
    $output = '{ "'
    . "jobCode"
    . '":"'
    . $njobtitlecode
	. '", '
    . '"'
    . "PositionName"
    . '":"'
    . $PositionName
    . '"'
    . " }";
    return $output;
}

// Get record count for JSON string formatting reasons.
$NumRecords = 0;
$sql="select h.njobtitlecode, count(h.njobtitlecode) as number, j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory from hr_trx h inner join HR_JobCodes j on h.NJobTitleCode = j.jobCode where h.reason in ('hir','ter') and h.in_tbl_date > '20230101' and j.isActive = 'true' group by h.njobtitlecode,j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory order by j.longDescription asc;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$number = odbc_result($rs,"number");
	if($number > $Cutoff) { $NumRecords++; }
}

$sql="select h.njobtitlecode, count(h.njobtitlecode) as number, j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory from hr_trx h inner join HR_JobCodes j on h.NJobTitleCode = j.jobCode where h.reason in ('hir','ter') and h.in_tbl_date > '20230101' and j.isActive = 'true' group by h.njobtitlecode,j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory order by j.longDescription asc;";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$njobtitlecode = odbc_result($rs,"njobtitlecode");
	$number = odbc_result($rs,"number");
	$longDescription = odbc_result($rs,"longDescription");
	$jobFamilyCode = odbc_result($rs,"jobFamilyCode");
	$countryCode = odbc_result($rs,"countryCode");
	$jobEEOCategory = odbc_result($rs,"jobEEOCategory");
	if($number > $Cutoff) 
	{
		$thisRow = get_item_html($njobtitlecode,$longDescription,$jobFamilyCode,$countryCode,$jobEEOCategory);
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
}

$JSONData = $BeginJSONHeader . $RunningJsonQuery . $EndingJSONHeader;
print "$JSONData";
odbc_close($conn);
?>
