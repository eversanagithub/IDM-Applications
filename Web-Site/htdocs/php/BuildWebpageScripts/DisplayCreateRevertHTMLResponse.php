<?php

/*
        Program Name: DisplayCreateRevertHTMLResponse.php
        Date Written: July 17th, 2023
          Written By: Dave Jaynes
  Function Called By: CreateADACHTMLResponse() function
             Purpose: This php script is called by the 'CreatepromoteHTMLResponse.pl' perl script
                      when displaying the contents of the 'PromoteScriptOutput.txt' file to the screen.
*/

// Identify the file name used to display to the screen.
$PromoteOutput = "C:/apache24/htdocs/php/WebsiteTextOutputFiles/RevertScriptOutput.txt";
$myfile = fopen($PromoteOutput, "r") or die("Unable to open file!");
echo fread($myfile,filesize($PromoteOutput));
fclose($myfile);
?>
