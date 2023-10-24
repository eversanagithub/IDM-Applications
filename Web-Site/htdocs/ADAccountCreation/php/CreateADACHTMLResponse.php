<?php

/*
        Program Name: CreateADACHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
         Description: Creates the AD Account Creation screen.
*/

include("DBWebConnection.php");

$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];
$applicationName = $_POST['applicationName'];

// Pull application title
$sql="select * from WebAdminPortalApplicationURL where application = '$applicationName';";
$rs=odbc_exec($conn,$sql);
$application = odbc_result($rs,"appFormalName");

// Pull application location
$sql="select * from WebAdminPortalApplicationURL where application = '$applicationName';";
$rs=odbc_exec($conn,$sql);
$FileOutput = odbc_result($rs,"appLocation");
if (file_exists($FileOutput)) { unlink($FileOutput); }

function BuildSuccessPage($FileOutput)
{
	$fh = fopen($FileOutput, "a");
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

BuildSuccessPage($FileOutput);
?>
