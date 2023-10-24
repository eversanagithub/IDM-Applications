$Date = Invoke-Sqlcmd -ServerInstance iuatidmgmtsql01.universal.co -Database IAM -Query "select HR.Hire_dt from dbo.HR_Trx HR inner join dbo.Feed_AD_Azure AD on HR.AssociateID = AD.employeeNumber where AD.UPN = 'dave.jaynes@eversana.com' ORDER BY HR.Hire_dt OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY"
foreach($tmpDate in $Date)
{
	$A = $tmpDate.ItemArray;
}
$B = [DateTime]"2020-01-01"
Write-host "Comparing $A to $B"
if($A -lt $B) { Write-Host "Earlier" } else { Write-Host "Later" }