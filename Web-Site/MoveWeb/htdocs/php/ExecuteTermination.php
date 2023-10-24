<?php
/*
				Program Name: ExecuteTermination.php
				Date Written: May 8th, 2023
					Written By: Dave Jaynes
	Function Called By: ExecuteTermination()
						 Purpose: Executes the DisablePersonAdHoc_UniversalAccountsOnly SQL Stored Procedure
											which disables the universal.co accounts linked to the 'AssocID' field.
*/

include("ProdDBWebConnection.php");
$AssocID = $_POST['AssocID'];
// $sql = "exec DisablePersonAdHoc_UniversalAccountsOnly $AssocID; WAITFOR DELAY '00:00:02';exec msdb.dbo.sp_start_job N'IDM - AD-Adhoc Account Provisioning - DIS/SDIS'";
// odbc_exec($conn,$sql);
?>