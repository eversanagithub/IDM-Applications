<?php

/*
        Program Name: CreateModifyApplicationAttributesPage.php
        Date Written: June 14th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateModifyUserAttributesPage.txt document which contains
					  the HTML code to modify application attributes.
*/

include("DBWebConnection.php");
$Count = '';

$illegalAccess = $_POST['illegalAccess'];
// $illegalAccess = "No";
$application = "Application Modification";

$CreateModifyApplicationAttributesOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/CreateModifyApplicationAttributesPage.txt";
if (file_exists($CreateModifyApplicationAttributesOutput)) { unlink($CreateModifyApplicationAttributesOutput); }
$fh = fopen($CreateModifyApplicationAttributesOutput, "w");

if($illegalAccess == 'No')
{
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<HTML>\n";
	fwrite($fh,$txt);
	$txt = "<HEAD>\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/UserModStyles.css'>\n";
	fwrite($fh,$txt);
	$txt = "<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	fwrite($fh,$txt);
	$txt = "</head>\n";
	fwrite($fh,$txt);
	$txt = "<BODY bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>Application Access Levels are a way of assigning values to applications which provide a scope of visibility to registered users.</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>Each application is assigned a value between one and three; one assigned to an app that every registered user can see</p></th></tr>\n"; 
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>while three being assigned to an app that is not widely used by everyone. Coorespondingly, each registered user</p></th></tr>\n"; 
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>is also assigned an access level between one and three. Registered users who have an access level of one</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>can only see applications that have an access level of one. Users with an access level of two can see applications</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>with an access level of one or two. Registered user with an access level of three can see all applications.</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>If you feel an application needs to have more or less visibility, you can lower or raise its access level using the</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>selection drop down boxes below to change an application's access level, thus fitting it to the needs of the user community.</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='30%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%'><p class='Heading'>Application Name</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='15%'><p class='Heading'>Access Level</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='40%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	// Get record count
	$CountNumRecords = "select count(*) from WebAdminPortalApplicationURL;";
	$rs = odbc_exec($conn,$CountNumRecords);
	odbc_fetch_row($rs);
	$NumRecords = odbc_result($rs,$Count);

	$sql="select * from WebAdminPortalApplicationURL;";
	$rs=odbc_exec($conn,$sql);
	if (!$rs)
		{exit("Error in SQL");}
	$Counter = 0;
	while (odbc_fetch_row($rs))
	{
		$Counter++;
		$Application = odbc_result($rs,"application");
		$AccessLevel = odbc_result($rs,"level");
		$ApplicationURL = odbc_result($rs,"applicationURL");
		$txt = "<tr>\n";
		fwrite($fh,$txt);
		
		// Application Name
		$txt = "<td width='30%'>&nbsp</td>\n";
		fwrite($fh,$txt);
		$txt = "<td width='15%'>\n";
		fwrite($fh,$txt);
		$txt = "<input id='Application${Counter}' name='Application${Counter}' type='text' value='$Application' size='6'>\n";
		fwrite($fh,$txt);
		$txt = "</td>\n";
		fwrite($fh,$txt);

		// Access Level
		$txt = "<td width='15%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "<select name='AccessLevel${Counter}' id='AccessLevel${Counter}' onChange='UpdateApplicationSettings()'>\n";
		fwrite($fh,$txt);
		if($AccessLevel == 1) 
		{ 
			$txt = "<option value='1' selected>1</option>\n"; 
			fwrite($fh,$txt);
		} 
		else 
		{ 
			$txt = "<option value='1'>1</option>\n"; 
			fwrite($fh,$txt);
		}
		if($AccessLevel == 2) 
		{ 
			$txt = "<option value='2' selected>2</option>\n"; 
			fwrite($fh,$txt);
		} 
		else 
		{ 
			$txt = "<option value='2'>2</option>\n"; 
			fwrite($fh,$txt);
		}
		if($AccessLevel == 3) 
		{ 
			$txt = "<option value='3' selected>3</option>\n"; 
			fwrite($fh,$txt);
		} 
		else 
		{ 
			$txt = "<option value='3'>3</option>\n"; 
			fwrite($fh,$txt);
		}
		$txt = "</select>\n";
		fwrite($fh,$txt);
		$txt = "</td>\n";
		fwrite($fh,$txt);

		$txt = "<td width='40%'>&nbsp</td>\n";
		fwrite($fh,$txt);
		$txt = "</tr>\n";
		fwrite($fh,$txt);
	}

	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</form>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
}
else
{
	$txt = "Content-type: text/html\n\n";
	fwrite($fh,$txt);
	$txt = "<html>\n";
	fwrite($fh,$txt);
	$txt = "<head>\n";
	fwrite($fh,$txt);
	$txt = "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
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
	$txt = "<img width=900 height=610 src='http://idmgmtapp01/images/NoAdminPrivileges.jpg'>\n";
	fwrite($fh,$txt);
	$txt = "</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "</form>\n";
	fwrite($fh,$txt);
	$txt = "</body>\n";
	fwrite($fh,$txt);
	$txt = "</html>\n";
	fwrite($fh,$txt);
}
fclose($fh);

?>
