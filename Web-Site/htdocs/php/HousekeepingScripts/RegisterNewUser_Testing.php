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

/*
$requesterName = $_POST['requesterName'];
$EmpID = $_POST['EmpID'];
$lastName = $_POST['lastName'];
$firstName = $_POST['firstName'];
$user = $_POST['user'];
$ProdEncryptedKey = $_POST['ProdEncryptedKey'];
*/

/*
// Scenario 1: Fully registered
$requesterName = 'dave.jaynes@eversana.com';
$EmpID = "103257";
$lastName = "Jaynes";
$firstName = "Dave";
$user = "103257";
$ProdEncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000f071b55641ec17231581a5919be095900000000004800000a000000010000000d1fff6040f7070ed19c5c3cbbc08a051180000000273d29bf97b6724bfa9604c4fd2d0e37a1c3656c17832f914000000292f9acdb478c8b017e74199e4b21bb3f8323f76";
*/
/*
// Scenario 2: Missing Cookies
$requesterName = 'dave.jaynes@eversana.com';
$EmpID = "103257";
$lastName = "Jaynes";
$firstName = "Dave";
$user = "";
$ProdEncryptedKey = "";
*/

// Scenario 3: Brand new user never registered
$requesterName = 'mickey.mouse@eversana.com';
$EmpID = "345678";
$lastName = "Mouse";
$firstName = "Mickey";
$user = "345678";
$ProdEncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000f071b55641ec17231581a5919be095900000000004800000a000000010000000d1fff6040f7070ed19c5c3cbbc08a051180000000273d29bf97b6724bfa9604c4fd2d0e37a1c3656c17832f914000000292f9acdb478c8b017e74199e4b21bb3f8323f76";


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
if($user != "Empty" && $user != "") { $BinaryCounter++; }

// Check for existing of user cookie and add 2 to BinaryCounter if not equal to 'Empty'.
if($ProdEncryptedKey != "Empty" && $ProdEncryptedKey != "") { $BinaryCounter += 2; }

// If number of records found when searching for the EmplID in 'WebNewUsers', add 4 to BinaryCounter.
$NumRecords = 0;
$CountNumRecords = "select count(*) from WebNewUsers where EmpID  = '$EmpID'";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);
if($NumRecords > 0) { $BinaryCounter += 4; }

// If number of records found when searching for the EmplID in 'WebNewUsers', add 4 to BinaryCounter.
$NumRecords = 0;
$CountNumRecords = "select count(*) from WebEncryptedKeys where EmpID  = '$EmpID'";
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
	if($ProdEncryptedKeySQLValue == $ProdEncryptedKey) { $BinaryCounter += 16; }
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

switch ($BinaryCounter)
{
	case 0:
		// DONE: User was never registered before.
		print "Case 0\n";
		$ReturnValue = 0;
		break;
	case 1:
		// User only has Employee ID Cookie. We nuke the user and ProdEncryptedKey cookie values and re-register.
		print "Case 1\n";
		$ReturnValue = 1;
		break;
	case 2:
		// User was once registered. We nuke the user and ProdEncryptedKey cookie values and re-register.
		print "Case 2\n";
		$ReturnValue = 1;
		break;
	case 3:
		// User was once registered. We nuke the user and ProdEncryptedKey cookie values and re-register.
		print "Case 3\n";
		$ReturnValue = 1;
		break;
	case 4:
		// This situation will never happen as that means there would be a row in the WebNewUsers table with a EmpID value of 'Empty'.
		print "Case 4\n";
		$ReturnValue = 0;
		break;
	case 5:
		// User is registered but ProdEncryptedKey key is empty. User visits 
		print "Case 5\n";
		$ReturnValue = 2;
		break;
	case 6:
		// User was never registered before.
		print "Case 6\n";
		$ReturnValue = 3;
		break;
	case 7:
		// User was at one time registered but the WebEncryptedKeys entry is missing an entry. Re-Register.
		print "Case 7\n";
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 8:
		// User was at one time registered but the cookies is missing. Re-Register.
		print "Case 8\n";
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 9:
		// User was at one time registered but the ProdEncryptedKey cookie is missing. Re-Register.
		print "Case 9\n";
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 10:
		// User was at one time registered but the user cookie is missing and Encrypted key pair does not match. Re-Register.
		print "Case 10\n";
		$ReturnValue = 1;
		break;
	case 11:
		// User was at one time registered but the WebNewUsers entry is missing an entry. Re-Register.
		print "Case 11\n";
		DeleteRecords();
		$ReturnValue = 1;
		break;
	case 12:
		// DONE: User is registered but both cookies are missing. Go to reset client link.
		print "Case 12\n";
		$ReturnValue = 2;
		break;
	case 13:
		// Done: User is registered but ProdEncryptedKey cookie is missing. Go to reset client link and use code to re-write Encrypted key. 
		print "Case 13\n";
		$ReturnValue = 2;
		break;
	case 14:
		// DONE: User is registered but user cookie is missing and Encrypted key pair does not match. Go to reset client link.
		print "Case 14\n";
		$ReturnValue = 2;
		break;
	case 15:
		// DONE: User is fully registered but the Encrypted key pair does not match. Go to reset client link.
		print "Case 15\n";
		$ReturnValue = 2;
		break;
	case 24:
		// User is registered correctly. user and ProdEncryptedKey Cookies are missing. Go to reset client link.
		print "Case 24\n";
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
		break;
	case 25:
		// User is registered correctly. ProdEncryptedKey Cookie is missing. Go to reset client link.
		print "Case 25\n";
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
	case 26:
		// User is registered correctly. user Cookie is missing. Go to reset client link.
		print "Case 26\n";
		AddMissingRecords($EmpID,$lastName,$firstName);
		$ReturnValue = 2;
	case 27:
		// User was never registered before.
		print "Case 27\n";
		$ReturnValue = 0;
		break;
	case 28:
		// User was never registered before.
		print "Case 28\n";
		$ReturnValue = 0;
		break;
	case 29:
		// User was never registered before.
		print "Case 29\n";
		$ReturnValue = 0;
		break;
	case 30:
		// DONE: Only Employee ID missing. Go to Website Clinic and have Employee ID Cookie re-written to laptop.
		print "Case 30\n";
		$ReturnValue = 0;
		break;
	case 31:
		// Done: User is fully registered and running OK. Display message that user is already registered.
		print "Case 31\n";
		$ReturnValue = 0;
		break;
}

?>
