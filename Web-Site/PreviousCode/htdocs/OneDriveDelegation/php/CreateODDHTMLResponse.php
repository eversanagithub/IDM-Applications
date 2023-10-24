<?php

/*
        Program Name: CreateODDHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
             Purpose: Creates the One-Drive Delegation screen.
*/

include("DBWebConnection.php");

# Assign posting to variables.
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

function BuildSuccessPage($FileOutput,$EmpID,$application)
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
	$txt = "</head>";
	fwrite($fh,$txt);
	$txt = "<body onLoad='DisplayODDIntro();InitialFormerAssociateDropDownList();InitialRequesterDropDownList()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/OneDriveDelegation/MonitorODDJobRun.pl' target='mainpanel'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='100%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "<p class='AcctCreationTitle'>Welcome to the One Drive Delegation Application</p>\n";
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
	$txt = "	<tr>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='13%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Narrow Associate Listing</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Select former Associate e-mail address</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='%13' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Narrow Requester Listing</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Select requester e-mail address</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='12%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Requesting Incident Number</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15'>Execute Request</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "	</tr>\n";
	fwrite($fh,$txt);
	$txt = "	<tr>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='13%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input id='assocName' name='assocName' type='text' placeholder='e.g. john.do' onkeyup='UpdateFormerAssociateDropDownList(this);'>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<select name='associateNames' id='associateNames'>\n";
	fwrite($fh,$txt);
	$txt = "				<option value=";
	fwrite($fh,$txt);
	$txt = '""';
	fwrite($fh,$txt);
	$txt = "></option>\n";
	fwrite($fh,$txt);
	$txt = "			</select>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='13%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input id='requesterName' name='requesterName' type='text' placeholder='e.g. john.do' onkeyup='UpdateRequesterDropDownList(this);'>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='18%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<select name='requesterNames' id='requesterNames'>\n";
	fwrite($fh,$txt);
	$txt = "				<option value=";
	fwrite($fh,$txt);
	$txt = '""';
	fwrite($fh,$txt);
	$txt = "></option>\n";
	fwrite($fh,$txt);
	$txt = "			</select>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='12%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input id='incidentNumber' name='incidentNumber' type='text' placeholder='Leave empty if no incident'>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<input id='userID' name='userID' type='hidden' value=";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = "$EmpID";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = ">\n";
	fwrite($fh,$txt);
	$txt = "		<input id='application' name='application' type='hidden' value=";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = "$application";
	fwrite($fh,$txt);
	$txt = '"';
	fwrite($fh,$txt);
	$txt = ">\n";
	fwrite($fh,$txt);
	$txt = "		<td width='10%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<button class='styledButton' id='Submit' name='Submit' value='Submit' onClick='SubmitODDRequest()'>Submit</button>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "	</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<table border='0' width=100%>\n";
	fwrite($fh,$txt);
	$txt = "	<tr>\n";
	fwrite($fh,$txt);
	$txt = "";
	fwrite($fh,$txt);
	$txt = "		<canvas id='myCanvas' width='1600' height='0' style='border:2px solid #DFAB17;'>\n";
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

BuildSuccessPage($FileOutput,$EmpID,$application)
?>
