<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: RegisterNewUser.php                                                                            |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: This nifty script actually creates the application buttons in the Admin portal page.        |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$role = '';
$FinalOutput = '';
$Count = '';

$requesterName = $_POST['requesterName'];
$EmpID = $_POST['EmpID'];
$lastName = $_POST['lastName'];
$firstName = $_POST['firstName'];
$user = $_POST['user'];
$EmpID = $_POST['EmpID'];
$ProdEncryptedKey = $_POST['ProdEncryptedKey'];

function DeleteRecords($EmpID)
{
	include("DBWebConnection.php");
	$sql = "delete from WebNewUsers where EmpID = '$EmpID'";
	odbc_exec($conn,$sql);
	$sql = "delete from WebUserRoles where EmpID = '$EmpID'";
	odbc_exec($conn,$sql);
	$sql = "delete from WebEncryptedKeys where EmpID = '$EmpID'";
	odbc_exec($conn,$sql);
	$sql = "delete from WebSearchFields where EmpID = '$EmpID'";
	odbc_exec($conn,$sql);
	$sql = "delete from WebRegisteredUsers where userID = '$EmpID'";
	odbc_exec($conn,$sql);
}

function AddMissingRecords($EmpID,$lastName,$firstName)
{
	include("DBWebConnection.php");
	
	// Check for entry in the WebUserRoles table
	$NumRecords = 0;
	$CountNumRecords = "select count(*) from WebUserRoles where EmplID  = '$EmpID'";
	$rs = odbc_exec($conn,$CountNumRecords);
	odbc_fetch_row($rs);
	$NumRecords = odbc_result($rs,$Count);
	if($NumRecords == 0)
	{
		$sql = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('$EmpID','No','No','Yes','Yes','No')";
		odbc_exec($conn,$sql);
	}
	
	// Check for entry in the WebSearchFields table
	$NumRecords = 0;
	$CountNumRecords = "select count(*) from WebSearchFields where EmplID  = '$EmpID'";
	$rs = odbc_exec($conn,$CountNumRecords);
	odbc_fetch_row($rs);
	$NumRecords = odbc_result($rs,$Count);
	if($NumRecords == 0)
	{
		$sql = "insert into WebSearchFields(EmpID,srchAssocID) values ('$EmpID','None')";
		odbc_exec($conn,$sql);
	}
	
	// Check for entry in the WebRegisteredUsers table
	$NumRecords = 0;
	$CountNumRecords = "select count(*) from WebSearchFields where userID  = '$EmpID'";
	$rs = odbc_exec($conn,$CountNumRecords);
	odbc_fetch_row($rs);
	$NumRecords = odbc_result($rs,$Count);
	if($NumRecords == 0)
	{
		$sql = "insert into WebSearchFields(userID,lastName,firstName,phoneNumber,textCode,userTextCode) values ('$EmpID','$lastName','$firstName','None','None','None')";
		odbc_exec($conn,$sql);
	}
		
	

/*

This function will perform the registration attempt.

So far all we know is that a user was selected from a drop-down box in 
the 'Add User To Portal' utility in the Housekeeping utility web site.

Now one of four situations will be ture concerning the user being registered:

1.	The user and Encrypted cookies do not exist on the user's laptop, but they are registered.
2.	The user and Encrypted cookies do not exist on the user's laptop and they are not registered.
3.	The user and Encrypted cookies do exist on the user's laptop and they are already successfully registered.
4.	The user and Encrypted cookies do exist on the users laptop, but they are NOT currently registered.

The five tables that will come into play when making these conditional checks are:

1. WebNewUsers 
2. WebUserRoles 
3. WebEncryptedKeys 
4. WebSearchFields 
5. WebRegisteredUsers 

In order to get a result of this complex matrix of checking tables for various entries, we will
assign a Binary value variable (BinaryCounter) where each time one of the five conditions above 
are true, a value of 1,2,4,8 or 16 is added to the Binary search variable depending on the condition. 

In the big picture, there are 24 possible results. (Outcomes 16 thru 23 are not possible).

So in the following lines of code we will be checking for:

1. Is the user Cookie empty. 
   - Add 1 to the BinaryCounter variable if true
2. If the Encrypted key Cookie empty. 
   - Add 2 to the BinaryCounter variable if true
3. Is there an entry in the WebNewUsers table for the user Cookie value.
   - Add 4 to the BinaryCounter variable if true
4. Is there an entry in the WebEncryptedKeys table for the user Cookie value.
   - Add 8 to the BinaryCounter variable if true
5. Does the values for the Encrypted Cookie value match its counterpart in the WebEncryptedKeys table.
   - Add 16 to the BinaryCounter variable if true
*/

$BinaryCounter = 0;

// Check for existing of user cookie and assign 1 to BinaryCounter if not equal to 'Empty'.
if($user != "Empty") { $BinaryCounter++; }

// Check for existing of user cookie and add 2 to BinaryCounter if not equal to 'Empty'.
if($ProdEncryptedKey != "Empty") { $BinaryCounter += 2; }

// If number of records found when searching for the EmplID in 'WebNewUsers', add 4 to BinaryCounter.
$NumRecords = 0;
$CountNumRecords = "select count(*) from WebNewUsers where EmplID  = '$EmpID'";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
if($NumRecords > 0) { $BinaryCounter += 4; }

// If number of records found when searching for the EmplID in 'WebNewUsers', add 4 to BinaryCounter.
$NumRecords = 0;
$CountNumRecords = "select count(*) from WebEncryptedKeys where EmplID  = '$EmpID'";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

// Test if the WebEncryptedKeys table has an entry for the Employee ID.
// If so, add 8 to BinaryCounter. 
if($NumRecords > 0) 
{ 
	$BinaryCounter += 8; 
	$sql = "select * from WebEncryptedKeys where EmpID = '$EmpID'";
	$rs = odbc_exec($conn,$sql);
	odbc_fetch_row($rs);
	$ProdEncryptedKeySQLValue = odbc_result($rs,"EncryptedKey");	
	
	// Finally, check if the ProdEncryptedKey Cookie matches its value in the WebEncryptedKeys table.
	// If so, add 16 to BinaryCounter.
	if($ProdEncryptedKeySQLValue == $ProdEncryptedKey) { $BinaryCounter += 16;
}

/*


There are 32 possible combined outcomes for all these checks.

We also have to define what the 'ReturnValue' values mean when we pass them back to 'RegisterNewUser' function:

ReturnValue		Action to take by the 'RegisterNewUser' function
-----------		------------------------------------------------
	0			Re-Register the user.
	1			Delete both the cookies and Re-Register the user.
	2			User is registered but both 'user' and 'Encrypted' Cookie are empty.
				The user may have cleared their cache and deleted the cookies in the process.
				In this case, the user will need to go to the reset client link and enter the
				initial code they were given in the registration e-mail. If the user does not
				have that code, they will need to contact an IDM website admin and ask for the 
				unencrypted code. The user will then go to the reset client website and enter the
				unencrypted key value to restore their encrypted keys.
	3			User is registered and Encrypted key is good but 'user' Cookie is empty. 
				In this case, use the reset client website to restore the 'user' Cookie.
	4			User is registered and user key is good but 'Encrypted' Cookie is empty.
				In this case, the user will need to ask an IDM website admin for the unencrypted
				key value. The user will then go to the reset client website and enter the
				unencrypted key value to restore their encrypted key.
	5			Client is already fully registered. Basically we selected a user from the drop-down
				list in the 'Add User To Portal' that is already registered. No action is necessary.
				
We will now use the Select state to check the BinaryCounter value
and determine from each outcome where the 4 situations of a 
previously registered user fits in.
*/

select($BinaryCounter)
{
	case 0:
		// User was never registered before.
		DeleteRecords(); // Do this anyway even though there should be no records for this employee present.
		$ReturnValue = 0;
		break;
	case 1:
		// User was once registered. We nuke the user and ProdEncryptedKey cookie values and re-register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 2:
		// User was once registered. We nuke the user and ProdEncryptedKey cookie values and re-register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 3:
		// User was once registered. We nuke the user and ProdEncryptedKey cookie values and re-register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 4:
		// This situation will never happen as that means there would be a row in the WebNewUsers table with a EmpID value of 'Empty'.
		$ReturnValue = 0;
		break;
	case 5:
		// User is registered but ProdEncryptedKey key is empty. User visits 
		// 
		$ReturnValue = 2;
		break;
	case 6:
		// User was never registered before.
		$ReturnValue = 3;
		break;
	case 7:
		// User was at one time registered but the WebEncryptedKeys entry is missing an entry. Re-Register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 8:
		// User was at one time registered but the cookies is missing. Re-Register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 9:
		// User was at one time registered but the ProdEncryptedKey cookie is missing. Re-Register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 10:
		// User was at one time registered but the user cookie is missing and Encrypted key pair does not match. Re-Register.
		$ReturnValue = 1;
		break;
	case 11:
		// User was at one time registered but the WebNewUsers entry is missing an entry. Re-Register.
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 12:
		// User is registered but cookies are missing. Go to reset client link.
		$ReturnValue = 2;
		break;
	case 13:
		// User is registered but ProdEncryptedKey cookie is missing. Go to reset client link. 
		$ReturnValue = 2;
		break;
	case 14:
		// User is registered but user cookie is missing and Encrypted key pair does not match. Go to reset client link.
		$ReturnValue = 2;
		break;
	case 15:
		// User is fully registered but the Encrypted key pair does not match. Go to reset client link.
		$ReturnValue = 2;
		break;
	case 24:
		// User is registered correctly. user and ProdEncryptedKey Cookies are missing. Go to reset client link.
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
		break;
	case 25:
		// User is registered correctly. ProdEncryptedKey Cookie is missing. Go to reset client link.
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
	case 26:
		// User is registered correctly. user Cookie is missing. Go to reset client link.
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
	case 27:
		// User was never registered before.
		$ReturnValue = 0;
		break;
	case 28:
		// User was never registered before.
		$ReturnValue = 0;
		break;
	case 29:
		// User was never registered before.
		$ReturnValue = 0;
		break;
	case 30:
		// User was never registered before.
		$ReturnValue = 0;
		break;
	case 31:
		// User was never registered before.
		$ReturnValue = 0;
		break;
		



$sql = "select EmpID from WebNewUsers where EmplID  = '$EmpID'";
$result = odbc_exec($conn,$sql);

function FormLink($FunctionName,$FunctionID,$Value,$Image,$Width,$Height,$Description,$Call,$URL,$TARGET,$SubmitFunction)
{
	$output = '';
	$output1 = '<FORM id="' . $Call . '" METHOD="POST" ACTION="' . $URL . '" target="' . $TARGET . '">';
	$output2 = "<table border=0 style='width:100%'>";
	$output3 = "<tr><td align='center'>";
	$output4 = '<input id="Submit" name="Submit" value="' . $Value . '" type="image" src="' . $Image . '" width="' . $Width . '" height="' . $Height . '" align="middle" border="0" onMouseOver="' . $Description . '();" onMouseLeave="MainTopDisplay();" onClick=' . "'" . 'SetShowDescriptionsOff();' . $FunctionName . '(id=' . '"' . $FunctionID . '"' . ');' . $SubmitFunction . '();' . "'" . '>';
	$output5 = "</td></tr>";
	$output6 = "</table>";
	$output7 = "</FORM>";
    $output8 = "<br>";
	// $output = $output1 . "\n" . $output2 . "\n" . $output3 . "\n" .  $output4 . "\n" .  $output5 . "\n" .  $output6 . "\n" .  $output7. "\n" .  $output8;
	$output = $output1 . $output2 . $output3 . $output4 . $output5 . $output6 . $output7. $output8;
    return $output;
}

function RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction)
{
	include("DBWebConnection.php");
	$ApplicationOutput = '';
	$rs=odbc_exec($conn,$sql1);
	odbc_fetch_row($rs);
	$Result = odbc_result($rs,"role");
	if($Result == 'Yes')
	{
		$rs=odbc_exec($conn,$sql2);
		if (!$rs) {exit("Error in SQL");}
		while (odbc_fetch_row($rs))
		{
			$FunctionName  = odbc_result($rs,"FunctionName");
			$FunctionID  = odbc_result($rs,"FunctionID");
			$Value = odbc_result($rs,"Value");
			$Image  = odbc_result($rs,"Image");
			$Width  = odbc_result($rs,"Width");
			$Height = odbc_result($rs,"Height");
			$ODDLink = FormLink($FunctionName,$FunctionID,$Value,$Image,$Width,$Height,$Description,$Call,$URL,$TARGET,$SubmitFunction);
		}
		$ApplicationOutput = $ApplicationOutput . $ODDLink;
		return $ApplicationOutput;
	}
}

// OneDriveDelegation
$sql1="select OneDriveDelegation as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'OneDriveDelegation';";
$Description = "ODD_Description";
$URL = "/cgi-bin/OneDriveDelegation/CreateODDHTMLResponse.pl";
$Call = "CallODDelegation";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitODDRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

// ADAccountCreation
$sql1="select ADAccountCreation as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'ADAccountCreation';";
$Description = "ADAC_Description";
$Call = "CallAcctCreation";
$URL = "/cgi-bin/ADAccountCreation/CreateADACHTMLResponse.pl";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitADACRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

// TerminateAssociate
$sql1="select TerminateAssociate as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'TerminateAssociate';";
$Description = "BlueBlank_Description";
$Call = "CallTerminateAssociate";
$URL = "/cgi-bin/AssociateTerminations/CreateTERMHTMLResponse.pl";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitTERMRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

print "$FinalOutput";

odbc_close($conn);
?>
