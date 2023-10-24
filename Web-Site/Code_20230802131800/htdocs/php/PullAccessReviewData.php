<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: PullAccessReviewData.php                                                                    |
!    Date Written: July 9th, 2023                                                                              |
|      Written By: Dave Jaynes                                                                                 |
|         Purpose: Creates the Access Review context string required by the AnyChart program.                  |
|--------------------------------------------------------------------------------------------------------------- */

include("DBAccessReview.php");
$Count = '';
$FormatString = '{"header" : ["Name", "Percentage"],"rows" : [';

function FormDataString($NumRecords,$Counter,$Name,$Percentage)
{
	$output = '';
	if($Counter < $NumRecords)
	{
		$output = '["' . $Name . '", ' . $Percentage . '],';
	}
	else
	{
		$output = '["' . $Name . '", ' . $Percentage . ']';
	}		
    return $output;
}
	
// Get record count
$CountNumRecords = "select count(*) from WebARData;";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebARData;";
$rs=odbc_exec($conn,$sql);
if (!$rs) {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$Counter++;
	$Name = odbc_result($rs,"name");
	$Percentage = odbc_result($rs,"percentage");
	$FormatLine = FormDataString($NumRecords,$Counter,$Name,$Percentage);
	$FormatString = $FormatString . $FormatLine;
}
$FormatString = $FormatString . ']}';
print "$FormatString";

odbc_close($conn);
?>
