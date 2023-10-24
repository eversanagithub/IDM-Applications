<?php

/*
        Program Name: PullApplicationPath.php
        Date Written: October 14th, 2023
          Written By: Dave Jaynes
             Purpose: Returns application file location for given application.
*/

include("DBWebConnection.php");

# Assign posting to variables.
$application = $_POST['application'];

// Pull application location
$sql="select * from WebAdminPortalApplicationURL where application = '$application';";
$rs=odbc_exec($conn,$sql);
$appLocation = odbc_result($rs,"appLocation");
print "$appLocation";
?>
