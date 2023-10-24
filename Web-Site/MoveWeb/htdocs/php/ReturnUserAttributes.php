<?php

/*
----------------------------------------------------------------------------------------------------------------
|     Script Name: ReturnUserAttributes.php                                                                    |
|       Called By: Various JavaScript functions which need the current users attributes.                       |
|    Initial Code: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|         Purpose: Retrieves users attributes from the 'IDM_Website_Profile' SQL table based on the current    |
|                  users 'WebPageDTG' Local Storage variable.                                                  |
|--------------------------------------------------------------------------------------------------------------- */

include("ProdDBWebConnection.php");
$BeginJSONHeader = '{ "UserAttributes" : [';
$EndingJSONHeader = ' ]}';
$JsonQuery = '';
$RunningJsonQuery = '';
$update = '';
$Count = '';
$InstanceUser = $_POST['InstanceUser'];
// $InstanceUser = '20230419150218';

// Format each row of SQL returns into JSON formatted text.
function get_item_html($item1,$item2,$item3,$item4,$item5)
{
    $output = '';
    $output = '{ "'
    . "lastName"
    . '":"'
    . $item1
    . '", '
    . '"'
    . "firstName"
    . '":"'
    . $item2
    . '", '
    . '"'
    . "userID"
    . '":"'
    . $item3
    . '", '
    . '"'
    . "IDActive"
    . '":"'
    . $item4
    . '", '
    . '"'
    . "loginDTG"
    . '":"'
    . $item5
    . '"'
    . " }";
    return $output;
}

// Get record count
$CountNumRecords = "select count(*) from WebAdminPortalLoginDetails where webUserDTG = '$InstanceUser';";
$rs = odbc_exec($conn,$CountNumRecords);
odbc_fetch_row($rs);
$NumRecords = odbc_result($rs,$Count);

$sql="select * from WebAdminPortalLoginDetails where webUserDTG = '$InstanceUser';";
$rs=odbc_exec($conn,$sql);
if (!$rs)
  {exit("Error in SQL");}
$Counter = 0;
while (odbc_fetch_row($rs))
{
	$lastName = odbc_result($rs,"lastName");
	$firstName = odbc_result($rs,"firstName");
	$userID = odbc_result($rs,"userID");
	$IDActive = odbc_result($rs,"IDActive");
	$loginDTG = odbc_result($rs,"loginDTG");

	$thisRow = get_item_html($lastName,$firstName,$userID,$IDActive,$loginDTG);
	$Counter++;
	if($Counter < $NumRecords)
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow . ', ';
	}
	else
	{
		$RunningJsonQuery = $RunningJsonQuery . $thisRow;
	}
}

$JSONData = $BeginJSONHeader . $RunningJsonQuery . $EndingJSONHeader;
print "$JSONData";
odbc_close($conn);
?>
