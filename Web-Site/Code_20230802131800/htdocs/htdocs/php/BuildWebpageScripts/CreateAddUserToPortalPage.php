<?php


/*
        Program Name: CreateAddUserToPortalHTMLResponse.php
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
$AdminPortalOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/AddUserToPortalMenuOutput.txt";
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
	$txt = "<body onLoad='InitialRequesterDropDownList()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='AddUserToPortal' METHOD='POST' ACTION='/cgi-bin/SendClientWebsiteInvite.pl';>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<th align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='RegisterHeading'>Select an Associate From the Drop-Down Box You Wish to Register to the IDM Website</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<th width='%13' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Narrow Requesters Listing</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Select requester e-mail address</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Execute Request</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='13%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='requesterName' name='requesterName' type='text' placeholder='e.g. john.do' onkeyup='UpdateRequesterDropDownList(this);'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<select name='requesterNames' id='requesterNames'>\n";
	fwrite($fh,$txt);
	$txt = "<option value=";
	fwrite($fh,$txt);
	$txt = '""';
	fwrite($fh,$txt);
	$txt = "></option>\n";
	fwrite($fh,$txt);
	$txt = "</select>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='Submit' name='Submit' type='image' src='http://idmgmtapp01/images/buttons/submit.jpg' width=100 height=30 align='middle' border='0' onClick='PreRegisterNewUser();'>\n";
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
