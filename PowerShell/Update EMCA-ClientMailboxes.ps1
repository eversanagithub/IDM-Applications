<#
		Program Name: Update_EMCA-ClientMailboxes.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Adds EMCA Client Mailboxes to Active Directory. 
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ou = "OU=Client Mailboxes,OU=EMCA,OU=Resources,DC=Universal,DC=co"
$group = "CN=EMCA-ClientMailboxes,OU=Groups,OU=EMCA,OU=Users and Workstations,DC=Universal,DC=co"
$emca_client_mailboxes = get-aduser -filter * -searchscope subtree -SearchBase $ou
$emca_client_mailboxes | %{
	Add-ADGroupMember -Identity $group -Members $_ #-WhatIf
}