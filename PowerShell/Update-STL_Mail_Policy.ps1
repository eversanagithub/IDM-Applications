<#
		Program Name: Update-STL_Mail_Policy.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Update the "STL Mail Policy" Security Group. 
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$STL_Mail_Policy_Group = "4b0b0732-f738-4028-b60f-2aad92cdd024"
#Get Unmarked Users
$Users = get-aduser -filter {Enabled -eq $True -and (extensionAttribute4 -eq "human" -or extensionAttribute4 -like "*|*" -or extensionAttribute4 -eq "*|")} | Where-Object {$_.DistinguishedName -like "*OU=CHMO*"}

#Mark Valid Users
foreach ($User in $Users) 
{
	$GUID = $User.ObjectGUID.GUID
	$DN = $User.DistinguishedName
	if ($DN -like "*OU=CHMO*") 
	{
		Add-ADGroupMember -Identity $STL_Mail_Policy_Group -Members $GUID -Confirm:$false
	}
}