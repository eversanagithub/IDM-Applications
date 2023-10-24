<#
		Program Name: Update-ServiceNow_Approver.ps1
		Date Written: February 21st, 2023
			Written By: Dave Jaynes
		 Description: Add all managers to the "ServiceNow Approver" Security Group. 
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Designate group GUID for ServiceNow_Approvers group
$groupGUID = "3f75b166-de99-4979-903a-698c0a38ae36"
# Get all group members
$groupMembers = Get-ADGroupMember -Identity $groupGUID
<#
GroupMembers will give you multiple listing of which below is an example of just one
------------------------------------------------------------------------------------
distinguishedName      : CN=Bill O'Bryon,OU=People,OU=SSNY,OU=Users and Workstations,DC=Universal,DC=co
name                   : Bill O'Bryon
objectClass            : user
objectGUID             : db423d7a-cad7-4e9f-82b2-e71daffff4ed
SamAccountName         : bill.obryon
SID                    : S-1-5-21-434181118-4213564157-2669733258-6286
WriteDebugStream       : {}
WriteErrorStream       : {}
WriteInformationStream : {}
WriteVerboseStream     : {}
WriteWarningStream     : {}
#>

# Get users that are marked as a manager in extensionAttribute9
$managers = Get-ADUser -filter {(enabled -eq $true) -and (extensionAttribute9 -eq "Yes") -and (extensionAttribute4 -eq "human" -or extensionAttribute4 -like "*|*" -or extensionAttribute4 -like "*|")} -properties directReports

<#
Manager will give you multiple listing of which below is an example of just one.
--------------------------------------------------------------------------------
directReports          : {CN=Allan Siongco,OU=People,OU=SSNY,OU=Users and Workstations,DC=Universal,DC=co, CN=Anton Ivanov,OU=People,OU=YAPA,OU=Users and Workstations,DC=Universal,DC=co, CN=Brandy Buhl,OU=People,OU=SSNY,OU=Users and Workstations,DC=Universal,DC=co,
                         CN=Jonathan Snyder,OU=People,OU=SSNY,OU=Users and Workstations,DC=Universal,DC=co...}
DistinguishedName      : CN=Bill O'Bryon,OU=People,OU=SSNY,OU=Users and Workstations,DC=Universal,DC=co
Enabled                : True
GivenName              : Bill
Name                   : Bill O'Bryon
ObjectClass            : user
ObjectGUID             : db423d7a-cad7-4e9f-82b2-e71daffff4ed
SamAccountName         : bill.obryon
SID                    : S-1-5-21-434181118-4213564157-2669733258-6286
Surname                : O'Bryon
UserPrincipalName      : bill.obryon@eversana.com
WriteDebugStream       : {}
WriteErrorStream       : {}
WriteInformationStream : {}
WriteVerboseStream     : {}
WriteWarningStream     : {}
#>

# Sort all current managers into arrays
$managersWithReports = @()
$managersWithOnlyInactiveReports = @()
$managersWithoutReports = @()

# Now we will walk through all the $managers rows looking for direct reports.
# In the example listing above, we can see Bill O'Bryon has several direct reports.
# We will also be looking for managers who did at one time have direct reports, but 
# due to people leaving the company, those people are now inactive (They don't work here anymore).
foreach ($manager in $managers)
{
	$reports = ''
	$reports = $manager.directReports
	$reportsCount = ''
	$reportsCount = ($reports).count

	if ($reportsCount -gt 0)
	{
		$check = $false
		foreach ($report in $reports)
		{
			$reportDetails = ''
			$reportDetails = get-aduser $report
			
			# Found a direct report. But is that employee active?
			if ($reportDetails.Enabled -eq $true)
			{
				$check = $true
			}
		}
		if ($check -eq $true)
		{
			# Add manager name with direct reports to the collection.
			$managersWithReports += $manager
		}
		else
		{
			# Manager did have any direct reports but they are now inactive.
			# We will add them to the manager with only inactive reports array.
			$managersWithOnlyInactiveReports += $manager
		}
	}
	else
	{
		# Found no direct reports for this manager so add them to the No direct reports array.
		$managersWithoutReports += $manager
	}
}

$managersWithoutReports = $managersWithoutReports.ObjectGUID.GUID
$managersWithOnlyInactiveReports = $managersWithOnlyInactiveReports.ObjectGUID.GUID

# So basically what we are doing here is removing managers from the ServiceNow_Approvers group
# if they do not have any direct reports ... hense they have nobody to approve for.
$remove = 0
foreach ($groupMember in $groupMembers)
{
	$GUID = ''
	$GUID = $groupMember.ObjectGUID.GUID

	# Here we check the ServiceNow_Approvers group GUID listing to see if any of these
	# GUIDs belong to the managers without direct reports. If so, we will remove them.
	# We periodically need to perform this action as folks come and go into the company
	# who were/or will become direct reports to the managers.
	if (($managersWithoutReports -contains $GUID) -or ($managersWithOnlyInactiveReports -contains $GUID))
	{
		Remove-ADGroupMember -Identity $groupGUID -Members $GUID -Confirm:$false
	}
}

$groupMembers = $groupMembers.ObjectGUID.GUID

# Here we are doing the exact opposite, that being adding managers to the ServiceNow_Approvers group
# if they are not currently listed in that group ... hense they do have direct reports to approve for.
$add = 0
foreach ($managerWithReports in $managersWithReports)
{
	$GUID = ''
	$GUID = $managerWithReports.ObjectGUID.GUID
	if ($groupMembers -notcontains $GUID)
	{
		Add-ADGroupMember -Identity $groupGUID -Members $GUID -Confirm:$false
	}
}

<#
Summary: So what we have done is basically a daily maintenance activity to add or remove
				 managers to/from the ServiceNow_Approvers group depending if they have active
				 direct reports or not.
#>