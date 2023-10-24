<?php


/*
        Program Name: CreateRegisterHTML.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: RegisterNewUser() function
             Purpose: Creates the CreateRegisterHTML.txt document which contains
					  the HTML code to display the result of the Cookie creation attempt.
*/

include("ProdDBWebConnection.php");

$Name = $_POST['Name'];
$EmplID = $_POST['EmplID'];
$CookieStatus = $_POST['CookieStatus'];

/*
$Name = "Dave Jaynes";
$EmplID = "103257";
$CookieStatus = 3;
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
		$txt = "	<div style='position:relative'>\n";
		fwrite($fh,$txt);
		$txt = "			<img width=790 height=634 src='http://idmgmtapp01/images/RegisterSuccessful.jpg' usemap='#image-map'>\n";
		fwrite($fh,$txt);
		$txt = "			<map name='image-map'>\n";
		fwrite($fh,$txt);
		$txt = "				<area target='_parent' alt='http://idmgmtapp01/' title='IDM Web Site' href='http://idmgmtapp01/' coords='566,372,605,390' shape='rect'>\n";
		fwrite($fh,$txt);
		$txt = "			</map>\n";
		fwrite($fh,$txt);
		$txt = "		</div>\n";
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
		odbc_exec($conn,$sql);
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