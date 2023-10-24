<?php


/*
        Program Name: AdminPortalErrorScreen.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the exception display when a user does not have 
					  authenticated rights to see the Admin Portal display.
*/

include("DBWebConnection.php");

$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];
$ErrorCode = $_POST['GetReturnValue'];

// We use the same output file as we would to display the proper Admin Portal screen since that is what we post to.
$AdminPortalOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/AdminPortalMenuOutput.txt";
if (file_exists($AdminPortalOutput)) { unlink($AdminPortalOutput); }

// Rebuild the initial screen if they don't have access. Put them back to the beginning page.
function BuildWarningScreen($AdminPortalOutput,$ErrorCode)
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
	$txt = "45; url='http://idmgmtapp01/index.html'";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);	
	$txt = " />\n";
	fwrite($fh,$txt);
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<BODY class='bodyBackground'>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<table border=0 style='width:100%'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td align='center'>\n";
	fwrite($fh,$txt);
	switch($ErrorCode)
	{
		case 0:
			$txt = "<div style='position:relative'>";
			fwrite($fh,$txt);
			$txt = "<img width=1200 height=800 src='http://idmgmtapp01/images/AdminPortalErrorImages/NotRegisteredOrMissingCookies.jpg'  usemap='#image-map'>\n";
			fwrite($fh,$txt);
			$txt = "<map name='image-map'>";
			fwrite($fh,$txt);
			$txt = "<area target='_parent' alt='http://idmgmtapp01/ClientHelp.html' title='Client Help' href='http://idmgmtapp01/ClientHelp.html' coords='518,645,580,680' shape='rect'>";
			fwrite($fh,$txt);
			$txt = "</map>";
			fwrite($fh,$txt);
			$txt = "</div>";
			fwrite($fh,$txt);
			break;
		case 1:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/SessionTimesOut.jpg'>\n";
			break;
		case 2:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
		case 3:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
		case 5:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
		case 7:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
		case 9:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
		case 15:
			$txt = "<div style='position:relative'>";
			fwrite($fh,$txt);
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/AdminPortalErrorImages/FixRegistrationOnThisDevice.jpg'>\n";
			fwrite($fh,$txt);
			$txt = "<map name='image-map'>";
			fwrite($fh,$txt);
			$txt = "<area target='_parent' alt='http://idmgmtapp01/ClientHelp.html' title='Client Help' href='http://idmgmtapp01/ClientHelp.html' coords='1030,490,1120,540' shape='rect'>";
			fwrite($fh,$txt);
			$txt = "</map>";
			fwrite($fh,$txt);
			$txt = "</div>";
			fwrite($fh,$txt);			
			break;
	}
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	
	$txt = "<table border=0 style='width:100%'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='55%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='45%' align='left'>\n";
	fwrite($fh,$txt);
	$txt = "<a href='http://idmgmtapp01/index.html'><img src='http://idmgmtapp01/images/buttons/backtomainpage.jpg' style='width:140px;height:40px;'></a>\n";
	fwrite($fh,$txt);
	$txt = "</td></tr></table>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}


BuildWarningScreen($AdminPortalOutput,$ErrorCode);

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
