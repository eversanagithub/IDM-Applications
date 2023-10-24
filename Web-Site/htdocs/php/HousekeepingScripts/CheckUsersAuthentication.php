<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: CheckUsersAuthentication.php                                                                |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: Checks the authentication setting on the user's browser against the registration tables.    |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");

$role = '';
$FinalOutput = '';
$Count = '';

$user = $_POST['user'];
$EncryptedKey = $_POST['EncryptedKey'];

//$user = "103257";
//$EncryptedKey = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000008abb3dcdf68241449ae2782b47a062d50000000002000000000003660000c000000010000000b48036b878c8d5a44cd7fa93df6798440000000004800000a0000000100000004af0dbe6719358dbd6fbdbc0851ac30f18000000afff5542103cf079bd4512e1c2d7f125f09678267476035414000000ed4cd3cc6236437b549c3b6fd213a36f85f80ed0";

/*
			Based on the return value from CheckUsersAuthentication function, here are the possible result codes:
			
			Code									Defination of Code
			----	---------------------------------------------------------------------------------------------
			  0     User has no cookies stored on their computer. They need to go to the Website Clinic.
			  1		User has the Employee ID cookie on their computer but no Encrypted cooke. Website Clinic.
			  2		User has the Encrypted cookie on their computer but no Employee ID cooke. Website Clinic.
			  3		User has both cookies on their laptop but are not present in the system. Website Clinic.
			  5		User is partically registered (Only in WebNewUsers table) and has no Encrypted cooke. Website Clinic.
			  7		User is registered but their is no entry in the WebEncryptedKeys table. Website Clinic.
			  9		User has Employee ID cooke but no Encrypted cookie. They are only in the WebEncryptedKeys table. Website Clinic.
			 15		User is registered but Encrypted cooke value does not match that in the WebEncryptedKeys table. Website Clinic.
			 31		User is completely registered correctly but access has been administratively been restricted by the Housekeeping website.
			 63		All systems Go! The user is good to access the application.

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

	// Test if the WebEncryptedKeys table has an entry for the Employee ID.
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
	}
	
	// Check to see if the locally stored encryption key matches the one in the WebEncryptedKeys table. 
	$sql="select EncryptedKey from WebEncryptedKeys where EmpID = '$EmpID';";
	$rs=odbc_exec($conn,$sql);
	$StoredEncryptedKey = odbc_result($rs,"EncryptedKey");
	if($StoredEncryptedKey == $EncryptedKey)
	{
		$BinaryCounter += 16;
	}
	
	// Has the user's access been restricted by the admin?
	$sql="select Authorized from WebNewUsers where EmpID = '$EmpID';";
	$rs=odbc_exec($conn,$sql);
	$Authorized = odbc_result($rs,"Authorized");
	if($Authorized != 'No')
	{
		$BinaryCounter += 32;
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
			// All tokens are ok but users access has been restricted by Housekeeping web site.
			$ReturnValue = 31;
			break;
		case 63:
			// Done: User is fully registered and running OK. Display message that user is already registered.
			$ReturnValue = 63;
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
