<?php


/*
        Program Name: CreateODDHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Evaluates the current state of the user's attributes who clicked on
					  the 'OD Delegation' button within the Admin portal.
					  If the 'IDActive' variable equals '1', the user's request is approved
					  and the One-Drive Delegation HTML page will be created.
					  If 'IDActive' = '0', they must have tried to by-pass the normal
					  process by going directly to the admin_portal.html page ... not happening!
					  The 'Access Denied' page will be created instead.
					  
					  So either way, the 'C:/apache24/htdocs/Applications/php/ODDMenuOutput.txt'
					  file will be generated by this script and will contain either the actual
					  One-Drive Delegation code if 'IDActive' = '1' (meaning the user is logged in)
					  or it will contain the HTML code saying access denied. 
					  
					  One other note. The 'ODD_Search_Settings.pl' script is executed from
					  the FORM statement within the 'topsidebar.html' script. It is this
					  'ODD_Search_Settings.pl' script that will display the ODDMenuOutput.txt
					  file to the screen after clicking on the 'OD Delegation' button and will
					  use the 'DisplayODDHTMLResponse.php' php script to print this file.
					  
					  Whew! A lot of stuff happens just to verify the user has rights to access an App!
*/

include("DBWebConnection.php");

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


//$EmpID = "103257";
//$EncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000a3ac1dc8af9879489ec822503f8363d60000000002000000000003660000c000000010000000b2e010fff14c2efac48315e31a7affe60000000004800000a000000010000000ec17d705d007df3a733983660b1065cc18000000d0cb2ffe4d822980434c5193297beff50ffc05ddeefebc3d14000000b4df87a0bace43657cc2ef635a5b888e7f0345c1";


$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];


$TimeCheckPassed = "Yes";  // Need a PowerShell script to check time difference.
$application = "One-Drive Delegation";

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

// Identify the file name used to load our data and make sure it does not exist.
$ODDOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/ODDMenuOutput.txt";
if (file_exists($ODDOutput)) { unlink($ODDOutput); }

// This function will be called if the 'IDActive' = '1' and the user is good to go.
function BuildSuccessPage($ODDOutput,$EmpID,$application)
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
	$txt = "<body onLoad='DisplayODDIntro();InitialFormerAssociateDropDownList();InitialRequesterDropDownList()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/OneDriveDelegation/GrantOneDriveFolderAccess.pl' target='mainpanel'>\n";
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
	$txt = "		<th width='7%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15_Underline'>Add Access</p>\n";
	fwrite($fh,$txt);
	$txt = "		</th>\n";
	fwrite($fh,$txt);
	$txt = "		<th width='7%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<p class='WhiteText_P15_Underline'>Remove Access</p>\n";
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
	$txt = "		<td width='7%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input type='radio' id='Action' name='Action' value='ADD' checked>\n";
	fwrite($fh,$txt);
	$txt = "		</td>\n";
	fwrite($fh,$txt);
	$txt = "		<td width='7%' align='center'>\n";
	fwrite($fh,$txt);
	$txt = "			<input type='radio' id='Action' name='Action' value='REMOVE'>\n";
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

function BuildIllegalPage($ODDOutput,$EmpID)
{
	$fh = fopen($ODDOutput, "a");
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

function BuildFailedPage($ODDOutput,$EmpID)
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
	$txt = "			<p class='AdminPortalHeading'>Sorry $firstName $lastName, your Admin Portal session has timed out after 60 minutes of inactivity.</p>\n";	
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

function BuildRestrictedPage($ODDOutput,$EmpID)
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

switch($AccessStatus)
{
	case 1:
		BuildSuccessPage($ODDOutput,$EmpID,$application);
		break;
	case 2:
		BuildIllegalPage($ODDOutput,$EmpID);
		break;
	case 3:
		BuildFailedPage($ODDOutput,$EmpID);
		break;
	case 4:
		BuildRestrictedPage($ODDOutput,$EmpID);
		break;
}

// That's it. Not it's up to the 'DisplayODDHTMLResponse.php' script to stream the HTML contents
// back to the screen when called by the 'ODD_Search_Settings.pl' script.

?>
