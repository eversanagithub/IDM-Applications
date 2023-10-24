function setCookie(cname,cvalue,exdays) {
  const d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  let expires = "expires=" + d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function deleteCookie(cname,cvalue,exdays) {
  const d = new Date();
  d.setTime(d.getTime() - (60000));
  let expires = "expires=" + d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function checkCookie(CookieID) {
	let msg = "";
	let user = getCookie(CookieID);
	if (user != "") 
	{
		msg = "Cookie " + CookieID + " exists.";
	} else {
		msg = "Cookie " + CookieID + " exists.";
	}
	let output = '';
	output2 = "<table border=0 style='width:100%'>";
	output3 = "<tr><td align='center'>";
	output4 = '<input id="Submit" name="Submit" value="' . $Value . '" type="image" src="' . $Image . '" width="' . $Width . '" height="' . $Height . '" align="middle" border="0" onMouseOver="' . $Description . '();" onMouseLeave="MainTopDisplay();" onClick=' . "'" . 'SetShowDescriptionsOff();' . $FunctionName . '(id=' . '"' . $FunctionID . '"' . ');' . $SubmitFunction . '();' . "'" . '>';
	output5 = "</td></tr>";
	output6 = "</table>";
	output7 = "</FORM>";
    output8 = "<br>";
	// output = output1 . "\n" . output2 . "\n" . output3 . "\n" .  output4 . "\n" .  output5 . "\n" .  output6 . "\n" .  output7. "\n" .  output8;
	output = output1 . output2 . output3 . output4 . output5 . output6 . output7. output8;
	document.getElementById('EmpIDResult').innerHTML = Link;
}
