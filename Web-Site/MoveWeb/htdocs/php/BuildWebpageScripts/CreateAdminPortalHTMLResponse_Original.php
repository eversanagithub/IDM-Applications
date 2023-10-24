<?php


/*
        Program Name: CreateAdminPortalHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateADACHTMLResponse.txt document which contains
					  the HTML code to display the Active Direct Account Creation page.
*/

include("ProdDBWebConnection.php");

$illegalAccess = $_POST['illegalAccess'];
// $illegalAccess = "No";

$application = "Admin Portal Creation";

$AccessStatus = 1;
if($illegalAccess == 'Yes') { $AccessStatus = 2; }

// Identify the file name used to load our data and make sure it does not exist.
$AdminPortalOutput = "C:/apache24/htdocs/php/BuildWebpageScripts/AdminPortalMenuOutput.txt";
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
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<frameset rows='12%,88%' name='top'  border='0' framespacing='1' frameborder=NO>\n";
	fwrite($fh,$txt);
	$txt = "<frameset cols='100%' name='topsidebar' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<frame src='http://idmgmtapp01/webpages/IDM_Large_Logo2.htm' name='topright' scrolling=NO>\n";
	fwrite($fh,$txt);
	$txt = "</frameset>\n";
	fwrite($fh,$txt);
	$txt = "<frameset cols='15%,85%' name='topsidebar' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<frameset rows='100%' name='leftpanel' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<frame src='http://idmgmtapp01/webpages/topsidebar.html' name='leftpanel' scrolling=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "</frameset>\n";
	fwrite($fh,$txt);
	$txt = "<frameset rows='17%,83%' name='mainpage' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<frame src='http://idmgmtapp01/webpages/AdminPortalWelcomeBanner.htm' name='topmainpanel' align=center scrolling=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<frame src='http://idmgmtapp01/webpages/WelcomeToAdminPortal.htm' name='mainpanel' align=center scrolling=YES border='0'>\n";
	fwrite($fh,$txt);
	$txt = "</frameset>\n";
	fwrite($fh,$txt);
	$txt = "</frameset>\n";
	fwrite($fh,$txt);
	$txt = "</frameset>\n";
	fwrite($fh,$txt);
	$txt = "<body>\n";
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
	$txt = "<meta http-equiv='refresh' content=";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = "10; url='http://idmgmtapp01/index.html'";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);	
	$txt = " />\n";
	fwrite($fh,$txt);
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<BODY class='bodyBackground'>\n";
	fwrite($fh,$txt);
	$txt = "<table border=0 style='width:100%'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td>\n";
	fwrite($fh,$txt);
	$txt = "<img width=1400 height=860 src='http://idmgmtapp01/images/NoAdminPortalAccess.jpg'>\n";
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