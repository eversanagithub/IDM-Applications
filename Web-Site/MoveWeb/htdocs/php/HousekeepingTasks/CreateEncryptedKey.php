<?php

/*
        Program Name: CreateEncryptedKey.php
        Date Written: June 1st, 2023
          Written By: Dave Jaynes
  Function Called By: RegisterNewUser() (In the SetCookie_functions.js file).
             Purpose: Passes the EmpID variable value to the CreateEncryptedKey.exe script
					  which in turn creates the new encrypted and decrypted key values and
					  then inserts them into the WebEncryptedKeys SQL table.
*/

include("ProdDBWebConnection.php");
$EmpID = $_POST['EmpID'];
$CreateEncryptedKey = "c:/Apache24/cgi-bin/CreateEncryptedKey.exe";
shell_exec("$CreateEncryptedKey $EmpID");
?>