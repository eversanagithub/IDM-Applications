<?php


/*
        Program Name: CreatePromotePage.php
        Date Written: July 17th, 2023
          Written By: Dave Jaynes
             Purpose: Creates the Promote webpage screen when the Promote button is clicked.
*/

include("DBWebConnection.php");

$illegalAccess = $_POST['illegalAccess'];
// $illegalAccess = "No";
$application = "Admin Portal Creation";
if($illegalAccess == 'No') { $AccessStatus = 1; }
if($illegalAccess == 'Yes') { $AccessStatus = 2; }

// Identify the file name used to load our data and make sure it does not exist.
$PromoteWebsiteOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/PromoteScriptOutput.txt";
if (file_exists($PromoteWebsiteOutput)) { unlink($PromoteWebsiteOutput); }

// Rebuild the Admin Portal screen since they have admin access.
function BuildSuccessPage($PromoteWebsiteOutput)
{
	$fh = fopen($PromoteWebsiteOutput, "a");
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<html>\n";
	fwrite($fh,$txt);
	$txt = "<head>\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	fwrite($fh,$txt);
	$txt = "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	fwrite($fh,$txt);
	$txt = "</head>";
	fwrite($fh,$txt);
	// $txt = "<body onLoad='KickoffPromotion();MonitorPromotionProgress()' bgcolor='#0F0141'>\n";
	$txt = "<body bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='PortalForm' METHOD='POST' ACTION='/cgi-bin/ExecutePromotionProcess.pl';>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='IDMReportHeading'>IDM Website Code Promotion Utility</p></td>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td>\n";
	fwrite($fh,$txt);
	$txt = "<p class='IDMReportDetail'>This application promotes the HTML code within the Development environment into Production.</p></td>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);	
	$txt = "<tr>\n";
	fwrite($fh,$txt);	
	$txt = "<td width='100%'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='MainHeader'>Click the Commence Promotion button to initiate the promotion process</p>\n";
	fwrite($fh,$txt);	
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);	
	$txt = "</table>\n";
	fwrite($fh,$txt);	
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='NoticeBlueUnderline'>Start Time</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='NoticeBlueUnderline'>Completion Time</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='NoticeBlueUnderline'>Completion %</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='21%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='NoticeBlueUnderline'>Status Message</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='13%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P18'>Pending</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P18'>Pending</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	
	$txt = "<td width='17%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P18'>0.0</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	
	$txt = "<td width='21%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P18'>Awaiting Command to start</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);

	$txt = "<td width='13%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br><br><br><br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<button class='styledButton' id='Submit' name='Submit' type='submit' value='Submit'>Commence Promotion</button>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br><br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<img width=800 height=300 src='http://idmgmtapp01/images/PromoteCartoon3.jpg'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}

// Rebuild the initial screen if they don't have access. Put them back to the beginning page.
function BuildIllegalPage($PromoteWebsiteOutput)
{
	$fh = fopen($PromoteWebsiteOutput, "a");
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<html>\n";
	fwrite($fh,$txt);
	$txt = "<head>\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	fwrite($fh,$txt);
	$txt = "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	fwrite($fh,$txt);
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<BODY onLoad='PromotionNotAllowed()' class='bodyBackground'>\n";
	fwrite($fh,$txt);
	$txt = "<table border=0 style='width:100%'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<img width=1600 height=100 src='http://idmgmtapp01/images/NoAdminPrivileges.jpg'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}

switch($AccessStatus)
{
	case 1:
		BuildSuccessPage($PromoteWebsiteOutput);
		break;
	case 2:
		BuildIllegalPage($PromoteWebsiteOutput);
		break;
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
