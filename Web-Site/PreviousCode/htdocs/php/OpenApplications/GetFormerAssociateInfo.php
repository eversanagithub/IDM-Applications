<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetFormerAssociateInfo.php                                                                |
|    Date Written: July 17th, 2023                                                                             |
|      Written By: Dave Jaynes                                                                                 |
|         Purpose: Retrieves fields from the Web Code promotion process.                                       |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "JSON_FormerAssociateInfo" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';

$requesterName = $_POST['requesterName'];
//$requesterName = "angel.mackey@eversana.com";

function MakeNiceTermDate($TermDate)
{
	if($TermDate == "")
	{
		$TermDate = "Empty";
	}
	else
	{
		$dateTimeArray = explode(" ", $TermDate);
		$justDate = $dateTimeArray[0];
		$ymdArray = explode("-", $justDate);
		$year = $ymdArray[0];
		$mon = $ymdArray[1];
		$day = $ymdArray[2];
		$intDay = (int)$day;
		
		switch($mon)
		{
			case "01":
				$month = "January";
				break;
			case "02":
				$month = "February";
				break;
			case "03":
				$month = "March";
				break;
			case "04":
				$month = "April";
				break;
			case "05":
				$month = "May";
				break;
			case "06":
				$month = "June";
				break;
			case "07":
				$month = "July";
				break;
			case "08":
				$month = "August";
				break;
			case "09":
				$month = "September";
				break;
			case "10":
				$month = "October";
				break;
			case "11":
				$month = "November";
				break;
			case "12":
				$month = "December";
				break;
		}
		$niceTermDate = $month . " " . $intDay . ", " . $year;
	}
	return $niceTermDate;
}

function MakeNiceDisableDate($DisableDate)
{
	$niceDisableDate = "";
	if($DisableDate == "")
	{
		$niceDisableDate = "Empty";
	}
	else
	{
		$dateTimeArray = explode(" ", $DisableDate);
		$justDate = $dateTimeArray[0];
		$justTime = $dateTimeArray[1];
		
		# Make the nice date
		$ymdArray = explode("-", $justDate);
		$year = $ymdArray[0];
		$mon = $ymdArray[1];
		$day = $ymdArray[2];
		$intDay = (int)$day;
		
		switch($mon)
		{
			case "01":
				$month = "January";
				break;
			case "02":
				$month = "February";
				break;
			case "03":
				$month = "March";
				break;
			case "04":
				$month = "April";
				break;
			case "05":
				$month = "May";
				break;
			case "06":
				$month = "June";
				break;
			case "07":
				$month = "July";
				break;
			case "08":
				$month = "August";
				break;
			case "09":
				$month = "September";
				break;
			case "10":
				$month = "October";
				break;
			case "11":
				$month = "November";
				break;
			case "12":
				$month = "December";
				break;
		}
		
		# Make the nice disable Date/Time
		$hmsmArray = explode(".", $justTime);
		$hms = $hmsmArray[0];
		$hmsArray = explode(":", $hms);
		$hour = $hmsArray[0];
		$minute = $hmsArray[1];
		if($hour > 11) { $apm = "PM"; } else { $apm = "AM"; }
		$intHour = (int)$hour;
		if($intHour > 12) { $intHour = $intHour - 12; }
		if($intHour == 0) { $intHour = 12; }
		$niceDisableDate = $month . " " . $intDay . ", " . $year . " " . $intHour . ":" . $minute . " " . $apm . " CT";
	}
	return $niceDisableDate;
}

// Format each row of SQL returns into JSON formatted text.
function get_item_html($AssociateID,$BusinessUnit,$HRLegalName,$TermDate,$DisableDate,$ReportedTo)
{
    $output = '';
    $output = '{ "'
    . "AssociateID"
    . '":"'
    . $AssociateID
    . '", '
    . '"'
    . "BusinessUnit"
    . '":"'
    . $BusinessUnit
    . '", '
    . '"'
    . "HRLegalName"
    . '":"'
    . $HRLegalName
    . '", '
    . '"'
    . "TermDate"
    . '":"'
    . $TermDate
    . '", '
    . '"'
    . "DisableDate"
    . '":"'
    . $DisableDate
    . '", '
    . '"'
    . "ReportedTo"
    . '":"'
    . $ReportedTo
    . '"'
    . " }";
    return $output;
}

// Pull the employee number for posted email address.
$PullAssociateID = "select u.AssociateID from Ultipro_ADRpt u left join profile p on (u.AssociateID = p.EMPLID) where p.Email = '$requesterName';";
$rs = odbc_exec($conn,$PullAssociateID);
odbc_fetch_row($rs);
$AssociateID = odbc_result($rs,'AssociateID');
$NumRecords = 1;

$sql="exec ComplianceNotifications_TerminationInfo_AssociateCheck '$AssociateID';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$AssociateID = odbc_result($rs,"AssociateID");
	$BusinessUnit = odbc_result($rs,"BusinessUnit");
	$HRLegalName = odbc_result($rs,"HR Legal Name");
	$TermDate = odbc_result($rs,"Time HR Set For Termination Date");
	$DisableDate = odbc_result($rs,"IDM Recognized ADUniversal Disable");
	$ReportedTo = odbc_result($rs,"ReportsToName");
	$NiceTermDate = MakeNiceTermDate($TermDate);
	$NiceDisableDate = MakeNiceDisableDate($DisableDate);
	$thisRow = get_item_html($AssociateID,$BusinessUnit,$HRLegalName,$NiceTermDate,$NiceDisableDate,$ReportedTo);
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
odbc_close($conn);
?>
