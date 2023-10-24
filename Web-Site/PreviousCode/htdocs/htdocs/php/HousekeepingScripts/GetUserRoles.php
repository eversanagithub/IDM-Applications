<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: GetUserRoles.php                                                                            |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl                |
|         Purpose: This nifty script actually creates the application buttons in the Admin portal page.        |
|--------------------------------------------------------------------------------------------------------------- */

include("DBWebConnection.php");
$role = '';
$FinalOutput = '';

$EmplID = $_POST['EmplID'];

function FormLink($FunctionName,$FunctionID,$Value,$OnClick,$Image,$Width,$Height,$Description,$Call,$URL,$TARGET,$SubmitFunction)
{
	$output = '';
	$output1 = '<FORM id="' . $Call . '" METHOD="POST" ACTION="' . $URL . '" target="' . $TARGET . '">';
	$output2 = "<table border=0 style='width:100%'>";
	$output3 = "<tr><td align='center'>";
	$output4 = '<input id="Submit" name="Submit" value="' . $Value . '" type="image" src="' . $Image . '" width="' . $Width . '" height="' . $Height . '" align="middle" border="0" onMouseOver="' . $Description . '();" onMouseLeave="MainTopDisplay();" onClick=' . "'" . 'SetShowDescriptionsOff();' . $OnClick . '();' . $FunctionName . '(id=' . '"' . $FunctionID . '"' . ');' . $SubmitFunction . '();' . "'" . '>';
	$output5 = "</td></tr>";
	$output6 = "</table>";
	$output7 = "</FORM>";
    $output8 = "<br>";
	$output = $output1 . $output2 . $output3 . $output4 . $output5 . $output6 . $output7. $output8;
    return $output;
}

function RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction)
{
	include("DBWebConnection.php");
	$ApplicationOutput = '';
	$rs=odbc_exec($conn,$sql1);
	odbc_fetch_row($rs);
	$Result = odbc_result($rs,"role");
	if($Result == 'Yes')
	{
		$rs=odbc_exec($conn,$sql2);
		if (!$rs) {exit("Error in SQL");}
		while (odbc_fetch_row($rs))
		{
			$FunctionName  = odbc_result($rs,"FunctionName");
			$FunctionID  = odbc_result($rs,"FunctionID");
			$Value = odbc_result($rs,"Value");
			$OnClick = odbc_result($rs,"OnClick");
			$Image  = odbc_result($rs,"Image");
			$Width  = odbc_result($rs,"Width");
			$Height = odbc_result($rs,"Height");
			$ODDLink = FormLink($FunctionName,$FunctionID,$Value,$OnClick,$Image,$Width,$Height,$Description,$Call,$URL,$TARGET,$SubmitFunction);
		}
		$ApplicationOutput = $ApplicationOutput . $ODDLink;
		return $ApplicationOutput;
	}
}

// OneDriveDelegation
$sql1="select OneDriveDelegation as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'OneDriveDelegation';";
$Description = "ODD_Description";
$URL = "/cgi-bin/OneDriveDelegation/CreateODDHTMLResponse.pl";
$Call = "CallODDelegation";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitODDRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

// ADAccountCreation
$sql1="select ADAccountCreation as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'ADAccountCreation';";
$Description = "ADAC_Description";
$Call = "CallAcctCreation";
$URL = "/cgi-bin/ADAccountCreation/CreateADACHTMLResponse.pl";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitADACRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

// TerminateAssociate
$sql1="select TerminateAssociate as role from WebUserRoles where EmpID = '$EmplID';";
$sql2="select * from WebBuildSelectionButtons where FunctionID = 'TerminateAssociate';";
$Description = "BlueBlank_Description";
$Call = "CallTerminateAssociate";
$URL = "/cgi-bin/AssociateTerminations/CreateTERMHTMLResponse.pl";
$TARGET = "topmainpanel";
$SubmitFunction = "SubmitTERMRequest";
$ApplicationOutput = RunQueries($sql1,$sql2,$EmplID,$Description,$Call,$URL,$TARGET,$SubmitFunction);
$FinalOutput = $FinalOutput . $ApplicationOutput;

print "$FinalOutput";

odbc_close($conn);
?>
