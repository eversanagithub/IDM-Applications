<?php

/*
        Program Name: DisplayADACHTMLResponse.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateADACHTMLResponse() function
             Purpose: This php script is called by the 'ODD_Search_Settings.pl' perl script
					  when displaying the contents of the 'ADACMenuOutput.txt' file to the screen.
*/

// Identify the file name used to display to the screen.
$ADACOutput = "C:/apache24/htdocs/php/ADACMenuOutput.txt";
$myfile = fopen($ADACOutput, "r") or die("Unable to open file!");
echo fread($myfile,filesize($ADACOutput));
fclose($myfile);
?>
