#Author: Gregory Warner
#Last Modified: 10/22/19
#Summary: Mark New Human Users
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Get Unmarked Users
$NewUsers = get-aduser -filter {(extensionAttribute4 -notlike "*") -and (userPrincipalName -like "*.*@*.com") -and (GivenName -like "*") -and (Surname -like "*") -and (Enabled -eq $true)}

#Mark Valid Users
foreach ($User in $NewUsers) {
    $GUID = $User.ObjectGUID.GUID
    $DN = $User.DistinguishedName
    #if ($DN -like "*OU=People*" -or $DN -like "*OU=Contractors*") {
        set-aduser -identity $GUID -replace @{extensionAttribute4='human';}
    #}
}