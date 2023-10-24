<?php
/*
	Program Name: KickOffPromotion.php
	Date Written: July 18th, 2023
	Written By: Dave Jaynes
	Purpose: Kicks off the C:\Apache24\Utilities\PromoteToProd.exe 
           script which launches the web code promotion process.
*/
$answer = shell_exec("C:/Apache24/Utilities/PromoteToProd.exe");
?>
