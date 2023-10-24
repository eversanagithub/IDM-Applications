<?php

/*
        Program Name: WhoAmI.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: topSideBar.html file.
             Purpose: Sets the current user in the WebWhoAmI table so Perl scripts knows who the curent user is.
*/

include("DBWebConnection.php");

$user = $_POST['user'];
$sql = "update WebWhoAmI set WhoAmI = '$user'";
odbc_exec($conn,$sql);
?>
