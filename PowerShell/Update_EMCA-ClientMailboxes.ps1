$ou = "OU=Client Mailboxes,OU=EMCA,OU=Resources,DC=Universal,DC=co"
$group = "CN=EMCA-ClientMailboxes,OU=Groups,OU=EMCA,OU=Users and Workstations,DC=Universal,DC=co"

$emca_client_mailboxes = get-aduser -filter * -searchscope subtree -SearchBase $ou

$emca_client_mailboxes | %{
    Add-ADGroupMember -Identity $group -Members $_ #-WhatIf
}