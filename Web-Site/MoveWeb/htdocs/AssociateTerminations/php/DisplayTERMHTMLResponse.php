<?php

/*
        Program Name: DisplayODDHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateODDHTMLResponse() function
             Purpose: This php script is called by the 'ODD_Search_Settings.pl' perl script
					  when displaying the contents of the 'ODDMenuOutput.txt' file to the screen.
*/

// Identify the file name used to display to the screen.
$ODDOutput = "C:/apache24/htdocs/php/TERMMenuOutput.txt";
$myfile = fopen($ODDOutput, "r") or die("Unable to open file!");
echo fread($myfile,filesize($ODDOutput));
fclose($myfile);
?>