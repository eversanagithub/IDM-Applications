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
$EncryptedKey = "e34re";
*/

$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];

$TimeCheckPassed = "Yes";  // Need a PowerShell script to check time difference.
$application = "Admin Portal Creation";

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

$TestingFile = "C:/apache24/htdocs/php/BuildWebpageScripts/TestingFile.txt";
if (file_exists($TestingFile)) { unlink($TestingFile); }
$fh = fopen($TestingFile, "a");
$txt = "EmpID = [$EmpID]\n";
fwrite($fh,$txt);
$txt = "TimeCheckPassed = [$TimeCheckPassed]\n";
fwrite($fh,$txt);
$txt = "EncryptedKey = [$EncryptedKey]\n";
fwrite($fh,$txt);
$txt = "Authorized = [$Authorized]\n";
fwrite($fh,$txt);
fclose($fh);

// Identify the file name used to load our data and make sure it does not exist.
$AdminPortalOutput = "C:/apache24/htdocs/php/BuildWebpageScripts/AdminPortalMenuOutput.txt";
if (file_exists($AdminPortalOutput)) { unlink($AdminPortalOutput); }

// Rebuild the Admin Portal screen since they have admin access.
function BuildAuthorizedUser($AdminPortalOutput)
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
function BuildInvalidCredentials($AdminPortalOutput,$AccessStatus)
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
	$txt = "<td align='center'>\n";
	fwrite($fh,$txt);
	switch($AccessStatus)
	{
		case 2:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/SessionCredentialsBad.jpg'>\n";
			break;
		case 3:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/SessionTimesOut.jpg'>\n";
			break;
		case 4:
			$txt = "<img width=800 height=800 src='http://idmgmtapp01/images/AdminPortalNotAuthorized.jpg'>\n";
			break;
	}
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

if($AccessStatus == 1)
{
	BuildAuthorizedUser($AdminPortalOutput);
}
else
{
	BuildInvalidCredentials($AdminPortalOutput,$AccessStatus);
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>