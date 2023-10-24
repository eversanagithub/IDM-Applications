<?php


/*
        Program Name: CreateRestoreWebsiteDataPage.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateAddUserToPortalHTMLResponse.txt document which contains
					  the HTML code to display the Active Direct Account Creation page.
*/

include("DBWebConnection.php");

// $illegalAccess = $_POST['illegalAccess'];
$illegalAccess = "No";
$application = "Admin Portal Creation";
if($illegalAccess == 'No') { $AccessStatus = 1; }
if($illegalAccess == 'Yes') { $AccessStatus = 2; }

// Identify the file name used to load our data and make sure it does not exist.
$AdminPortalOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/RestoreWebsiteDataPage.txt";
if (file_exists($AdminPortalOutput)) { unlink($AdminPortalOutput); }

// Rebuild the Admin Portal screen since they have admin access.
function BuildSuccessPage($AdminPortalOutput)
{
	$fh = fopen($AdminPortalOutput, "a");
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
	$txt = "<body bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='RestoreWebsiteData' METHOD='POST' ACTION='/cgi-bin/BuildWebpageScripts/CreateRestoreWebsiteDataPage.pl';>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='50%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<img width=700 height=600 src='http://idmgmtapp01/images/RestoreWebsiteData_Left.jpg'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='50%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<div style='position:relative'>\n";
	fwrite($fh,$txt);
	$txt = "<img width=700 height=600 src='http://idmgmtapp01/images/RestoreWebsiteData_Right.jpg' usemap='#image-map'>\n";
	fwrite($fh,$txt);
	$txt = "<map name='image-map'>\n";
	fwrite($fh,$txt);
	$txt = "<area alt='http://idmgmtapp01/webpages/thispagecomingsoon.htm' title='Restore Website Data' href='http://idmgmtapp01/webpages/thispagecomingsoon.htm' coords='117,492,171,520' shape='rect'>\n";
	fwrite($fh,$txt);
	$txt = "<area alt='http://idmgmtapp01/webpages/WelcomeToAdminPortal.htm' title='Cancel Recovery Operation' href='http://idmgmtapp01/webpages/HousekeepingCover.htm' coords='117,554,171,583' shape='rect'>\n";
	fwrite($fh,$txt);
	$txt = "</map>\n";
	fwrite($fh,$txt);
	$txt = "</div>\n";
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
function BuildIllegalPage($AdminPortalOutput)
{
	$fh = fopen($AdminPortalOutput, "a");
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<html>\n";
	fwrite($fh,$txt);
	$txt = "<head>\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	fwrite($fh,$txt);
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<BODY class='bodyBackground'>\n";
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
		BuildSuccessPage($AdminPortalOutput);
		break;
	case 2:
		BuildIllegalPage($AdminPortalOutput);
		break;
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
