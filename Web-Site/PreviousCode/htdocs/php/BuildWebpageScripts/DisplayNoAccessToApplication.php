<?php


/*
        Program Name: DisplayNoAccessToApplication.php
        Date Written: October 14th, 2023
          Written By: Dave Jaynes
         Description: Creates the display show user they do not have access to selected application.
*/

include("DBWebConnection.php");

$application = $_POST['application'];
$applicationPath = $_POST['applicationPath'];
$errorCode = $_POST['errorCode'];

if (file_exists($applicationPath)) { unlink($applicationPath); }

// This function will be called if the 'IDActive' = '1' and the user is good to go.
function BuildSuccessPage($applicationPath)
{
	$fh = fopen($applicationPath, "a");
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
	$txt = "<body onLoad='DisplayADACIntro();InitialJobCodeDropDownList()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/ADAccountCreation/ADAccountCreation.pl' target='mainpanel'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<th width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>First Name</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Last Name</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='%21' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Enter Job Title Search Text</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='%24' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Job Description (Title ; Job Family Code ; Location ; Job ID)</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Manager</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "<th width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Click below to submit entry</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "</tr>";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='firstName' name='firstName' type='text' placeholder='e.g. John'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='lastName' name='lastName' type='text' placeholder='e.g. Doe'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	
	$txt = "<td width='21%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input id='longDescriptionSrchStr' name='longDescriptionSrchStr' type='text' placeholder='e.g. Program Specialist' onkeyup='JobCodeDropDownList(this);'>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	
	
	$txt = "<td width='24%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<select name='jobDescription' id='jobDescription'>\n";
	fwrite($fh,$txt);
	$txt = "				<option value=";
	fwrite($fh,$txt);
	$txt = '""';
	fwrite($fh,$txt);
	$txt = "></option>\n";
	fwrite($fh,$txt);
	$txt = "			</select>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);

	$txt = "<td width='15%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='manager' name='manager' type='text' placeholder='e.g. Jane Doe'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<button class='styledButton' id='Submit' name='Submit' value='Submit' type='submit'>Submit</button>\n";
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

function BuildIllegalPage($applicationPath)
{
	$fh = fopen($applicationPath, "a");
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<html>\n";
	fwrite($fh,$txt);
	$txt = "<head>\n";
	fwrite($fh,$txt);
	$txt = "<meta HTTP-EQUIV='REFRESH' CONTENT=";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = "6; URL=javascript:window.open('http://idmgmtapp01/index.html','_parent);";
	fwrite($fh,$txt);
	$txt = '" />';
	fwrite($fh,$txt);
	$txt = "\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	fwrite($fh,$txt);
	$txt = "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	fwrite($fh,$txt);
	$txt = "</head>";
	fwrite($fh,$txt);
	$txt = "<body onLoad='ShowIllegalAccessScreen()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='AdminPortalHeading'>Please do not attempt to bypass the proper login procedures for this web site.</p>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "	</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</form>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}

function BuildFailedPage($applicationPath)
{
	$fh = fopen($applicationPath, "a");
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
	$txt = "<body  onLoad='ShowTimeOutScreen()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/OneDriveDelegation/GrantOneDriveFolderAccess.pl' target='mainpanel'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='AdminPortalHeading'>Sorry, your Admin Portal session has timed out after 60 minutes of inactivity.</p>\n";	
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "	</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}

function BuildRestrictedPage($applicationPath)
{
	$fh = fopen($applicationPath, "a");
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
	$txt = "<center>\n";
	fwrite($fh,$txt);
	$txt = "<BODY onLoad='ShowNotAuthorizedMsg()' class='bodyBackground'>\n";
	fwrite($fh,$txt);
		$txt = "<img width=1520 height=52 src='http://idmgmtapp01/images/WelcomeToTheIdentityAccessHeader.jpg'>\n";
	fwrite($fh,$txt);
	$txt = "</center>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
	fclose($fh);
}

switch($errorCode)
{
	case 1:
		BuildSuccessPage($applicationPath);
		break;
	case 2:
		BuildIllegalPage($applicationPath);
		break;
	case 3:
		BuildFailedPage($applicationPath);
		break;
	case 31:
		BuildRestrictedPage($applicationPath);
		break;
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
