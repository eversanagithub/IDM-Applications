<?php

/*
        Program Name: LogInitialVisit.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: topSideBar.html file.
             Purpose: Log initial entries for this web session into the WebAdminPortalLoginDetails SQL table.
*/

include("ProdDBWebConnection.php");
$webUserDTG = $_POST['webUserDTG'];
$myDTG = $_POST['myDTG'];
$userID = $_POST['userID'];
$lastName = $_POST['lastName'];
$firstName = $_POST['firstName'];
$IDActive = $_POST['IDActive'];
$loginAttempt = $_POST['loginAttempt'];
$loginDTG = $_POST['loginDTG'];
$sql = "insert into WebAdminPortalLoginDetails(webUserDTG,userID,lastName,firstName,IDActive,adminPortalLoginAttempt,loginDTG) values ('$webUserDTG','$userID','$lastName','$firstName',$IDActive,'$loginAttempt','$loginDTG')";
odbc_exec($conn,$sql);
$sql = "insert into WebSearchFields(webUserDTG,srchAssocID) values ('$webUserDTG','000000')";
odbc_exec($conn,$sql);
?>