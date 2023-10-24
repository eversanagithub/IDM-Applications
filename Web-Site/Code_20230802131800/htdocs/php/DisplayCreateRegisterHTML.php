<?php

/*
        Program Name: DisplayCreateRegisterHTML.php
        Date Written: May 8th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateTERMHTMLResponse() function
             Purpose: This php script is called by the 'ODD_Search_Settings.pl' perl script
					  when displaying the contents of the 'ODDMenuOutput.txt' file to the screen.
*/

// Identify the file name used to display to the screen.
$RegisterOutput = "C:/apache24/htdocs/php/RegisterHTMLOutput.txt";
$myfile = fopen($RegisterOutput, "r") or die("Unable to open file!");
echo fread($myfile,filesize($RegisterOutput));
fclose($myfile);
?>
