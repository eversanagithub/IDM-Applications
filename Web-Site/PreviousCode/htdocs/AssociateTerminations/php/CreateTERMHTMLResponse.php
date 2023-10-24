<?php

/*
        Program Name: CreateTERMHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
             Purpose: Creates the Associate Termination screen.
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
	$fh = fopen($FileOutput, "w");
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
	$txt = "<body onLoad='DisplayTermIntro();' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/AssociateTerminations/ListAssociates.pl' target='mainpanel'>\n";
	fwrite($fh,$txt);
	/*
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='AcctCreationTitle'>Welcome to the Associate Termination Application</p>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	*/
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<th width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='WhiteText_P15'>Employee ID</p>\n";
	fwrite($fh,$txt);
	$txt = "</th>\n";
	fwrite($fh,$txt);
	$txt = "</tr>";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<input id='assocID' name='assocID' type='text' onkeyup='UpdateSearchRecords();'>\n";
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
