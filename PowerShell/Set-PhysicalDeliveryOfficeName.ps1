<#
		Program Name: Set-PhysicalDeliveryOfficeName.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Updates AD with the proper listing of Unique Location Codes where they are currently blank/missing. 
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$all = get-aduser -filter {(enabled -eq $true) -and ((extensionAttribute4 -like "human") -or (extensionAttribute4 -like "*|*") -or (extensionAttribute4 -like "*|"))} -Properties physicalDeliveryOfficeName

#Get users with blank location code and assign based on OU membership
$blank = $all | Where-Object {($_.physicalDeliveryOfficeName -notlike "*") -or ($_.physicalDeliveryOfficeName -eq $null)}

foreach ($human in $blank) {
    $GUID = $human.objectGUID.GUID
    $DN = $human.DistinguishedName

    if ($DN -like "*OU=B3NJ*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Berkeley Heights-NJ-USA";}}
    elseif ($DN -like "*OU=BFCO*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Broomfield-CO-USA";}}
    elseif ($DN -like "*OU=BHNJ*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Berkeley Heights-NJ-USA";}}
    elseif ($DN -like "*OU=BUON*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Burlington-ON-CAN";}}
    elseif ($DN -like "*OU=CAMA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Cambridge-MA-USA";}}
    elseif ($DN -like "*OU=CHIL*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Chicago-IL-USA";}}
    elseif ($DN -like "*OU=CHMO*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Chesterfield-MO-USA";}}
    elseif ($DN -like "*OU=CIOH*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Mason-OH-USA";}}
    elseif ($DN -like "*OU=CPIL*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Champaign-IL-USA";}}
    elseif ($DN -like "*OU=DTPA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Doylestown-PA-USA";}}
    elseif ($DN -like "*OU=EMCA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Emeryville-CA-USA";}}
    elseif ($DN -like "*OU=FOCA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Fontana-CA-USA";}}
    elseif ($DN -like "*OU=IRCA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Irvine-CA-USA";}}
    elseif ($DN -like "*OU=LACA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Los Angeles-CA-USA";}}
    elseif ($DN -like "*OU=LOUK*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="London-GBR";}}
    elseif ($DN -like "*OU=METN*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Memphis-TN-USA";}}
    elseif ($DN -like "*OU=MIWI*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Milwaukee-WI-USA";}}
    elseif ($DN -like "*OU=NYNY*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="New York-NY-USA";}}
    elseif ($DN -like "*OU=PUIN*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="India";}}
    elseif ($DN -like "*OU=SCAZ*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Scottsdale-AZ-USA";}}
    elseif ($DN -like "*OU=SDCA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="San Diego-CA-USA";}}
    elseif ($DN -like "*OU=SFCA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="San Francisco-CA-USA";}}
    elseif ($DN -like "*OU=SGSG*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Singapore-SGP";}}
    elseif ($DN -like "*OU=SONJ*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Somerset-NJ-USA";}}
    elseif ($DN -like "*OU=SPIL*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Springfield-IL-USA";}}
    elseif ($DN -like "*OU=SSNY*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Saratoga Springs-NY-USA";}}
    elseif ($DN -like "*OU=SYNS*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Sydney-NS-CAN";}}
    elseif ($DN -like "*OU=TOJA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Tokyo-JPN";}}
    elseif ($DN -like "*OU=WAPA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Wayne-PA-USA";}}
    elseif ($DN -like "*OU=WRCO*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Wheat Ridge-CO-USA";}}
    elseif ($DN -like "*OU=YAPA*") {set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Yardley-PA-USA";}}
}

#Fix Incomplete Location Codes
$BFCO = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Broomfield-CO"}
foreach ($human in $BFCO) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Broomfield-CO-USA";}
}

$BHNJ = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Berkeley Heights-NJ"}
foreach ($human in $BHNJ) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Berkeley Heights-NJ-USA";}
}

$BUON = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Burlington-ON"}
foreach ($human in $BUON) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Burlington-ON-CAN";}
}

$CAMA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Cambridge-MA"}
foreach ($human in $CAMA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Cambridge-MA-USA";}
}

$CHIL = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Chicago-IL"}
foreach ($human in $CHIL) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Chicago-IL-USA";}
}

$CHMO = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Chesterfield-MO"}
foreach ($human in $CHMO) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Chesterfield-MO-USA";}
}

$CIOH = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "BusinessWay-OH"}
foreach ($human in $CIOH) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="BusinessWay-OH-USA";}
}

$CIOH2 = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Cornell Park-OH"}
foreach ($human in $CIOH2) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Cornell Park-OH-USA";}
}

$CIOH3 = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Mason-OH"}
foreach ($human in $CIOH3) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Mason-OH-USA";}
}

$CPIL = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Champaign-IL"}
foreach ($human in $CPIL) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Champaign-IL-USA";}
}

$CSCA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Client Sites-CA"}
foreach ($human in $CSCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Client Sites-CA-USA";}
}

$CSFL = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Client Sites-FL"}
foreach ($human in $CSFL) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Client Sites-FL-USA";}
}

$CSNJ = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Client Sites-NJ"}
foreach ($human in $CSNJ) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Client Sites-NJ-USA";}
}

$CSPA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Client Sites-PA"}
foreach ($human in $CSPA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Client Sites-PA-USA";}
}

$DTPA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Doylestown-PA"}
foreach ($human in $DTPA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Doylestown-PA-USA";}
}

$EMCA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Emeryville-CA"}
foreach ($human in $EMCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Emeryville-CA-USA";}
}

$FOCA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Fontana-CA"}
foreach ($human in $FOCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Fontana-CA-USA";}
}

$IRCA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Irvine-CA"}
foreach ($human in $IRCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Irvine-CA-USA";}
}

$LACA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Los Angeles-CA"}
foreach ($human in $LACA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Los Angeles-CA-USA";}
}

$LOUK = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "London"}
foreach ($human in $LOUK) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="London-GBR";}
}

$METN = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Memphis-TN"}
foreach ($human in $METN) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Memphis-TN-USA";}
}

$MIWI = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Milwaukee-WI"}
foreach ($human in $MIWI) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Milwaukee-WI-USA";}
}

$NYNY = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "New York-NY"}
foreach ($human in $NYNY) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="New York-NY-USA";}
}

$Other = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Other"}
foreach ($human in $Other) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -clear physicalDeliveryOfficeName
}

$PACA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Palo Alto-CA"}
foreach ($human in $PACA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Palo Alto-CA-USA";}
}

$PRNJ = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Princeton-NJ"}
foreach ($human in $PRNJ) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Princeton-NJ-USA";}
}

$PUIN = $all | Where-Object {($_.physicalDeliveryOfficeName -eq "Pune-India") -or ($_.physicalDeliveryOfficeName -eq "Pune-IN") -or ($_.physicalDeliveryOfficeName -eq "Mumbai-India")-or ($_.physicalDeliveryOfficeName -eq "Mumbai")}
foreach ($human in $PUIN) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="India";}
}

$Remote = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Remote"}
foreach ($human in $Remote) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -clear physicalDeliveryOfficeName
}

$SCAZ = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Scottsdale-AZ"}
foreach ($human in $SCAZ) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Scottsdale-AZ-USA";}
}

$SDCA = $all | Where-Object {($_.physicalDeliveryOfficeName -eq "San Diego-CA") -or ($_.physicalDeliveryOfficeName -like "San Diego-CA-USA*")}
foreach ($human in $SDCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="San Diego-CA-USA";}
}

$SFCA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "San Francisco-CA"}
foreach ($human in $SFCA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="San Francisco-CA-USA";}
}

$Singapore = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Singapore"}
foreach ($human in $Singapore) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Singapore-SGP";}
}

$SONJ = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Somerset-NJ"}
foreach ($human in $SONJ) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Somerset-NJ-USA";}
}

$SPIL = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Springfield-IL"}
foreach ($human in $SPIL) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Springfield-IL-USA";}
}

$SSNY = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Saratoga Springs-NY"}
foreach ($human in $SSNY) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Saratoga Springs-NY-USA";}
}

$SYNS = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Sydney-NS"}
foreach ($human in $SYNS) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Sydney-NS-CAN";}
}

$Tokyo = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Tokyo"}
foreach ($human in $Tokyo) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Tokyo-JPN";}
}

$WAPA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Wayne-PA"}
foreach ($human in $WRCO) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Wayne-PA-USA";}
}

$WRCO = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Wheat Ridge-CO"}
foreach ($human in $WRCO) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Wheat Ridge-CO-USA";}
}

$YAPA = $all | Where-Object {$_.physicalDeliveryOfficeName -eq "Yardley-PA"}
foreach ($human in $YAPA) {
    $GUID = $human.ObjectGUID.GUID
    set-aduser -identity $GUID -replace @{physicalDeliveryOfficeName="Yardley-PA-USA";}
}