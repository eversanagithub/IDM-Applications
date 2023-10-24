#Author: Chris Matute
#Last Modified: 06/18/2020
#Summary: Sets ext15 to flast format for all human users who have it set to first.last format
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function sam-to-flast($sam){
    $sam = $user.samaccountname
	$split = $sam.split(".")
	$f = ($split[0])[0]
	$last = $split[1]
	"$f$last"
}

$X = "15" #extension attribute number to be used for FLast formatting of name (cmatute)
$extshort = "ExtensionAttribute$X"

$users = get-aduser -filter {(ExtensionAttribute4 -like "*|*" -or ExtensionAttribute4 -eq "human") -and $extshort -like "*.*"} -Properties ExtensionAttribute4,$extshort

$users | %{

	$user = $_
	$legacy = $user.extensionattribute1
	$sam = $user.samaccountname

	$flast = sam-to-flast $sam

    #write-host $extshort
    
	set-aduser $sam -clear "$extshort" 
	set-aduser $sam -add @{ $extshort = $flast } 
}
