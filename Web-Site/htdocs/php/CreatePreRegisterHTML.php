<?php

/*
        Program Name: CreatePreRegisterHTML.php
        Date Written: July 8th, 2023
          Written By: Dave Jaynes
             Purpose: Creates the response HTML page when an Admin registers a new user.
*/

include("DBWebConnection.php");

$Name = $_POST['Name'];
$EmplID = $_POST['EmplID'];

$RegisterHTMLOutput = "C:/apache24/htdocs/php/RegisterHTMLOutput.txt";
if (file_exists($RegisterHTMLOutput)) { unlink($RegisterHTMLOutput); }

$fh = fopen($RegisterHTMLOutput, "a");
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
fclose($fh);
?>
