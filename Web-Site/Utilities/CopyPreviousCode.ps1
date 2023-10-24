# This code lives on the IDMGMTAPP01 production server.

function CopyCurrentCode    
{
	param(
		[string]$Source,
		[string]$Destination
	)  
	Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}

CopyCurrentCode -Source 'C:\Apache24\cgi-bin\*' -Destination 'C:\Apache24\PreviousCode\cgi-bin'
CopyCurrentCode -Source 'C:\Apache24\htdocs\*' -Destination 'C:\Apache24\PreviousCode\htdocs'
