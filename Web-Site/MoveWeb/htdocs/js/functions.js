/*
	This file holds all the functions for the IDM Website.
	It is broken down into nine sections, each one cooresponding
	to a different functionality of the website.
	These nine sections are:
	1. Global and pointer variables: Those variables used by one or more functions as well as URL/PHP file pointers.
	2. Global Functions: Those functions used by more than one application.
	3. Form Submitting Functions: Used for the onClick() calls to the cooresponding form submitting function.
	4. Main Page Applications: Those functions that support the main page.
	5. Admin Portal Applications: Those functions what support the Admin Portal page.
	6. Housekeeping Applications: Those functions used by webpage support.
	7. Register New Users Applications: These are special utility functions. (SetCookie_functions.js)
	8. Application Support Functions: Specialized functions assisting individual apps such as ODD. (AJAX_functions.js)
	9. Rollover Functions: Shows a description of the application at the top of the screen as the mouse cursor rolls over button.

*/

/*
===================================================================================================
|                           Section One: Global and pointer Variables                             |
===================================================================================================
*/
let applicationURL = "";
let IAMADMINPassword = '103257';
const PHPFileName = "http://idmgmtapp01/php/GetNewRegisteredUserInfo.php";
const getMainApplicationURLValues = "http://idmgmtapp01/php/BuildWebPageScripts/GetMainApplicationURLValues.php";
const GetAPApplicationLevelPHP = "http://idmgmtapp01/php/GetAdminPortalApplicationValues.php";
const GetAPApplicationURLValue = "http://idmgmtapp01/php/GetAdminPortalApplicationURL.php";
const getUserAttributes = "http://idmgmtapp01/php/ReturnUserAttributes.php";
const GetUserAccessLevelValue = "http://idmgmtapp01/php/GetUserAccessLevelValue.php";
const WhoAmIURL = "http://idmgmtapp01/php/WhoAmI.php";
const GetHKApplicationURLValues = "http://idmgmtapp01/php/BuildWebPageScripts/GetHousekeepingURLValues.php";
const ExecuteTerminationURL = "http://idmgmtapp01/php/ExecuteTermination.php";
const FormerAssociateDropDownListURL = "http://idmgmtapp01/OneDriveDelegation/php/InitialFormerAssociateDropDownList.php";
const BuildMainSelectionButtonsURL = "http://idmgmtapp01/php/BuildMainSelectionButtons.php";
const BuildAdminPortalSelectionButtonsURL = "http://idmgmtapp01/php/BuildAdminPortalSelectionButtons.php";
const BuildHousekeepingSelectionButtonsURL =  "http://idmgmtapp01/php/HousekeepingTasks/BuildHousekeepingSelectionButtons.php";
const CreateRegisterUserDropDownPHPFile = "http://idmgmtapp01/php/CreateRegisterUserDropDown.php";
const LoadTextTrackingTablePHPFile = "http://idmgmtapp01/php/LoadTextTrackingTable.php";
const DisplayTerminatedAccountsPHPFile = "http://idmgmtapp01/php/DisplayTerminatedAccounts.php";
const StoreEmployeeIDSearchStringPHPFile = "http://idmgmtapp01/AssociateTerminations/php/StoreEmployeeIDSearchString.php";
const InitialFormerAssociateDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/InitialFormerAssociateDropDownList.php";
const InitialRequesterDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/InitialRequesterDownList.php";
const UpdateFormerAssociateDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/UpdateFormerAssociateDropDownList.php";
const UpdateRequesterDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/UpdateRequesterDropDownList.php";
const StatusOfODDProgressPHPFile = "http://idmgmtapp01/php/StatusOfODDProgress.php";
const LocationNameDropDownListPHPFile = "http://idmgmtapp01/php/LocationNameDropDownList.php";
const RetrieveInitialEncryptedKey = "http://idmgmtapp01/php/HousekeepingTasks/RetrieveInitialEncryptedKey.php"
const CreateRegistrationPagePHPFile = "http://idmgmtapp01/php/CreateRegisterHTML.php";

/*
===================================================================================================
|                             Section Two: Global Functions                                       |
===================================================================================================
*/

const getCookie = (cname) => {
  let name = cname + "=";
  let ca = document.cookie.split(';');
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

const setCookie = (cname, cvalue, exdays) => {
  const d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  let expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

const GetNewRegisteredUserInfo = (EmpID,PHPFileName,returnRegisteredUserInfo) => {		
	let applicationURL = "";
	let getInfoParams = 'EmpID=' + EmpID;
	const requestRegisteredUserInfo = new XMLHttpRequest();
	requestRegisteredUserInfo.addEventListener('readystatechange', () => {
		if(requestRegisteredUserInfo.readyState === 4 && requestRegisteredUserInfo.status === 200) 
		{
			returnRegisteredUserInfo(requestRegisteredUserInfo.responseText);
		}
	});
	requestRegisteredUserInfo.open("POST", PHPFileName, true);
	requestRegisteredUserInfo.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestRegisteredUserInfo.send(getInfoParams);
}

// Initial setting of the function WebPageDTG variable
const SetWebPageDTGToZero = () => {
	localStorage.setItem('WebPageDTG','000');
}

const ResetTimer = (EmpID) => {
	var now = new Date();
	var year = now.getFullYear().toString();
	var mn1 = now.getMonth();
	mn1 = mn1 + 1;
	var mn = mn1.toString();
	if(mn.length == 1) { var month = '0' + mn; }else{ var month = mn; }
	var dy = now.getDate().toString();
	if(dy.length == 1) { var day = '0' + dy; }else{ var day = dy; }
	var hr = now.getHours().toString();
	if(hr.length == 1) { var hour = '0' + hr; }else{ var hour = hr; }
	var min = now.getMinutes().toString();
	if(min.length == 1) { var minute = '0' + min; }else{ var minute = min; }
	var sec = now.getSeconds().toString();
	if(sec.length == 1) { var second = '0' + sec; }else{ var second = sec; }
	var myDTG = year + '-' + month +  '-' + day + ' ' + hour + ':' + minute + ':' + second;
	var xhr = new XMLHttpRequest();
	var params = 'EmpID=' + EmpID + '&ResetTime=' + myDTG;
	xhr.open("POST", "http://idmgmtapp01/php/ResetTimer.php", true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
}

const WhoAmI = (user) => {
	let params = 'user=' + user;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", WhoAmIURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params);
}

/*
===================================================================================================
|                              Section Three: Form Submitting Functions                           |
===================================================================================================
*/

const DisplayDetails = () => {
	// Called by the ListAssociates.pl script.
	
	let form = document.getElementById("ViewDetails");
	form.submit();
}

const DisplayODDIntro = () => {
	// Called by the SearchBoxes.html file.
	top.mainpanel.location='http://idmgmtapp01/OneDriveDelegation/webpages/onedrivedelegation.htm';
}

const DisplayADACIntro = () => {
	// Called by the SearchBoxes.html file.
	top.mainpanel.location='http://idmgmtapp01/ADAccountCreation/webpages/CreateADACHTMLResponse.htm';
}

const DisplayTermIntro = () => {
	// Called by the SearchBoxes.html file.
	top.mainpanel.location='http://idmgmtapp01/webpages/AssociateTermination.htm';
}

const ResetAllAttributes = () => {
	localStorage.setItem('DisplayRollover','Yes');
}

const SetShowDescriptionsOff = () => {
	localStorage.setItem('DisplayRollover','No');
}

const SubmitDetailedListing = () => {
	// Called by the DetailedListing.pl script.
	var webUserDTG = localStorage.getItem('WebPageDTG');
	var params = 'webUserDTG=' + webUserDTG;
	var xhr = new XMLHttpRequest();
	xhr.open("POST", "http://idmgmtapp01/php/SetWebUserDTG.php", true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
	
	document.getElementById("Submit").disabled = true;
	document.getElementById("Cancel").disabled = true;
	let form = document.getElementById("DetailedListings");
	form.submit();
}

const SubmitODDRequest = () => {
	// top.mainpanel.location='http://idmgmtapp01/OneDriveDelegation/webpages/StatusOfODDProgress.html';
	document.getElementById('Submit').disabled = true;
	let form = document.getElementById('ViewListings');
	form.submit();
}

const ShowTimeOutScreen = () => {
	top.mainpanel.location='http://idmgmtapp01/webpages/TimeOut.htm';
}

const ShowIllegalAccessScreen = () => {
	top.mainpanel.location='http://idmgmtapp01/webpages/IllegalAccess.htm';
}

const LaunchAdminPortalBuildPage = () => {
	let form = document.getElementById("LaunchAdminPortalBuildPage");
	form.submit();	
}

const DisplayNewUserAddMessage = () => {
	top.mainpanel.location='http://idmgmtapp01/webpages/DisplayNewUserAddMessage.htm';
	let form = document.getElementById("AddUserToPortal");
	form.submit();
}

const DisplayIDMBanner = () => {
	top.topmainpanel.location='http://idmgmtapp01/webpages/AdminPortalWelcomeBanner.htm';
}


/*
===================================================================================================
|                             Section Four: Main Page Applications                                |
===================================================================================================
*/

const CreateWebUserDTG = () => {
	var now = new Date();
	var year = now.getFullYear().toString();
	var mn1 = now.getMonth();
	mn1 = mn1 + 1;
	var mn = mn1.toString();
	if(mn.length == 1) { var month = '0' + mn; }else{ var month = mn; }
	var dy = now.getDate().toString();
	if(dy.length == 1) { var day = '0' + dy; }else{ var day = dy; }
	var hr = now.getHours().toString();
	if(hr.length == 1) { var hour = '0' + hr; }else{ var hour = hr; }
	var min = now.getMinutes().toString();
	if(min.length == 1) { var minute = '0' + min; }else{ var minute = min; }
	var sec = now.getSeconds().toString();
	if(sec.length == 1) { var second = '0' + sec; }else{ var second = sec; }
	var myDTG = year + '-' + month +  '-' + day + ' ' + hour + ':' + minute + ':' + second;
	var webUserDTG = year + month + day + hour + minute + second;
	return [webUserDTG,myDTG];
}

const InsertNewTimeStamp = (webUserDTG,myDTG,userID,lastName,firstName,IDActive,loginAttempt) => {
	var params = 'webUserDTG=' + webUserDTG + '&myDTG=' + myDTG + '&userID=' + userID + '&lastName=' + lastName + '&firstName=' + firstName + '&IDActive=' + IDActive + '&loginAttempt=' + loginAttempt + '&loginDTG=' + myDTG;
	var xhr = new XMLHttpRequest();
	xhr.open("POST", "http://idmgmtapp01/php/LogInitialVisit.php", true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
}

const GetMainApplicationURL = (application,getMainApplicationURLValues,returnApplicationURL) => {		
	let applicationURL = "";
	let getInfoParams = 'application=' + application;
	const requestApplicationURL = new XMLHttpRequest();
	requestApplicationURL.addEventListener('readystatechange', () => {
		if(requestApplicationURL.readyState === 4 && requestApplicationURL.status === 200) 
		{
			returnApplicationURL(requestApplicationURL.responseText);
		}
	});
	requestApplicationURL.open("POST", getMainApplicationURLValues, true);
	requestApplicationURL.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestApplicationURL.send(getInfoParams);
}

const SendMainPageParameters = (user,EncryptedKey,applicationURL) => {	
	let params2 = 'user=' + user + '&EncryptedKey=' + EncryptedKey;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", applicationURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params2);
}

const CreateMainHTMLResponse = (application) => {
	GetMainApplicationURL(application,getMainApplicationURLValues,function(applicationURL)
	{
		let user = getCookie("emplid");
		WhoAmI(user);
		let EncryptedKey = getCookie("EncryptedKey");
		SendMainPageParameters(user,EncryptedKey,applicationURL);
		});
}

// This function builds the buttons you see on the main screen when you first visit the website
const BuildMainSelectionButtons = (applicationName) => {	
	let FunctionName = "";
	let FunctionID = "";
	let Value = "";
	let Image = "";
	let Width = "";
	let Height = "";

	// Request user information from the 'IDM_Website_Profile' SQL table.
	const requestValues = new XMLHttpRequest();
	requestValues.addEventListener('readystatechange', () => {
		if(requestValues.readyState === 4 && requestValues.status === 200) {
			const str = requestValues.responseText;
			console.log('str = ' + str);
			const obj = JSON.parse(str);
			let arrayLength = obj.ApplicationValues.length;
			var detailLine = '';
			
			for(let i=0;i<arrayLength;i++)
			{
				let FunctionName = obj.ApplicationValues[i].FunctionName;
				let FunctionID = obj.ApplicationValues[i].FunctionID;
				let MouseOver = obj.ApplicationValues[i].MouseOver;
				let MouseLeave = obj.ApplicationValues[i].MouseLeave;
				let Image = obj.ApplicationValues[i].Image;
				let Width = obj.ApplicationValues[i].Width;
				let Height = obj.ApplicationValues[i].Height;

				let Link = "<input id='Submit' name='Submit' value='" + FunctionID + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='" + MouseOver + "();' onMouseLeave='" + MouseLeave + "();' onClick='SetShowDescriptionsOff();"+ FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
				switch(FunctionID)
				{
					case "adminPortal":
						document.getElementById('adminPortal').innerHTML = Link;
						break;
					case "HRContactInfo":
						document.getElementById('HRContactInfo').innerHTML = Link;
						break;
					case "DepartmentalInfo":
						document.getElementById('DepartmentalInfo').innerHTML = Link;
						break;
					case "SnowFlake":
						document.getElementById('SnowFlake').innerHTML = Link;
						break;
				}
			}
		}
	});
	requestValues.open("GET", BuildMainSelectionButtonsURL, true);
	requestValues.setRequestHeader("Content-Type", "application/x-www-form-urlencoded", true);
	requestValues.send();	
}

/*
===================================================================================================
|                             Section Five: Admin Portal Applications                             |
===================================================================================================
*/

const GetUserAccessLevel = (EmplID,GetUserAccessLevelValue,returnUserAccessLevel) => {		
	let applicationURL = "";
	let getInfoParams = 'EmplID=' + EmplID;
	const requestAccessLevel = new XMLHttpRequest();
	requestAccessLevel.addEventListener('readystatechange', () => {
		if(requestAccessLevel.readyState === 4 && requestAccessLevel.status === 200) 
		{
			returnUserAccessLevel(requestAccessLevel.responseText);
		}
	});
	requestAccessLevel.open("POST", GetUserAccessLevelValue, true);
	requestAccessLevel.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestAccessLevel.send(getInfoParams);
}

const GetAPApplicationURL = (application,GetAdminPortalApplicationURLValues,returnApplicationURL) => {		
	let applicationURL = "";
	let getInfoParams = 'application=' + application;
	const requestApplicationURL = new XMLHttpRequest();
	requestApplicationURL.addEventListener('readystatechange', () => {
		if(requestApplicationURL.readyState === 4 && requestApplicationURL.status === 200) 
		{
			returnApplicationURL(requestApplicationURL.responseText);
		}
	});
	requestApplicationURL.open("POST", GetAdminPortalApplicationURLValues, true);
	requestApplicationURL.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestApplicationURL.send(getInfoParams);
}

const SendAdminPortalApplicationParameters = (user,EncryptedKey,applicationURL) => {	
	let params2 = 'user=' + user + '&EncryptedKey=' + EncryptedKey;
	console.log('Troubleshoot: user = [' + user + '], EncryptedKey = [' + EncryptedKey + ']');
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", applicationURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params2);
}

// This is the main incoming function when a desired App button is pressed on the screen.
const CreateAPApplicationHTMLResponse = (application) => {
	let applicationURL = "";

	GetAPApplicationURL(application,GetAPApplicationURLValue,function(applicationURL)
	{
		let user = getCookie("emplid");
		let EncryptedKey = getCookie("EncryptedKey");
		SendAdminPortalApplicationParameters(user,EncryptedKey,applicationURL);
	});
}

const BuildAdminPortalApplicationSelectionButtonsRefresh = () => {
	BuildAdminPortalApplicationSelectionButtons();
	var int = self.setInterval(function ()
	{
		BuildAdminPortalApplicationSelectionButtons();
	}, 500);
}

// This function builds the buttons we only see within the Admin Portal section of the website.
const BuildAdminPortalApplicationSelectionButtons = (applicationName) => {	
	let EmployeeID = getCookie("emplid");
	let FunctionName = "";
	let FunctionID = "";
	let Value = "";
	let Image = "";
	let Width = "";
	let Height = "";

	// Request user information from the 'IDM_Website_Profile' SQL table.
	const requestValues = new XMLHttpRequest();
	requestValues.addEventListener('readystatechange', () => {
		if(requestValues.readyState === 4 && requestValues.status === 200) {
			const str = requestValues.responseText;
			const obj = JSON.parse(str);
			let arrayLength = obj.ApplicationValues.length;
			var detailLine = '';
			
			for(let i=0;i<arrayLength;i++)
			{
				FunctionName = obj.ApplicationValues[i].FunctionName;
				FunctionID = obj.ApplicationValues[i].FunctionID;
				Value = obj.ApplicationValues[i].Value;
				Image = obj.ApplicationValues[i].Image;
				Width = obj.ApplicationValues[i].Width;
				Height = obj.ApplicationValues[i].Height;
				let Link = "<input id='Submit' name='Submit' value='" + Value + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='ODD_Description();' onMouseLeave='MainTopDisplay();' onClick='SetShowDescriptionsOff();" + FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
				switch(FunctionID)
				{
					case "OneDriveDelegation":
						GetAPApplicationURL(FunctionID,GetAPApplicationLevelPHP,function(ApplicationLevel)
						{
							ApplicationLevel = ApplicationLevel.trim();
							GetUserAccessLevel(EmployeeID,GetUserAccessLevelValue,function(AccessLevel)
							{
								AccessLevel = AccessLevel.trim();
								if(AccessLevel >= ApplicationLevel) { document.getElementById('OneDriveDelegation').innerHTML = Link; }
							});
						});
						break;
					case "ADAccountCreation":
						GetAPApplicationURL(FunctionID,GetAPApplicationLevelPHP,function(ApplicationLevel)
						{
							ApplicationLevel = ApplicationLevel.trim();
							GetUserAccessLevel(EmployeeID,GetUserAccessLevelValue,function(AccessLevel)
							{
								AccessLevel = AccessLevel.trim();
								if(AccessLevel >= ApplicationLevel) { document.getElementById('ADAccountCreation').innerHTML = Link; }
							});
						});
						break;
					case "TerminateAssociate":
						GetAPApplicationURL(FunctionID,GetAPApplicationLevelPHP,function(ApplicationLevel)
						{
							ApplicationLevel = ApplicationLevel.trim();
							GetUserAccessLevel(EmployeeID,GetUserAccessLevelValue,function(AccessLevel)
							{
								AccessLevel = AccessLevel.trim();
								if(AccessLevel >= ApplicationLevel) { document.getElementById('TerminateAssociate').innerHTML = Link; }
							});
						});
						break;
				}
			}
		}
	});
	
	requestValues.open("GET", BuildAdminPortalSelectionButtonsURL, true);
	requestValues.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestValues.send();	
}

/*
===================================================================================================
|                               Section Six: Housekeeping Applications                            |
===================================================================================================
*/

const GetHKApplicationURL = (application,GetHKApplicationURLValues,returnApplicationURL) => {		
	let applicationURL = "";
	let getInfoParams = 'application=' + application;
	const requestApplicationURL = new XMLHttpRequest();
	requestApplicationURL.addEventListener('readystatechange', () => {
		if(requestApplicationURL.readyState === 4 && requestApplicationURL.status === 200) 
		{
			returnApplicationURL(requestApplicationURL.responseText);
		}
	});
	requestApplicationURL.open("POST", GetHKApplicationURLValues, true);
	requestApplicationURL.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestApplicationURL.send(getInfoParams);
}

const SendHousekeepingParameters = (illegalAccess,applicationURL) => {	
	let params2 = 'illegalAccess=' + illegalAccess;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", applicationURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params2);
}

const CreateHKHTMLResponse = (application) => {
	GetHKApplicationURL(application,GetHKApplicationURLValues,function(applicationURL)
	{
		// Let's make sure they cookie is valid.
		// This will decide whether to let them in or not.
		let IAMADMIN = getCookie("IAMADMIN");
		if(IAMADMIN == IAMADMINPassword)
		{
			// User is eligable to make Housekeeping administrative changes.
			let illegalAccess = "No";
			SendHousekeepingParameters(illegalAccess,applicationURL);
		}
		else
		{
			// User is NOT eligable to make Housekeeping administrative changes.
			let illegalAccess = "Yes";
			SendHousekeepingParameters(illegalAccess,applicationURL);
		}
	});	
}

const BuildHousekeepingSelectionButtons = (applicationName) => {		
	let FunctionName = "";
	let FunctionID = "";
	let Value = "";
	let Image = "";
	let Width = "";
	let Height = "";

	// Request user information from the 'IDM_Website_Profile' SQL table.
	const requestValues = new XMLHttpRequest();
	requestValues.addEventListener('readystatechange', () => {
		if(requestValues.readyState === 4 && requestValues.status === 200) {
			const str = requestValues.responseText;
			console.log('str = ' + str);
			const obj = JSON.parse(str);
			console.log('obj = ' + obj);
			let arrayLength = obj.ApplicationValues.length;
			var detailLine = '';
			
			for(let i=0;i<arrayLength;i++)
			{
				FunctionName = obj.ApplicationValues[i].FunctionName;
				FunctionID = obj.ApplicationValues[i].FunctionID;
				Value = obj.ApplicationValues[i].FunctionID;
				Image = obj.ApplicationValues[i].Image;
				Width = obj.ApplicationValues[i].Width;
				Height = obj.ApplicationValues[i].Height;
				let Link = "<input id='Submit' name='Submit' value='" + Value + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='ODD_Description();' onMouseLeave='MainTopDisplay();' onClick='SetShowDescriptionsOff();" + FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
				switch(FunctionID)
				{
					case "AddUserToPortal":
						document.getElementById('AddUserToPortal').innerHTML = Link;
						break;
				}
			}
		}
	});
	requestValues.open("GET", BuildHousekeepingSelectionButtonsURL, true);
	requestValues.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestValues.send();	
}

/*
===================================================================================================
|                          Section Seven: Register New Users Applications                         |
===================================================================================================
*/

// Retrieves the newly created Encrypted key.
const RetrieveEncryptedKey = (EmplID,RetrieveInitialEncryptedKey,returnEncryptedKey) => {		
	let applicationURL = "";
	let getInfoParams = 'EmplID=' + EmplID;
	const requestEncryptedKey = new XMLHttpRequest();
	requestEncryptedKey.addEventListener('readystatechange', () => {
		if(requestEncryptedKey.readyState === 4 && requestEncryptedKey.status === 200) 
		{
			returnEncryptedKey(requestEncryptedKey.responseText);
		}
	});
	requestEncryptedKey.open("POST", RetrieveInitialEncryptedKey, true);
	requestEncryptedKey.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestEncryptedKey.send(getInfoParams);
}

const CreateRegisterHTML = (Name,EmplID,CookieStatus) => {		
	var params = 'Name=' + Name + '&EmplID=' + EmplID + '&CookieStatus=' + CookieStatus;
	var xhr = new XMLHttpRequest();
	xhr.open("POST", CreateRegistrationPagePHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
}

const LogInitialVisit = () => {
	let IDActive = 0;
	let loginAttempt = "";
	// First we generate the date-time stamp which will bind this 
	// user instance to work that will be done in the Admin Portal.
	var now = new Date();
	var year = now.getFullYear().toString();
	var mn1 = now.getMonth();
	mn1 = mn1 + 1;
	var mn = mn1.toString();
	if(mn.length == 1) { var month = '0' + mn; }else{ var month = mn; }
	var dy = now.getDate().toString();
	if(dy.length == 1) { var day = '0' + dy; }else{ var day = dy; }
	var hr = now.getHours().toString();
	if(hr.length == 1) { var hour = '0' + hr; }else{ var hour = hr; }
	var min = now.getMinutes().toString();
	if(min.length == 1) { var minute = '0' + min; }else{ var minute = min; }
	var sec = now.getSeconds().toString();
	if(sec.length == 1) { var second = '0' + sec; }else{ var second = sec; }
	var myDTG = year + '-' + month +  '-' + day + ' ' + hour + ':' + minute + ':' + second;
	var webUserDTG = year + month + day + hour + minute + second;
	localStorage.setItem('WebPageDTG',webUserDTG);
	localStorage.setItem('DisplayRollover','Yes');
}

const CreateRegisterUserDropDown = () => {
	let dropDownData = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.Register.length;
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData += "<option value='" + obj.Register[i].EmpID + "'>" + obj.Register[i].Name + "</option>";
			}
			document.getElementById('name').innerHTML = dropDownData;
		}
	});

	request.open("GET", CreateRegisterUserDropDownPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

const RegisterNewUser = () => {
	let cookieStatus = "";
	let EmpID = document.getElementById('name').value;
	GetNewRegisteredUserInfo(EmpID,PHPFileName,function(RegUserInfo)
	{
		let i = 0;
		const obj = JSON.parse(RegUserInfo);
		const arrayLength = obj.NewUser.length;
		let Name = obj.NewUser[i].Name
		let EmplID = obj.NewUser[i].EmpID
		let AccessLevel = obj.NewUser[i].AccessLevel
		let Registered = obj.NewUser[i].Registered
		
		// Now let's check to see if the user's cookie exist.
		let user = getCookie("emplid");
		if(user == '' || user == null)
		{
			setCookie("emplid",EmplID, 365);
			LogInitialVisit();
			
			// We create the encrypted key ahead of time in the CreateEncryptedKey.exe PowerShell script.
			RetrieveEncryptedKey(EmpID,RetrieveInitialEncryptedKey,function(thisEncryptedKey)
			{
				thisEncryptedKey = thisEncryptedKey.trim();
				setCookie("EncryptedKey",thisEncryptedKey, 365);
			});
			CookieStatus = 3;

		}
		else
		{
			CookieStatus = 1;
		}
		
		CreateRegisterHTML(Name,EmplID,CookieStatus);
	});
	
	top.mainpanel.location='http://idmgmtapp01/webpages/Register.htm';
	let form = document.getElementById('RegisterCookie');
	form.submit();
}

/*
===================================================================================================
|                           Section Eight: Application Support Functions                          |
===================================================================================================
*/

const LoadTextTrackingTable = () => {
	let dropDownData = '';
	const request = new XMLHttpRequest();

	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_TextTracking.length;
			dropDownData += "<option value='SelectYourName'>Select Name</option>";
			for(let i=0;i<arrayLength;i++)
			{
				let fullName = obj.JSON_TextTracking[i].firstName + " " + obj.JSON_TextTracking[i].lastName;
				dropDownData += "<option value='" + obj.JSON_TextTracking[i].phoneNumber + "'>" + fullName + "</option>";
			}
			document.getElementById('userNames').innerHTML = dropDownData;
		}
	});

	request.open("GET", LoadTextTrackingTablePHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

/*
----------------------------------------------------------------------------------------------------------------
|   Function Name: DisplayTerminatedAccounts                                                                   |
|       Called By: C:\Apache24\cgi-bin\Applications\AssociateTerminations\ProcessTermination.pl            |
|      PHP Script: DisplayTerminatedAccounts                                                                   |
|         Purpose: Loads the fields retrieved from the RawADs_VW SQL table via the StatusOfODDProgress.php     |
|                  script to display the percentage completed progress of the Associate Termination process.   |
---------------------------------------------------------------------------------------------------------------- */

function DisplayTerminatedAccounts(assocID)
{
	// Called by the DetailedListing.pl script.
	
	let params = 'AssocID=' + assocID;
	var xhr;
	if (window.XMLHttpRequest)
	{
		xhr = new XMLHttpRequest();
	}
	else if (window.ActiveXObject)
	{
		xhr = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xhr.open("POST", DisplayTerminatedAccountsPHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
	xhr.onreadystatechange = display_DTA_detaildata;

	function display_DTA_detaildata()
	{
		if (xhr.readyState == 4)
		{
			if (xhr.status == 200)
			{
				var str = xhr.responseText;
				const obj = JSON.parse(str);
				let arrayLength = obj.RawADSData.length;
				var detailLine = '';
				for(let i=0;i<arrayLength;i++)
				{
					detailLine += "<tr><td width='8%'><p class='WhiteText_P15'>" + obj.RawADSData[i].domain + "</p></td>";
					detailLine += "<td width='8%'><p class='WhiteText_P15'>" + obj.RawADSData[i].sAMAccountName + "</p></td>";
					detailLine += "<td width='8%'><p class='WhiteText_P15'>" + obj.RawADSData[i].Enabled + "</p></td>";
					detailLine += "<td width='10%'><p class='WhiteText_P15'>" + obj.RawADSData[i].sn + "</p></td>";
					detailLine += "<td width='10%'><p class='WhiteText_P15'>" + obj.RawADSData[i].GivenName + "</p></td>";
					detailLine += "<td width='18%'><p class='WhiteText_P15'>" + obj.RawADSData[i].Title + "</p></td>";
					detailLine += "<td width='19%'><p class='WhiteText_P15'>" + obj.RawADSData[i].whenCreated + "</p></td>";
					detailLine += "<td width='19%'><p class='WhiteText_P15'>" + obj.RawADSData[i].whenChanged + "</p></td></tr>";
				}
				document.getElementById('detailLine').innerHTML = detailLine;
			}
		}
	}
	top.topmainpanel.location='http://idmgmtapp01/webpages/TermTitlePage.html';
}

const ExecuteTermination = (assocID) => {
	// Called by the ProcessTermination.pl script.
	console.log('assocID = [' + assocID + ']');
	var params = 'AssocID=' + assocID;
	var xhr = new XMLHttpRequest();
	xhr.open("POST",ExecuteTerminationURL, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
	//let form = document.getElementById("DetailedListings");
	//form.submit();
}

const StoreEmployeeIDSearchString = (assocID) => {
	// Called by the DetailedListing.pl script.
	let EmpID = getCookie("emplid");
	let params = 'EmpID=' + EmpID + '&SrchAssocID=' + assocID;
	var xhr;
	xhr = new XMLHttpRequest();
	xhr.open("POST", StoreEmployeeIDSearchStringPHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);	
}

// Called by the SearchBoxes.html file.
const UpdateSearchRecords = () => {
	let EmpID = getCookie("emplid");
	let srchAssocID = document.getElementById('assocID').value;
	let params = 'EmpID=' + EmpID + '&SrchAssocID=' + srchAssocID;
	var xhr;
	xhr = new XMLHttpRequest();
	xhr.open("POST", StoreEmployeeIDSearchStringPHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);	
	let form = document.getElementById("ViewListings");
	form.submit();
}

function InitialFormerAssociateDropDownList()
{
	let dropDownData = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			let arrayLength = obj.JSON_FormerAssociateNames.length;
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData += "<option value='" + obj.JSON_FormerAssociateNames[i].formerAssociateNames + "'>" + obj.JSON_FormerAssociateNames[i].formerAssociateNames + "</option>";
			}
			document.getElementById('associateNames').innerHTML = dropDownData;
		}
	});

	request.open("GET", InitialFormerAssociateDropDownListPHPFile, true);
	// request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

function InitialRequesterDownList()
{
	let dropDownData2 = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_RequesterName.length; 
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData2 += "<option value='" + obj.JSON_RequesterName[i].requesterNames  + "'>" + obj.JSON_RequesterName[i].requesterNames + "</option>";
			}
			document.getElementById('requesterNames').innerHTML = dropDownData2;
		}
	});

	request.open("GET", InitialRequesterDownListPHPFile, true);
	//request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

function UpdateFormerAssociateDropDownList(textBox)
{
	const assocName = textBox.value;
	const params = 'assocName=' + assocName;
	let dropDownData = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_FormerAssociateNames.length;
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData += "<option value='" + obj.JSON_FormerAssociateNames[i].formerAssociateNames + "'>" + obj.JSON_FormerAssociateNames[i].formerAssociateNames + "</option>";
			}
			document.getElementById('associateNames').innerHTML = dropDownData;
		}
	});

	request.open("POST", UpdateFormerAssociateDropDownListPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send(params);	
}

function UpdateRequesterDropDownList(textBox)
{
	const requesterName = textBox.value;
	const params = 'requesterName=' + requesterName;
	let dropDownData2 = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_RequesterName.length;
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData2 += "<option value='" + obj.JSON_RequesterName[i].requesterNames + "'>" + obj.JSON_RequesterName[i].requesterNames + "</option>";
			}
			document.getElementById('requesterNames').innerHTML = dropDownData2;
		}
	});

	request.open("POST", UpdateRequesterDropDownListPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send(params);	
}

function StatusOfODDProcess()
{
	let i = 0;
	const request = new XMLHttpRequest();
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			document.getElementById("ODDPctDone").innerText = obj.oddstats[i].pctdone;
			document.getElementById("ODDPctDone").setAttribute("class", "White_P18");
			document.getElementById("ODDStatus").innerText = obj.oddstats[i].msg;
			document.getElementById("ODDStatus").setAttribute("class", "White_P18");
			document.getElementById("ODDFinishMsg1").innerText = obj.oddstats[i].msg1;
			document.getElementById("ODDFinishMsg1").setAttribute("class", "ODD_P28_Heading");
			document.getElementById("ODDFinishMsg2").innerText = obj.oddstats[i].msg2;
			document.getElementById("ODDFinishMsg2").setAttribute("class", "ODD_P28_Heading");				
		}
	});
	self.setInterval(() => PullODDProgress(request),400)
}

function PullODDProgress(request)
{
    request.open("GET", StatusOfODDProgressPHPFile, true);
    request.send();
}

/*
----------------------------------------------------------------------------------------------------------------
|   Function Name: LocationNameDropDownList                                                                    |
|       Called By: C:\Apache24\htdocs\Applications\ADAccountEntry\ADAccountEntry.html                      |
|      PHP Script: LocationNameDropDownList.php                                                                |
|         Purpose: Loads the 'locationCode' and 'description' variables from the 'HR_Locations' SQL table      |
|                  to populate the Location drop-down box in ADAccountEntry.html.                              |
---------------------------------------------------------------------------------------------------------------- */

function LocationNameDropDownList()
{
	let dropDownData = '';
	const request = new XMLHttpRequest();

	// Kick off the listener method and wait for data to roll in.
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_LocationName.length;
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData += "<option value='" + obj.JSON_LocationName[i].locationCode + "'>" + obj.JSON_LocationName[i].description + "</option>";
			}
			document.getElementById('locationNames').innerHTML = dropDownData;
		}
	});

	request.open('GET', LocationNameDropDownListPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

/*
===================================================================================================
|                                 Section Nine: Rollover Functions                                |
===================================================================================================
*/

const initialTopDisplay = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/webpages/InitialTopDisplay.htm';
	}
}

const BlueBlank_Description = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/webpages/blueblank.htm';
	}
}

const Admin_Portal_Description = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/webpages/admin_portal_rollover_desc.htm';
	}	
}

// The following rollover functions are for the admin protal

const ADAC_Description = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/ADAccountCreation/webpages/ADAC_Description.htm';
	}
}

const ODD_Description = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/OneDriveDelegation/webpages/ODD_Description.htm';
	}
}

const EmployeeTerminationDescription = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/AssociateTerminations/webpages/EmployeeTerminationDescription.htm';
	}
}

const PostInitialAdminPortalAccess = () => {
	let form = document.getElementById("SelectName");
	form.submit();
}

const PortalLogoutBanner = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/webpages/PortalLogoutBanner.htm';
	}
}

const MainTopDisplay = () => {
	let DisplayRollovers = localStorage.getItem('DisplayRollover');
	if(DisplayRollovers == 'Yes')
	{
		top.topmainpanel.location='http://idmgmtapp01/webpages/AdminPortalWelcomeBanner.htm';
	}
}
