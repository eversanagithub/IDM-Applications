<?php

/*
        Program Name: DisplayRestoreWebsiteDataPage.php
        Date Written: July 14th, 2023
          Written By: Dave Jaynes
             Purpose: Prints out the HTML code to display the Restore Website Data page.
*/

// Identify the file name used to display to the screen.
$RestoreWebsiteDataPage = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/RestoreWebsiteDataPage.txt";
$myfile = fopen($RestoreWebsiteDataPage, "r") or die("Unable to open file!");
echo fread($myfile,filesize($RestoreWebsiteDataPage));
fclose($myfile);
?>
