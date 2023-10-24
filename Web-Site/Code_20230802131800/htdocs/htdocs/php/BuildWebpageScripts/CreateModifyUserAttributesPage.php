<?php

/*
        Program Name: CreateModifyUserAttributesPage.php
        Date Written: June 14th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: Creates the CreateModifyUserAttributesPage.txt document which contains
					  the HTML code to modify user's attributes.
*/

include("DBWebConnection.php");
$Count = '';

$illegalAccess = $_POST['illegalAccess'];

$CreateModifyUserAttributesOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/CreateModifyUserAttributesPage.txt";
if (file_exists($CreateModifyUserAttributesOutput)) { unlink($CreateModifyUserAttributesOutput); }
$fh = fopen($CreateModifyUserAttributesOutput, "w");
if($illegalAccess == 'No')
{
	// Pull role assignments
	function GetApplicationAccess($EmpID,$Application)
	{
		include("DBWebConnection.php");
		$sql = "select * from WebUserRoles where EmpID = '$EmpID';";
		$ApplicationResult = '';
		$rs = odbc_exec($conn,$sql);
		odbc_fetch_row($rs);
		$ApplicationResult = odbc_result($rs,$Application);
		return $ApplicationResult;
	}
	
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
	$txt = "<BODY onLoad='UpdateUserSettings()' bgcolor='#0F0141'>\n";
	fwrite($fh,$txt);
	$txt = "<FORM id='ModifyUsersRole' METHOD='POST' ACTION='/cgi-bin/HousekeepingScripts/CreateModifyUserAttributesPage.pl'>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>This section allows for the update or deletion of registered user accounts.</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>To change settings for either application roles or user access, simply click</p></th></tr>\n"; 
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>on the check box values associated with a users name. These changes will </p></th></tr>\n"; 
	fwrite($fh,$txt);
	$txt = "<tr><th><p class='TitleSmallWhite'>then be reflected within the website immediately after a selection is clicked.</p></th></tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<br>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='32%'>&nbsp</td>\n";	
	fwrite($fh,$txt);
	$txt = "<td width='30%'><p class='ModifyRoleAssignmentHeader'>Modify Role Assignments for Each User Below</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='4.5%'>&nbsp</td>\n";	
	fwrite($fh,$txt);
	$txt = "<td width='16%'><p class='ModifyRoleAssignmentHeader'>Modify User Access</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='17.5%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);
	$txt = "<tr>\n";
	fwrite($fh,$txt);
	$txt = "<td width='7%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='13%'><p class='Heading'>Name</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='9%'><p class='Heading'>Registered</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='12%'><p class='Heading'>One-Drive Delegate</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='12%'><p class='Heading'>AD Account Creation</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='12%'><p class='Heading'>Terminate Associate</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='9%'><p class='Heading'>Authorized</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='9%'><p class='Heading'>Admin Access</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='9%'><p class='Heading'>Delete User</p></td>\n";
	fwrite($fh,$txt);
	$txt = "<td width='8%'>&nbsp</td>\n";
	fwrite($fh,$txt);
	$txt = "</tr>\n";
	fwrite($fh,$txt);
	$txt = "</table>\n";
	fwrite($fh,$txt);
	$txt = "<table width='100%' border='0'>\n";
	fwrite($fh,$txt);

	$sql="SELECT WebNewUsers.EmpID, WebNewUsers.Name, WebNewUsers.Registered,WebUserRoles.Authorized, WebUserRoles.AdminAccess, WebUserRoles.OneDriveDelegation, WebUserRoles.ADAccountCreation,WebUserRoles.TerminateAssociate FROM WebNewUsers INNER JOIN WebUserRoles ON WebNewUsers.EmpID = WebUserRoles.EmpID order by WebNewUsers.Name;";
	$rs=odbc_exec($conn,$sql);
	if (!$rs)
		{exit("Error in SQL");}
	$Counter = 0;
	while (odbc_fetch_row($rs))
	{
		$Counter++;
		
		// Get the basics from the WebNewUsers table.
		$EmpID = odbc_result($rs,"EmpID");
		$Name = odbc_result($rs,"Name");
		$Registered = odbc_result($rs,"Registered");
		$Authorized = odbc_result($rs,"Authorized");
		$AdminAccess = odbc_result($rs,"AdminAccess");
		$ODDAccess = odbc_result($rs,"OneDriveDelegation");
		$ADACAccess = odbc_result($rs,"ADAccountCreation");
		$TERMAccess = odbc_result($rs,"TerminateAssociate");
		$EmpID = trim($EmpID);
		$Name = trim($Name);
		$Registered = trim($Registered);
		$Authorized = trim($Authorized);
		$AdminAccess = trim($AdminAccess);
		$ODDAccess = trim($ODDAccess);
		$ADACAccess = trim($ADACAccess);
		$TERMAccess = trim($TERMAccess);
		$AllThree = $EmpID . ";" . $Name . ";" . $Counter;

		$txt = "<tr>\n";
		fwrite($fh,$txt);
		$txt = "<td width='3%'>\n";
		fwrite($fh,$txt);
		
		// We hide the employee ID by making the color of the ID the same color as the background, 
		// make the input border invisible and making the text box only one pixel in length.
		$txt = "<input id='EmpID${Counter}' name='EmpID${Counter}' type='text' value='$EmpID' style='color:#0F0141; background-color#0F0141; border: none; border-color: transparent;width: 1px'>\n";
		fwrite($fh,$txt);
		$txt = "</td>\n";
		fwrite($fh,$txt);
		
		fwrite($fh,$txt);
		$txt = "<td width='4%'>\n";
		fwrite($fh,$txt);
		
		// We hide the associate name by making the color of the ID the same color as the background, 
		// make the input border invisible and making the text box only one pixel in length.
		$txt = "<input id='Name${Counter}' name='Name${Counter}' type='text' value='$Name' style='color:#0F0141; background-color#0F0141; border: none; border-color: transparent;width: 1px'>\n";
		fwrite($fh,$txt);
		$txt = "</td>\n";
		fwrite($fh,$txt);
		
		// Name Area
		$txt = "<td width='13%'><p class='Detail'>$Name</p></td>\n";
		fwrite($fh,$txt);
		
		// Registered Area
		$txt = "<td width='9%'><p class='Detail'>$Registered</p></td>\n";
		fwrite($fh,$txt);

		// Check/Uncheck One Drive Deletion
		$txt = "<td width='12%' align='center'>\n";
		fwrite($fh,$txt);
		if($ODDAccess == 'Yes')
		{
			$txt = "<input type='checkbox' name='ODDAccessLevel${Counter}' id='ODDAccessLevel${Counter}' checked onChange='UpdateUserSettings()'>\n";
			fwrite($fh,$txt);
		}
		else
		{
			$txt = "<input type='checkbox' name='ODDAccessLevel${Counter}' id='ODDAccessLevel${Counter}' onChange='UpdateUserSettings()'>\n";
			fwrite($fh,$txt);
		}
		$txt = "</td>\n";
		fwrite($fh,$txt);

		// Check/Uncheck AD Account Creation
		$txt = "<td width='12%' align='center'>\n";
		fwrite($fh,$txt);
		if($ADACAccess == 'Yes')
		{
			$txt = "<input type='checkbox' name='ADACAccessLevel${Counter}' id='ADACAccessLevel${Counter}' checked onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		else
		{
			$txt = "<input type='checkbox' name='ADACAccessLevel${Counter}' id='ADACAccessLevel${Counter}' onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		$txt = "</td>\n";
		fwrite($fh,$txt);
		
		// Check/Uncheck Associate Termination
		$txt = "<td width='12%' align='center'>\n";
		fwrite($fh,$txt);
		if($TERMAccess == 'Yes')
		{
			$txt = "<input type='checkbox' name='TERMAccessLevel${Counter}' id='TERMAccessLevel${Counter}' checked onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		else
		{
			$txt = "<input type='checkbox' name='TERMAccessLevel${Counter}' id='TERMAccessLevel${Counter}' onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		$txt = "</td>\n";
		fwrite($fh,$txt);

		// Authorized Area
		$txt = "<td width='9%' align='center'>\n";
		fwrite($fh,$txt);
		if($TERMAccess == 'Yes')
		{
			$txt = "<input type='checkbox' name='Authorized${Counter}' id='Authorized${Counter}' checked onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		else
		{
			$txt = "<input type='checkbox' name='Authorized${Counter}' id='Authorized${Counter}' onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		$txt = "</td>\n";
		fwrite($fh,$txt);
		
		// Admin Access Area
		$txt = "<td width='9%' align='center'>\n";
		fwrite($fh,$txt);
		if($TERMAccess == 'Yes')
		{
			$txt = "<input type='checkbox' name='AdminAccess${Counter}' id='AdminAccess${Counter}' checked onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		else
		{
			$txt = "<input type='checkbox' name='AdminAccess${Counter}' id='AdminAccess${Counter}' onChange='UpdateUserSettings();'>\n";
			fwrite($fh,$txt);
		}
		$txt = "</td>\n";
		fwrite($fh,$txt);
		
		// Delete User
		$txt = "<td width='9%' align='center'>\n";
		fwrite($fh,$txt);
		$txt = "<input type='radio' name='deleteuser${Counter}' id='deleteuser${Counter}' value='$EmpID' onChange='ModifyUsersRoles($Counter)'>\n";
		fwrite($fh,$txt);
		$txt = "</td>\n";
		fwrite($fh,$txt);	
		$txt = "<td width='8%'>&nbsp</td>\n";
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
