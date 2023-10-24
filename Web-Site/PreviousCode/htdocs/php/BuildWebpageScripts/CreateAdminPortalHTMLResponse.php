<?php


/*
        Program Name: CreateAdminPortalHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateADACHTMLResponse.txt document which contains
					  the HTML code to display the Admin Portal Menu Creation page.
*/

include("DBWebConnection.php");

$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];

// Identify the file name used to load our data and make sure it does not exist.
$AdminPortalOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/AdminPortalMenuOutput.txt";
if (file_exists($AdminPortalOutput)) { unlink($AdminPortalOutput); }

function BuildAdminPortalPage($AdminPortalOutput)
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
	$txt = "	<frameset cols='100%' name='topsidebar' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "		<frame src='http://idmgmtapp01/webpages/WebTitleBanner.htm' name='topright' scrolling=NO>\n";
	fwrite($fh,$txt);
	$txt = "	</frameset>\n";
	fwrite($fh,$txt);
	$txt = "	<frameset cols='15%,85%' name='topsidebar' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "		<frameset rows='43%,45%,12%' name='leftpanel' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "			<frame src='http://idmgmtapp01/webpages/topsidebar.html' name='leftpanel' scrolling=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "		<frame src='http://idmgmtapp01/webpages/ClickOnApplicationButton.htm' name='middleleftpanel' scrolling=NO>\n";
	fwrite($fh,$txt);
	$txt = "		<frame src='http://idmgmtapp01/webpages/DisplayEventLogs.html' name='bottomleftpanel' scrolling=NO>\n";
	fwrite($fh,$txt);
	$txt = "		</frameset>\n";
	fwrite($fh,$txt);
	$txt = "		<frameset rows='17%,83%' name='mainpage' frameborder=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "			<frame src='http://idmgmtapp01/webpages/AdminPortalWelcomeBanner.htm' name='topmainpanel' align=center scrolling=NO border='0'>\n";
	fwrite($fh,$txt);
	$txt = "			<frame src='http://idmgmtapp01/webpages/WelcomeToAdminPortal.htm' name='mainpanel' align=center scrolling=YES border='0'>\n";
	fwrite($fh,$txt);
	$txt = "		</frameset>\n";
	fwrite($fh,$txt);
	$txt = "	</frameset>\n";
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

BuildAdminPortalPage($AdminPortalOutput);

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
