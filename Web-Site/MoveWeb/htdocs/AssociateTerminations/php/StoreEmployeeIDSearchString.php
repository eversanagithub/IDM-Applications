<?php
/*
				Program Name: StoreEmployeeIDSearchString.php
				Date Written: Jane 6th, 2023
					Written By: Dave Jaynes
	Function Called By: ExecuteTermination()
						 Purpose: Executes the DisablePersonAdHoc_UniversalAccountsOnly SQL Stored Procedure
											which disables the universal.co accounts linked to the 'AssocID' field.
*/

include("ProdDBWebConnection.php");
$EmpID = $_POST['EmpID'];
$SrchAssocID = $_POST['SrchAssocID'];

// This will store the latest employee ID search string when looking for employees to terminate.
$sql = "update WebSearchFields set srchAssocID = '$SrchAssocID' where EmpID = '$EmpID'";
odbc_exec($conn,$sql);

// This will tell the ProcessTermination.pl script who the last user was that selected a record for deletion.
$sql = "update WebWhoAmI set WhoAmi = '$EmpID'";
odbc_exec($conn,$sql);

odbc_close($conn);
?>