<?php


/*
        Program Name: CreateDisplayEventLogs.php
        Date Written: July 1st, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateADACHTMLResponse.txt document which contains
					  the HTML code to display the Active Direct Account Creation page.
*/
$Conn = '';
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


$EmpID = "103257";
$EncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000f071b55641ec17231581a5919be095900000000004800000a000000010000000d1fff6040f7070ed19c5c3cbbc08a051180000000273d29bf97b6724bfa9604c4fd2d0e37a1c3656c17832f914000000292f9acdb478c8b017e74199e4b21bb3f8323f76";

/*
$EmpID = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];
*/

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

// Identify the file name used to load our data and make sure it does not exist.
$TERMOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/DisplayEventLogs.txt";
if (file_exists($TERMOutput)) { unlink($TERMOutput); }

// This function will be called if the 'IDActive' = '1' and the user is good to go.
function BuildSuccessPage($TERMOutput)
{
  include("DBWebConnection.php");
  $Count = 0;
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
  $txt = "<center>\n";
  fwrite($fh,$txt);
  $txt = "<table width=100%>\n";
  fwrite($fh,$txt);
  $txt = "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
  fwrite($fh,$txt);
  $txt = "</table>\n";
  fwrite($fh,$txt);
  $txt = "</br>\n";
  fwrite($fh,$txt);
  $txt = "<table width=100%>\n";
  fwrite($fh,$txt);
  $txt = "<table width='100%' border='1'>\n";
  fwrite($fh,$txt);
  $txt = "<tr>\n";
  fwrite($fh,$txt);
  $txt = "<th width='10%'><p class='RegistrationResponse3'>Executed By</p></th>\n";
  fwrite($fh,$txt);
  $txt = "<th width='10%'><p class='RegistrationResponse3'>Application</p></th>\n";
  fwrite($fh,$txt);
  $txt = "<th width='10%'><p class='RegistrationResponse3'>Time Of Execution</p></th>\n";
  fwrite($fh,$txt);
  $txt = "<th width='70%'><p class='RegistrationResponse3'>Description</p></th>\n";
  fwrite($fh,$txt);
  $txt = "</tr>\n";
  fwrite($fh,$txt);
  $sql="select * from WebIDMWebsiteLoggedEvents order by time_of_execution;";
  $rs=odbc_exec($conn,$sql);
  if (!$rs) {exit("Error in SQL");}
  $Counter = 0;
  while (odbc_fetch_row($rs))
  {
    $ExecutedBy = odbc_result($rs,"ExecutedBy");
    $Application = odbc_result($rs,"application");
    $TimeOfExecution = odbc_result($rs,"time_of_execution");
    $Description = odbc_result($rs,"description");
    $txt = "<tr>\n";
    fwrite($fh,$txt);
    $txt = "<td width='10%'><p class='RegistrationResponse3'>$ExecutedBy</p></td>\n";
    fwrite($fh,$txt);
    $txt = "<td width='10%'><p class='RegistrationResponse3'>$Application</p></td>\n";
    fwrite($fh,$txt);
    $txt = "<td width='10%'><p class='RegistrationResponse3'>$TimeOfExecution</p></td>\n";
    fwrite($fh,$txt);
    $txt = "<td width='10%'><p class='RegistrationResponse3'>$Description</p></td>\n";
    fwrite($fh,$txt);
    $txt = "</tr>\n";
    fwrite($fh,$txt);
  }
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
	$fh = fopen($TERMOutput, "a");
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

function BuildRestrictedPage($TERMOutput)
{
	$fh = fopen($TERMOutput, "a");
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
		BuildSuccessPage($TERMOutput);
		break;
	case 2:
		BuildIllegalPage($TERMOutput);
		break;
	case 3:
		BuildFailedPage($TERMOutput);
		break;
	case 4:
		BuildRestrictedPage($TERMOutput);
		break;
}

// That's it. Not it's up to the 'DisplayADACHTMLResponse.php' script to stream the HTML contents
// back to the screen.

?>
