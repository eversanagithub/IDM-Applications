<?php


/*
        Program Name: CreateADACHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateADACHTMLResponse.txt document which contains
					  the HTML code to display the Active Direct Account Creation page.
*/

include("ProdDBWebConnection.php");

/*
	First let's make sure the user has the appropriate access.
	The following requirements will be checks:
	
	1. Does the user have a EmpID key cookie value on their laptop?
	2. Does the user's encrypted key cookie value on their laptop match the value 
	   of the cooresponding 'EncryptedKey' field in the 'WebEncryptedKeys' table?
	3. Is the 'ValidTimeStamp' variable set to 'Yes'?
	
	All three of the conditions need to true before we give them access to the
	Admin Portal menu.
*/

/*
	We are going to give this user the benifit of the doubt that their access
	is good by setting the $AccessStatus variable equal to 1 which means they pass the
	verification check. If they fail any of the verification checks (non-matching
	Encryption keys, User Cookie not valid, TimeCheckPassed equal to 'No' ... etc),
	then we set $AccessStatis equal to '2' and they get the 'Not Authorized' message.
*/

$AccessStatus = 1;

/*
$EmpID = "103257";
$EncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000a3ac1dc8af9879489ec822503f8363d60000000002000000000003660000c000000010000000014a67d4dc37d13953e568545133d21c0000000004800000a00000001000000094fe515535c8cfac17198cd81f16638318000000479741b0465f3d76d695efb31dfa9e1d117e61d02704a0021400000010dac33aff0fc6a848a4abb1972de41c98e655db";
*/

$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];

$TimeCheckPassed = "Yes";  // Need a PowerShell script to check time difference.
$application = "Terminated Associate";

/*
	Remember the 'SendAdminPortalParameters' JavaScript fuction?
	It was the function that called this PHP script via an AJAX method call.
	
	In that function we talked about the four parameters which need to be checked
	to make sure the user is eligable to view the Admin Portal page. They are:
	
		1. Do they have a valid employee ID number stored in the user's 'emplid' cookie?
		2. Does the encrypted key value stored in the user's EncryptedKey cookie match 
		   what is stored in the WebEncryptedKeys SQL table?
		3. Is the DTG stamp (webUserDTG) in the right format (i.e., is it of string 
		   type and 14 characters in length?).
		4. Has more than 60 minutes passed since the last DTG stamp in the 'webUserDTG' 
		   internal storage variable?
		5. Is the user authorized to use the web page (Has their access been restricted 
		   by the admin of the site)?
		   
	We will now check those five conditions below.
*/

// Check to make sure the user has a valid Employee ID Cookie on their laptop.
if($EmpID == '' || $EmpID == null)
{
	$AccessStatus = 2;
}

// Get's get the Encrypted key from the WebEncryptedKeys SQL table for this user.
// If the Stored Encrypted key from the SQL does not match the passed encrypted key,
// we will set $AccessStatus to equal 2.
$sql="select EncryptedKey from WebEncryptedKeys where EmpID = '$EmpID';";
$rs=odbc_exec($conn,$sql);
$StoredEncryptedKey = odbc_result($rs,"EncryptedKey");
if($StoredEncryptedKey != $EncryptedKey)
{
	$AccessStatus = 2;
}

// Make sure the session did not timeout due to inactivity.
if($TimeCheckPassed == "No")
{
	$AccessStatus = 3;
}

// Has the user's access been restricted by the admin?
$sql="select Authorized from WebNewUsers where EmpID = '$EmpID';";
$rs=odbc_exec($conn,$sql);
$Authorized = odbc_result($rs,"Authorized");
if($Authorized == 'No')
{
	$AccessStatus = 4;
}

$TestingFile = "C:/apache24/htdocs/php/BuildWebpageScripts/TermedAssociateTestingFile.txt";
if (file_exists($TestingFile)) { unlink($TestingFile); }
$fh = fopen($TestingFile, "w");
$txt = "EmpID = [$EmpID]\n";
fwrite($fh,$txt);
$txt = "TimeCheckPassed = [$TimeCheckPassed]\n";
fwrite($fh,$txt);
$txt = "EncryptedKey = [$EncryptedKey]\n";
fwrite($fh,$txt);
$txt = "Authorized = [$Authorized]\n";
fwrite($fh,$txt);
$txt = "AccessStatus = [$AccessStatus]\n";
fwrite($fh,$txt);
fclose($fh);

// Identify the file name used to load our data and make sure it does not exist.
$TERMOutput = "C:/apache24/htdocs/php/TERMMenuOutput.txt";
if (file_exists($TERMOutput)) { unlink($TERMOutput); }

// This function will be called if the 'IDActive' = '1' and the user is good to go.
function BuildSuccessPage($TERMOutput)
{
	$fh = fopen($TERMOutput, "w");
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

function BuildIllegalPage($TERMOutput)
{
	$fh = fopen($TERMOutput, "a");
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

function BuildFailedPage($TERMOutput)
{
	$fh = fopen($ODDOutput, "a");
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

switch($AccessStatus)
{
	case 1:
		BuildSuccessPage($TERMOutput);
		break;
	case 2:
		BuildIllegalPage($TERMOutput);
		break;
	case 3:
		BuildFailedPage($TERMOutput);
		break;
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>