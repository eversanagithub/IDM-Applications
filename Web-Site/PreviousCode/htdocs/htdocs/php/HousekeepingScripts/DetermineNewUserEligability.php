<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: DetermineNewUserEligability.php                                                             |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: Checks to see if the associate selected to be a new Admin Portal user is eligable.          |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");

$role = '';
$FinalOutput = '';
$Count = '';

$user = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];

/*
********************************************************************
*              Begin Function Defination Section                   *
******************************************************************** */
function GetAssociateSQLDetails($user)
{
	include("DBWebConnection.php");
	if($user == 'Empty')
	{
		$EmpID = "Blank";
		$LastName = "Blank";
		$FirstName = "Blank";
		$EncryptedKeySQLValue = "Blank";
	}
	else
	{
		$sql = "select * from Profile where EMPLID = '$user'";
		$rs = odbc_exec($conn,$sql);
		odbc_fetch_row($rs);
		$EmpID = odbc_result($rs,"EMPLID");	
		$LastName = odbc_result($rs,"PrefLName");
		$FirstName = odbc_result($rs,"PrefFName");
		$sql = "select * from WebEncryptedKeys where EmpID = '$user'";
		$rs = odbc_exec($conn,$sql);
		odbc_fetch_row($rs);
		$EncryptedKeySQLValue = odbc_result($rs,"EncryptedKey");
	}
	$AssociateValues = array();
	array_push($AssociateValues,$EmpID);
	array_push($AssociateValues,$LastName);
	array_push($AssociateValues,$FirstName);
	array_push($AssociateValues,$EncryptedKeySQLValue);
	return $AssociateValues;
}

function CalculateStatusCode($user,$EncryptedKey,$EmpID,$LastName,$FirstName,$EncryptedKeySQLValue)
{
	include("DBWebConnection.php");
	
	$Count = '';
	$BinaryCounter = 0;

	// Check for existing of user cookie and assign 1 to BinaryCounter if not equal to 'Empty'.
	if($user != "Empty" && $user != "Blank" && $user != "") { $BinaryCounter++; }

	// Check for existing of user cookie and add 2 to BinaryCounter if not equal to 'Empty'.
	if($EncryptedKey != "Empty" && $EncryptedKey != "") { $BinaryCounter += 2; }

	// If number of records found when searching for the EmplID in 'WebNewUsers', add 4 to BinaryCounter.
	$NumRecords = 0;
	$CountNumRecords = "select count(*) from WebNewUsers where EmpID  = '$EmpID'";
	$rs = odbc_exec($conn,$CountNumRecords);
	odbc_fetch_row($rs);
	$NumRecords = odbc_result($rs,$Count);
	if($NumRecords > 0) { $BinaryCounter += 4; }

	// If number of records found when searching for the EmplID in 'WebEncryptedKeys', add 4 to BinaryCounter.
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
		$EncryptedKeySQLValue = odbc_result($rs,"EncryptedKey");	
	
		// Finally, check if the EncryptedKey Cookie matches its value in the WebEncryptedKeys table.
		// If so, add 16 to BinaryCounter.
		if($EncryptedKeySQLValue == $EncryptedKey) { $BinaryCounter += 16; }
	}
	return $BinaryCounter;
}

function GetStatusResult($BinaryCounter)
{
	$ReturnValue = 0;
	switch ($BinaryCounter)
	{
		case 0:
			// DONE: User has no cookie values stored on their computer. They need to go to the Website Clinic.
			$ReturnValue = 0;
			break;
		case 1:
			// User only has Employee ID Cookie. We nuke the user and EncryptedKey cookie values and re-register.
			$ReturnValue = 1;
			break;
		case 2:
			// User was once registered. We nuke the user and EncryptedKey cookie values and re-register.
			$ReturnValue = 2;
			break;
		case 3:
			// User was once registered. We nuke the user and EncryptedKey cookie values and re-register.
			$ReturnValue = 3;
			break;
		case 4:
			// This situation will never happen as that means there would be a row in the WebNewUsers table with a EmpID value of 'Empty'.
			$ReturnValue = 4;
			break;
		case 5:
			// User is registered but EncryptedKey key is empty. User visits 
			$ReturnValue = 5;
			break;
		case 6:
			// User was never registered before.
			$ReturnValue = 6;
			break;
		case 7:
			// User was at one time registered but the WebEncryptedKeys entry is missing an entry. Re-Register.
			$ReturnValue = 7;
			break;
		case 8:
			// User was at one time registered but the cookies is missing. Re-Register.
			$ReturnValue = 8;
			break;
		case 9:
			// User was at one time registered but the EncryptedKey cookie is missing. Re-Register.
			$ReturnValue = 9;
			break;
		case 10:
			// User was at one time registered but the user cookie is missing and Encrypted key pair does not match. Re-Register.
			$ReturnValue = 10;
			break;
		case 11:
			// User was at one time registered but the WebNewUsers entry is missing an entry. Re-Register.
			$ReturnValue = 11;
			break;
		case 12:
			// DONE: User is registered but both cookies are missing. Go to reset client link.
			$ReturnValue = 12;
			break;
		case 13:
			// Done: User is registered but EncryptedKey cookie is missing. Go to reset client link and use code to re-write Encrypted key. 
			$ReturnValue = 13;
			break;
		case 14:
			// DONE: User is registered but user cookie is missing and Encrypted key pair does not match. Go to reset client link.
			$ReturnValue = 14;
			break;
		case 15:
			// DONE: User is fully registered but the Encrypted key pair does not match. Go to reset client link.
			$ReturnValue = 15;
			break;
		case 24:
			// User is registered correctly. user and EncryptedKey Cookies are missing. Go to reset client link.
			$ReturnValue = 24;
			break;
		case 25:
			// User is registered correctly. EncryptedKey Cookie is missing. Go to reset client link.
			$ReturnValue = 25;
			break;
		case 26:
			// User is registered correctly. user Cookie is missing. Go to reset client link.
			$ReturnValue = 26;
			break;
		case 27:
			// User was never registered before.
			$ReturnValue = 27;
			break;
		case 28:
			// User was never registered before.
			$ReturnValue = 28;
			break;
		case 29:
			// User was never registered before.
			$ReturnValue = 29;
			break;
		case 30:
			// DONE: Only Employee ID missing. Go to Website Clinic and have Employee ID Cookie re-written to laptop.
			$ReturnValue = 30;
			break;
		case 31:
			// Done: User is fully registered and running OK. Display message that user is already registered.
			$ReturnValue = 31;
			break;
	}
	return $ReturnValue;
}
/*
********************************************************************
*                 End Function Defination Section                  *
******************************************************************** */

/*
********************************************************************
*                       Main Processing Area                       *
******************************************************************** */
list($EmpID,$LastName,$FirstName,$EncryptedKeySQLValue) = GetAssociateSQLDetails($user);
$StatusCode = CalculateStatusCode($user,$EncryptedKey,$EmpID,$LastName,$FirstName,$EncryptedKeySQLValue);
$StatusResult = GetStatusResult($StatusCode);
print "$StatusResult";

?>
