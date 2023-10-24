$Phone = $args[0]
$Number = Get-Random -Minimum 100000 -Maximum 999999
$Message = "$Number%0aEnter this code to authenticate to the IDM website"
$Key = "11cf555d2fb9df50256882f3d3318d1d5a14edf6v5u0An6YaKYifBggmcvc7ZMa2"
$body = @{
	"phone"=$Phone
	"message"=$Message
	"key"=$Key
}
$submit = Invoke-WebRequest -Uri https://textbelt.com/text -Body $body -Method Post
Write-Host "$Number" -NoNewline