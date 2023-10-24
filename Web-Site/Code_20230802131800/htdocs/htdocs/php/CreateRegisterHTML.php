<?php

/*
        Program Name: CreateRegisterHTML.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: RegisterNewUser() function
             Purpose: Creates the CreateRegisterHTML.txt document which contains
                      the HTML code to display the result of the Cookie creation attempt.
*/

include("DBWebConnection.php");

$result1 = '';
$result2 = '';

$Name = $_POST['Name'];
$EmplID = $_POST['EmplID'];
$CookieStatus = $_POST['CookieStatus'];

/*
$RegisterThisUser = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/RegisterThisUser.txt";
if (file_exists($RegisterThisUser)) { unlink($RegisterThisUser); }

$fhTest = fopen($RegisterThisUser, "a");
$txt = "$EmplID;$Name";
fwrite($fhTest,$txt);
fclose($fhTest);
*/

$RegisterHTMLOutput = "C:/apache24/htdocs/php/RegisterHTMLOutput.txt";
if (file_exists($RegisterHTMLOutput)) { unlink($RegisterHTMLOutput); }

$fh = fopen($RegisterHTMLOutput, "a");

switch($CookieStatus)
{
	case 3:
		$txt = "Content-type: text/html\n\n";
		fwrite($fh,$txt);
		$txt = "<html>\n";
		fwrite($fh,$txt);
		$txt = "<head>\n";
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
		$txt = "<body bgcolor='#0F0141'>\n";
		fwrite($fh,$txt);
		$txt = "<table width='100%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "	<tr>\n";
		fwrite($fh,$txt);
		$txt = "		<td width='100%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "			<img width=1870 height=920 src='http://idmgmtapp01/images/FullScreenRegister.jpg'>\n";
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
		$sql = "update WebNewUsers set Registered = 'Yes',Authorized = 'Yes' where EmpID = '$EmplID'";
		$rs = odbc_exec($conn,$sql);
		$sql = "select * from WebNewUsers where EmpID  = '$EmplID'";
		$rs = odbc_exec($conn,$sql);
		$result1 = odbc_result($rs,"Registered");
		$result2 = odbc_result($rs,"Authorized");
		break;
	case 2:
		$txt = "Content-type: text/html\n\n";
		fwrite($fh,$txt);
		$txt = "<html>\n";
		fwrite($fh,$txt);
		$txt = "<head>\n";
		fwrite($fh,$txt);
		$txt = "</head>\n";
		fwrite($fh,$txt);
		$txt = "<body bgcolor='#0F0141'>\n";
		fwrite($fh,$txt);
		$txt = "<table width='100%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "	<tr>\n";
		fwrite($fh,$txt);
		$txt = "		<td width='30.3%'>&nbsp</td>\n";
		fwrite($fh,$txt);
		$txt = "		<td width='69.7%' align='left'>\n";
		fwrite($fh,$txt);
		$txt = "			<img width=350 height=600 src='http://idmgmtapp01/images/RegisterCookie_Unsuccessful.jpg'>\n";
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
		break;
	case 1:
		$txt = "Content-type: text/html\n\n";
		fwrite($fh,$txt);
		$txt = "<html>\n";
		fwrite($fh,$txt);
		$txt = "<head>\n";
		fwrite($fh,$txt);
		$txt = "</head>\n";
		fwrite($fh,$txt);
		$txt = "<body bgcolor='#0F0141'>\n";
		fwrite($fh,$txt);
		$txt = "<table width='100%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "	<tr>\n";
		fwrite($fh,$txt);
		$txt = "		<td width='100%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "			<img width=600 height=600 src='http://idmgmtapp01/images/RegisterSuccessful.jpg'>\n";
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
		break;
}
fclose($fh);

?>
