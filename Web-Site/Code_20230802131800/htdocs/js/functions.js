/*
  JavaScript Name: functions.js
     Date Written: May 8th, 2023
       Written By: Dave Jaynes
          Purpose: This file holds all the functions for the IDM Website.
				           It is broken down into ten sections, each one cooresponding to a different functionality of the website.
				           These ten sections are:
	
	1. Global and pointer variables: Those variables used by one or more functions as well as URL/PHP file pointers.
	2. Global Functions: Those functions used by more than one application.
	3. Form Submitting and Panel painting Functions: Used to direct froms to their associated CGI scripts as well as update HTML panels.
	4. Main Page Applications: Those functions that support the main page.
	5. Admin Portal Applications: Those functions what support the Admin Portal page.
	6. Housekeeping Applications: Those functions used by webpage support.
	7. Register New Users Applications: These are special utility functions. (SetCookie_functions.js)
	8. Application Support Functions: Specialized functions assisting individual apps such as ODD. (AJAX_functions.js)
	9. Rollover Functions: Shows a description of the application  as the mouse cursor rolls over button.
 10. Graphics Functions: These include pie charts and other graphical visual aids.
 11. Promotion of website code: Provides a means of promoting changes of the development code into production.

===================================================================================================
|                           Section One: Global and pointer Variables                             |
===================================================================================================
*/
let applicationURL = "";
let AppCheckBoxNameInstance = "";
const Admins = ["103257","103882","101791","120405","120441"];
let TERMButton = '';
let ADACButton = '';
let ODDButton = '';
const PHPFileName = "http://idmgmtapp01/php/GetNewRegisteredUserInfo.php";
const GetOldRegisteredUserInfoPHP = "http://idmgmtapp01/php/GetOldRegisteredUserInfo.php";
const getMainApplicationURLValues = "http://idmgmtapp01/php/BuildWebPageScripts/GetMainApplicationURLValues.php";
const GetAPApplicationLevelPHP = "http://idmgmtapp01/php/GetAdminPortalApplicationValues.php";
const GetAPApplicationURLValue = "http://idmgmtapp01/php/GetAdminPortalApplicationURL.php";
const getUserAttributes = "http://idmgmtapp01/php/ReturnUserAttributes.php";
const GetUserRolesURL = "http://idmgmtapp01/php/HousekeepingScripts/GetUserRoles.php";
const WhoAmIURL = "http://idmgmtapp01/php/WhoAmI.php";
const GetHKApplicationURLValues = "http://idmgmtapp01/php/BuildWebPageScripts/GetHousekeepingURLValues.php";
const GetPromoteApplicationURLValues = "http://idmgmtapp01/php/BuildWebPageScripts/GetPromoteURLValues.php";
const ExecuteTerminationURL = "http://idmgmtapp01/php/ExecuteTermination.php";
const FormerAssociateDropDownListURL = "http://idmgmtapp01/OneDriveDelegation/php/InitialFormerAssociateDropDownList.php";
const BuildMainSelectionButtonsURL = "http://idmgmtapp01/php/BuildMainSelectionButtons.php";
const BuildAdminPortalSelectionButtonsURL = "http://idmgmtapp01/php/BuildAdminPortalSelectionButtons.php";
const BuildHousekeepingSelectionButtonsURL = "http://idmgmtapp01/php/HousekeepingScripts/BuildHousekeepingSelectionButtons.php";
const BuildPromoteSelectionButtonsURL = "http://idmgmtapp01/php/HousekeepingScripts/BuildPromoteSelectionButtons.php";
const KickOffPromotionURL = "http://idmgmtapp01/php/KickOffPromotion.php";
const DisplayPromotionProgressURL = "http://idmgmtapp01/php/DisplayPromotionProgress.php";
const CreateRegisterUserDropDownPHPFile = "http://idmgmtapp01/php/CreateRegisterUserDropDown.php";
const LoadTextTrackingTablePHPFile = "http://idmgmtapp01/php/LoadTextTrackingTable.php";
const DisplayTerminatedAccountsPHPFile = "http://idmgmtapp01/php/DisplayTerminatedAccounts.php";
const StoreEmployeeIDSearchStringPHPFile = "http://idmgmtapp01/AssociateTerminations/php/StoreEmployeeIDSearchString.php";
const InitialFormerAssociateDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/InitialFormerAssociateDropDownList.php";
const InitialRequesterDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/InitialRequesterDropDownList.php";
const UpdateFormerAssociateDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/UpdateFormerAssociateDropDownList.php";
const UpdateRequesterDropDownListPHPFile = "http://idmgmtapp01/OneDriveDelegation/php/UpdateRequesterDropDownList.php";
const StatusOfODDProgressPHPFile = "http://idmgmtapp01/php/StatusOfODDProgress.php";
const LocationNameDropDownListPHPFile = "http://idmgmtapp01/php/LocationNameDropDownList.php";
const JobCodeDropDownListPHPFile = "http://idmgmtapp01/php/JobCodeDropDownList.php";
const RetrieveInitialEncryptedKey = "http://idmgmtapp01/php/HousekeepingScripts/RetrieveInitialEncryptedKey.php"
const CreatePreRegistrationPagePHPFile = "http://idmgmtapp01/php/CreatePreRegisterHTML.php";
const CreateRegistrationPagePHPFile = "http://idmgmtapp01/php/CreateRegisterHTML.php";
const DetermineNewUserEligabilityURL = "http://idmgmtapp01/php/HousekeepingScripts/DetermineNewUserEligability.php"
const CreateModifyUserAttributesPageURL  = "http://idmgmtapp01/php/HousekeepingScripts/CreateModifyUserAttributesPage.php";
const DeleteUserFromAdminPortalURL  = "http://idmgmtapp01/php/HousekeepingScripts/DeleteUserFromAdminPortal.php";
const PullListOfAdminUsersURL  = "http://idmgmtapp01/php/HousekeepingScripts/PullListOfAdminUsers.php";
const UpdateUserSettingsURL = "http://idmgmtapp01/php/HousekeepingScripts/UpdateUserSettings.php";
const UpdateApplicationSettingsURL = "http://idmgmtapp01/php/HousekeepingScripts/UpdateApplicationsSettings.php";
const PullBUListingURL = "http://idmgmtapp01/php/PullBUData.php";
const PullGrowthListingURL = "http://idmgmtapp01/php/PullGrowthData.php";
const PullARDataURL = "http://idmgmtapp01/php/PullAccessReviewData.php";
const UpdateUserApplicationSettingsURL = "http://idmgmtapp01/php/HousekeepingScripts/UpdateUserApplicationSettings.php";
const RegisterNewUserURL = "http://idmgmtapp01/php/HousekeepingScripts/RegisterNewUser.php";
const CheckUsersAuthenticationURL = "http://idmgmtapp01/php/HousekeepingScripts/CheckUsersAuthentication.php";
const AdminPortalErrorScreenURL = "http://idmgmtapp01/php/BuildWebPageScripts/AdminPortalErrorScreen.php";
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

const PullListOfAdminUsers = (returnAdminUserList) => {
	const AdminUserList = [];
	const requestListOfAdminUsers = new XMLHttpRequest();
	requestListOfAdminUsers.addEventListener('readystatechange', () => {
		if(requestListOfAdminUsers.readyState === 4 && requestListOfAdminUsers.status === 200) 
		{
			const str = requestListOfAdminUsers.responseText;
			const obj = JSON.parse(str);
			let arrayLength = obj.ListOfAdminUsers.length;
			var detailLine = '';
			for(let i=0;i<arrayLength;i++)
			{
				EmpID = obj.ListOfAdminUsers[i].EmpID;
				AdminUserList.push(EmpID);
			}
			returnAdminUserList(AdminUserList);
		}
	});
	requestListOfAdminUsers.open("GET", PullListOfAdminUsersURL, true);
	requestListOfAdminUsers.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestListOfAdminUsers.send();
}

const WhoAmI = (user) => {
	let params = 'user=' + user;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", WhoAmIURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params);
}

const CheckUsersAuthentication = (user,EncryptedKey,CheckUsersAuthenticationURL,returnVerificationCode) => {
	if(user == '' || user == null) { user = 'Empty'; }
	if(EncryptedKey == '' || EncryptedKey == null) { EncryptedKey = 'Empty'; }
	let getInfoParams = 'user=' + user + '&EncryptedKey=' + EncryptedKey;
	const requestVerificationCode = new XMLHttpRequest();
	requestVerificationCode.addEventListener('readystatechange', () => {
		if(requestVerificationCode.readyState === 4 && requestVerificationCode.status === 200) 
		{
			returnVerificationCode(requestVerificationCode.responseText);
		}
	});
	requestVerificationCode.open("POST", CheckUsersAuthenticationURL, true);
	requestVerificationCode.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestVerificationCode.send(getInfoParams);
}

const CallUserBasedApplication = (user,EncryptedKey,applicationURL) => {	
	let params = 'user=' + user + '&EncryptedKey=' + EncryptedKey;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", applicationURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params);
}

const CallNonUserBasedApplication = (illegalAccess,applicationURL) => {	
	let params = 'illegalAccess=' + illegalAccess;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", applicationURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params);
}

/*
===================================================================================================
|                  Section Three: Form Submitting and Panel painting Functions                    |
===================================================================================================
*/

const SubmitPortalForm = () => {
	let form = document.getElementById('PortalForm');
	form.submit();
}

const SubmitODDRequest = () => {
	let form = document.getElementById('CallODDelegation');
	form.submit();
}

const SubmitADACRequest = () => {
	let form = document.getElementById('CallAcctCreation');
	form.submit();
}

const SubmitTERMRequest = () => {
	let form = document.getElementById('CallTerminateAssociate');
	form.submit();
}

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

const LaunchDisplayEventLogs = () => {
	top.topmainpanel.location='http://idmgmtapp01/webpages/DisplayEventLogsBanner.html';
	let form = document.getElementById("DisplayEventLogsForm");
	form.submit();
}

const LaunchAboutThisWebsite = () => {
	top.topmainpanel.location='http://idmgmtapp01/webpages/DisplayAboutThisWebsiteBanner.html';
	let form = document.getElementById("AboutThisWebsiteForm");
	form.submit();
}

const DisplayHelpBanner = () => {
	top.topmainpanel.location='http://idmgmtapp01/webpages/DisplayHelpBanner.html';
}

const ODDInstructions = () => {
	top.middleleftpanel.location='http://idmgmtapp01/webpages/ODDInstructions.htm';
}

const ADACInstructions = () => {
	top.middleleftpanel.location='http://idmgmtapp01/webpages/ADACInstructions.htm';
}

const TERMInstructions = () => {
	top.middleleftpanel.location='http://idmgmtapp01/webpages/TERMInstructions.htm';
}

const AddUserToPortalInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/AddUserToPortalInstructions.htm';
}

const ModifyUserAttributesInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/ModifyUserAttributesInstructions.htm';
}

const RestoreWebsiteDataInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/RestoreWebsiteDataInstructions.htm';
}

const PromoteInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/PromoteCodeInstructions.htm';
}

const RevertInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/RestoreWebsiteDataInstructions.htm';
}

const GITInstructions = () => {
	top.bottomleftpanel.location='http://idmgmtapp01/webpages/RestoreWebsiteDataInstructions.htm';
}

const PromotionNotAllowed = () => {
	top.mainpanel.location='http://idmgmtapp01/webpages/PromotionNotAllowed.htm';
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

const AdminPortalErrorScreen = (user,EncryptedKey,GetReturnValue,AdminPortalErrorScreenURL) => {	
	let params = 'user=' + user + '&EncryptedKey=' + EncryptedKey + '&GetReturnValue=' + GetReturnValue;
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", AdminPortalErrorScreenURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send(params);
}

const CreateMainHTMLResponse = (application) => {
	GetMainApplicationURL(application,getMainApplicationURLValues,function(applicationURL)
	{
		let user = getCookie("ProdEmpID");
		let EncryptedKey = getCookie("ProdEncryptedKey");
		WhoAmI(user);
		CheckUsersAuthentication(user,EncryptedKey,CheckUsersAuthenticationURL,function(GetReturnValue)
		{
			GetReturnValue = GetReturnValue.trim();
			switch(GetReturnValue)
			{
				case "0":
					AdminPortalErrorScreen(user,EncryptedKey,GetReturnValue,AdminPortalErrorScreenURL);
					break;
				case "31":
					CallUserBasedApplication(user,EncryptedKey,applicationURL);
					break;
				default:
					AdminPortalErrorScreen(user,EncryptedKey,GetReturnValue,AdminPortalErrorScreenURL);
					break;
			}
		});
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

				let Link = "<input id='Submit' name='Submit' value='" + FunctionID + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='" + MouseOver + "();' onMouseLeave='" + MouseLeave + "();' onClick='SetShowDescriptionsOff();" + FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
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

const GetUserAccessLevel = (EmplID,GetUserRolesURL,returnUserAccessLevel) => {		
	let applicationURL = "";
	let getInfoParams = 'EmplID=' + EmplID;
	const requestAccessLevel = new XMLHttpRequest();
	requestAccessLevel.addEventListener('readystatechange', () => {
		if(requestAccessLevel.readyState === 4 && requestAccessLevel.status === 200) 
		{
			returnUserAccessLevel(requestAccessLevel.responseText);
		}
	});
	requestAccessLevel.open("POST", GetUserRolesURL, true);
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

// This is the main incoming function when a desired App button is pressed on the screen.
const CreateAPApplicationHTMLResponse = (application) => {
	let applicationURL = "";
	// Here we retrieve the application (One Drive Delegation, Terminate Associate ... etc)
	GetAPApplicationURL(application,GetAPApplicationURLValue,function(applicationURL)
	{
		// Now we check to see if the user has the proper cookies values to authenticate
		// into the Admin Portal. We are looking for a return value of 31 which means "Good to go!".
		let user = getCookie("ProdEmpID");
		let EncryptedKey = getCookie("ProdEncryptedKey");
		CheckUsersAuthentication(user,EncryptedKey,CheckUsersAuthenticationURL,function(GetReturnValue)
		{
			GetReturnValue = GetReturnValue.trim();
/*
			Based on the return value from CheckUsersAuthentication function, here are the possible result codes:
			
			Code									Defination of Code
			----	---------------------------------------------------------------------------------------------
			  0     User has no cookies stored on their computer. They need to go to the Website Clinic.
			  1		User has the Employee ID cookie on their computer but no Encrypted cooke. Website Clinic.
			  2		User has the Encrypted cookie on their computer but no Employee ID cooke. Website Clinic.
			  3		User has both cookies on their laptop but are not present in the system. Website Clinic.
			  5		User is partically registered (Only in WebNewUsers table) and has no Encrypted cooke. Website Clinic.
			  7		User is registered but their is no entry in the WebEncryptedKeys table. Website Clinic.
			  9		User has Employee ID cooke but no Encrypted cookie. They are only in the WebEncryptedKeys table. Website Clinic.
			 15		User is registered but Encrypted cooke value does not match that in the WebEncryptedKeys table. Website Clinic.
			 31		User is completely registered correctly! Off to the application we go!
			 
					Now we use the switch statement to pass program control to the proper    
					PHP files that will handle each of the 9 possible return values above.
*/
			CallUserBasedApplication(user,EncryptedKey,applicationURL);
		});
	});
}

// This function builds the buttons we only see within the Admin Portal section of the website.
const BuildAdminPortalApplicationSelectionButtonsRefresh = () => {
	BuildAdminPortalApplicationSelectionButtons();
	var int = self.setInterval(function ()
	{
		BuildAdminPortalApplicationSelectionButtons();
	}, 1000);
}

// This function builds the buttons we only see within the Admin Portal section of the website.
const BuildAdminPortalApplicationSelectionButtons = () => {
	let EmployeeID = getCookie("ProdEmpID");
	GetUserAccessLevel(EmployeeID,GetUserRolesURL,function(AllButtons)
	{
		AllButtons = AllButtons.trim();
		document.getElementById('AllButtons').innerHTML = AllButtons;
	});
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

// Check if current user is authorized to perform administrative tasks.
const CreateHKHTMLResponse = (application) => {
	GetHKApplicationURL(application,GetHKApplicationURLValues,function(applicationURL)
	{
		let EmployeeID = getCookie("ProdEmpID");
		PullListOfAdminUsers(function(GetAdminUserList)
		{
			if(GetAdminUserList.includes(EmployeeID))
			{
				// User is eligable to make Housekeeping administrative changes.
				let illegalAccess = "No";
				switch(application)
				{
					case "AddUserToPortal":
						top.mainpanel.location='http://idmgmtapp01/webpages/AddUsersToPortal.htm';
						break;
					case "ModifyUserAttributes":
						top.topmainpanel.location='http://idmgmtapp01/webpages/ModifyUsersTitleBar.htm';
						break;
					case "RestoreWebsiteData":
						top.topmainpanel.location='http://idmgmtapp01/webpages/RestoreWebsiteData.htm';
						break;
				}
				CallNonUserBasedApplication(illegalAccess,applicationURL);
			}
			else
			{
				// User is NOT eligable to make Housekeeping administrative changes.
				let illegalAccess = "Yes";
				CallNonUserBasedApplication(illegalAccess,applicationURL);
			}
		});
	});	
}

const BuildHousekeepingSelectionButtons = (applicationName) => {		
	let FunctionName = "";
	let FunctionID = "";
	let Value = "";
	let Image = "";
	let Width = "";
	let Height = "";
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
				Value = obj.ApplicationValues[i].FunctionID;
				OnClick = obj.ApplicationValues[i].OnClick;
				Image = obj.ApplicationValues[i].Image;
				Width = obj.ApplicationValues[i].Width;
				Height = obj.ApplicationValues[i].Height;
				let Link = "<input id='Submit' name='Submit' value='" + Value + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='ODD_Description();' onMouseLeave='MainTopDisplay();' onClick='SetShowDescriptionsOff();" + OnClick + "();" + FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
				switch(FunctionID)
				{
					case "AddUserToPortal":
						document.getElementById('AddUserToPortal').innerHTML = Link;
						break;
					case "ModifyUserAttributes":
						document.getElementById('ModifyUserAttributes').innerHTML = Link;
						break;
					case "RestoreWebsiteData":
						document.getElementById('RestoreWebsiteData').innerHTML = Link;
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
|                          Section Seven: Register New Users and Modify Applications              |
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

const CreatePreRegisterHTML = (Name,EmplID) => {		
	var params = 'Name=' + Name + '&EmplID=' + EmplID;
	var xhr = new XMLHttpRequest();
	xhr.open("POST", CreatePreRegistrationPagePHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);
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

const GetNewRegisteredUserInfo = (EmpEMail,PHPFileName,returnRegisteredUserInfo) => {		
	let applicationURL = "";
	let getInfoParams = 'EmpEMail=' + EmpEMail;
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

const GetOldRegisteredUserInfo = (EmpEMail,GetOldRegisteredUserInfoPHP,returnOldRegisteredUserInfo) => {		
	let applicationURL = "";
	let getInfoParams = 'EmpEMail=' + EmpEMail;
	const requestOldRegisteredUserInfo = new XMLHttpRequest();
	requestOldRegisteredUserInfo.addEventListener('readystatechange', () => {
		if(requestOldRegisteredUserInfo.readyState === 4 && requestOldRegisteredUserInfo.status === 200) 
		{
			returnOldRegisteredUserInfo(requestOldRegisteredUserInfo.responseText);
		}
	});
	requestOldRegisteredUserInfo.open("POST", GetOldRegisteredUserInfoPHP, true);
	requestOldRegisteredUserInfo.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestOldRegisteredUserInfo.send(getInfoParams);
}

const PreRegisterNewUser = () => {
	let cookieStatus = "";
	let firstName = "";
	let lastName = "";
	if(document.getElementById('requesterNames') != 'undefined' && document.getElementById('requesterNames') != null) 
	{ 
		let EmpEMail = document.getElementById('requesterNames').value;
	}
	if(document.getElementById('name') != 'undefined' && document.getElementById('name') != null) 
	{ 
		let EmpEMail = document.getElementById('name').value;
	}
	let EmpEMail = document.getElementById('requesterNames').value;
	GetNewRegisteredUserInfo(EmpEMail,PHPFileName,function(RegUserInfo)
	{
		let i = 0;
		const obj = JSON.parse(RegUserInfo);
		const arrayLength = obj.NewUser.length;
		let EmplID = obj.NewUser[i].EmpID
		let PrefFName = obj.NewUser[i].PrefFName
		let PrefLName = obj.NewUser[i].PrefLName
		let GivenName = obj.NewUser[i].GivenName
		let SurName = obj.NewUser[i].SurName
		if(PrefFName != '') { firstName = PrefFName; } else { firstName = GivenName; }
		if(PrefLName != '') { lastName = PrefLName; } else { lastName = SurName; }
		let Name = firstName + ' ' + lastName;
		// Modify the CreateRegisterHTML.php script to take away the update WebNewUsers portion. 
		// This will be done by the Grant_One_Time_OneDriveFoleAccess.ps1 script.
		// CreatePreRegisterHTML(Name,EmplID);
	});
	
	top.mainpanel.location='http://idmgmtapp01/webpages/successlogin.htm';
	let form = document.getElementById('AddUserToPortal');
	form.submit();
}

const RegisterNewUser = () => {
	let cookieStatus = "";
	let firstName = "";
	let lastName = "";
	if(document.getElementById('name') != 'undefined' && document.getElementById('name') != null) 
	{ 
		let EmpEMail = document.getElementById('name').value;
		GetOldRegisteredUserInfo(EmpEMail,GetOldRegisteredUserInfoPHP,function(OldUserInfo)
		{
			let i = 0;
			const obj = JSON.parse(OldUserInfo);
			const arrayLength = obj.NewUser.length;
			let EmplID = obj.NewUser[i].EmpID
			let PrefFName = obj.NewUser[i].PrefFName
			let PrefLName = obj.NewUser[i].PrefLName
			let GivenName = obj.NewUser[i].GivenName
			let SurName = obj.NewUser[i].SurName
			if(PrefFName != '') { firstName = PrefFName; } else { firstName = GivenName; }
			if(PrefLName != '') { lastName = PrefLName; } else { lastName = SurName; }
			let Name = firstName + ' ' + lastName;

			// Now let's check to see if the user's cookie exist.
			let user = getCookie("ProdEmpID");
			if(user == '' || user == null)
			{
				setCookie("ProdEmpID",EmplID, 365);
				LogInitialVisit();
			
				// We create the encrypted key ahead of time in the CreateEncryptedKey.exe PowerShell script.
				RetrieveEncryptedKey(EmplID,RetrieveInitialEncryptedKey,function(thisEncryptedKey)
				{
					thisEncryptedKey = thisEncryptedKey.trim();
					setCookie("ProdEncryptedKey",thisEncryptedKey, 365);
				});
				CookieStatus = 3;
			}
			else
			{
				CookieStatus = 1;
			}
			// Modify the CreateRegisterHTML.php script to take away the update WebNewUsers portion. 
			// This will be done by the Grant_One_Time_OneDriveFoleAccess.ps1 script.
			CreateRegisterHTML(Name,EmplID,CookieStatus);
		});
	}
	else
	{
		// If program control gets here, there was no e-mail name passed in the selection menu.
		CookieStatus = 6;
	}
	top.mainpanel.location='http://idmgmtapp01/webpages/Register.htm';
	let form = document.getElementById('RegisterCookie');
	form.submit();
}

const UpdateUserSettings = () => {
	let ActivateButton = '';
	let thisEmpID = '';
	let thisODDAccessLevel = '';
	let thisADACAccessLevel = '';
	let thisTERMAccessLevel = '';
	let thisAuthorized = '';
	let thisAdminAccess = '';
	let ODDAccessLevel = '';
	let ADACAccessLevel = '';
	let TERMAccessLevel = '';
	
	for(i=1;i<=5000;i++)
	{
		thisEmpID = 'EmpID' + i;
		thisODDAccessLevel = 'ODDAccessLevel' + i;
		thisADACAccessLevel = 'ADACAccessLevel' + i;
		thisTERMAccessLevel = 'TERMAccessLevel' + i;
		thisAuthorized = 'Authorized' + i;
		thisAdminAccess = 'AdminAccess' + i;
		
		// End the loop once we run out of registered users.
		if(document.getElementById(thisEmpID) === 'undefined' || document.getElementById(thisEmpID) === null) { break;}
		
		// Set the variables assigned by value levels.
		let EmpID = document.getElementById(thisEmpID).value;

		// Set the checkbox variables.
		
		// One Drive Delegation
		document.getElementById(thisODDAccessLevel).addEventListener("change", function() {
			if (this.checked) 
			{ 
				ActivateButton = "Yes"
			}
			else
			{
				ActivateButton = "No"
			}
			
			let ApplicationCheckBox = "OneDriveDelegation";
			var params = 'EmpID=' + EmpID + '&ApplicationCheckBox=' + ApplicationCheckBox + '&ActivateButton=' + ActivateButton;
			var xhr = new XMLHttpRequest();
			xhr.open("POST",UpdateUserApplicationSettingsURL, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.send(params);
		});
		
		// AD Account Creation
		document.getElementById(thisADACAccessLevel).addEventListener("change", function() {
			if (this.checked) 
			{ 
				ActivateButton = "Yes"
			}
			else
			{
				ActivateButton = "No"
			}
			
			let ApplicationCheckBox = "ADAccountCreation";
			var params = 'EmpID=' + EmpID + '&ApplicationCheckBox=' + ApplicationCheckBox + '&ActivateButton=' + ActivateButton;
			var xhr = new XMLHttpRequest();
			xhr.open("POST",UpdateUserApplicationSettingsURL, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.send(params);
		});
		
		// Terminate Associate
		document.getElementById(thisTERMAccessLevel).addEventListener("change", function() {
			if (this.checked) 
			{ 
				ActivateButton = "Yes"
			}
			else
			{
				ActivateButton = "No"
			}
			
			let ApplicationCheckBox = "TerminateAssociate";
			var params = 'EmpID=' + EmpID + '&ApplicationCheckBox=' + ApplicationCheckBox + '&ActivateButton=' + ActivateButton;
			var xhr = new XMLHttpRequest();
			xhr.open("POST",UpdateUserApplicationSettingsURL, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.send(params);
		});
		
		// Authorized to use Admin Portal
		document.getElementById(thisAuthorized).addEventListener("change", function() {
			if (this.checked) 
			{ 
				ActivateButton = "Yes"
			}
			else
			{
				ActivateButton = "No"
			}
			
			let ApplicationCheckBox = "Authorized";
			var params = 'EmpID=' + EmpID + '&ApplicationCheckBox=' + ApplicationCheckBox + '&ActivateButton=' + ActivateButton;
			var xhr = new XMLHttpRequest();
			xhr.open("POST",UpdateUserApplicationSettingsURL, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.send(params);
		});
		
		// User has housekeeping admin access
		document.getElementById(thisAdminAccess).addEventListener("change", function() {
			if (this.checked) 
			{ 
				ActivateButton = "Yes"
			}
			else
			{
				ActivateButton = "No"
			}
			
			let ApplicationCheckBox = "AdminAccess";
			var params = 'EmpID=' + EmpID + '&ApplicationCheckBox=' + ApplicationCheckBox + '&ActivateButton=' + ActivateButton;
			var xhr = new XMLHttpRequest();
			xhr.open("POST",UpdateUserApplicationSettingsURL, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.send(params);
		});
	}
}

const UpdateApplicationSettings = () => {
	let thisApplication = '';
	let thisAccessLevel = '';
	let thisAuthorized = '';
	let thisAdminAccess = '';
	for(i=1;i<=5000;i++)
	{
		thisApplication = 'Application' + i;
		thisAccessLevel = 'AccessLevel' + i;
		thisApplicationURL = 'ApplicationURL' + i;
		if(document.getElementById(thisApplication) === 'undefined' || document.getElementById(thisApplication) === null) { break;}
		let Application = document.getElementById(thisApplication).value;
		let AccessLevel = document.getElementById(thisAccessLevel).value;
		var params = 'Application=' + Application + '&AccessLevel=' + AccessLevel;
		var xhr = new XMLHttpRequest();
		xhr.open("POST", UpdateApplicationSettingsURL, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.send(params);
	}
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

// This function builds the buttons we only see within the Admin Portal section of the website.
const DisplayTerminatedAccountsRefresh = (assocID) => {
  top.topmainpanel.location='http://idmgmtapp01/webpages/TermTitlePage.html';
	var int = self.setInterval(function ()
	{
		DisplayTerminatedAccounts(assocID);
	}, 1000);
}

function DisplayTerminatedAccounts(assocID)
{
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
}

const ExecuteTermination = (assocID) => {
	// Called by the ProcessTermination.pl script.
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
	let EmpID = getCookie("ProdEmpID");
	let params = 'EmpID=' + EmpID + '&SrchAssocID=' + assocID;
	var xhr;
	xhr = new XMLHttpRequest();
	xhr.open("POST", StoreEmployeeIDSearchStringPHPFile, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send(params);	
}

// Called by the SearchBoxes.html file.
const UpdateSearchRecords = () => {
	let EmpID = getCookie("ProdEmpID");
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

const InitialRequesterDropDownList = () => {
	let dropDownData2 = '';
	const request = new XMLHttpRequest();
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
	request.open("GET", InitialRequesterDropDownListPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	request.send();	
}

const JobCodeDropDownList = () => {
	let dropDownData2 = '';
	const request = new XMLHttpRequest();
	request.addEventListener('readystatechange', () => {
		if(request.readyState === 4 && request.status === 200) {
			// Populate the str variable with the extracted JSON data.
			const str = request.responseText;
			const obj = JSON.parse(str);
			const arrayLength = obj.JSON_JobCode.length; 
			for(let i=0;i<arrayLength;i++)
			{
				dropDownData2 += "<option value='" + obj.JSON_JobCode[i].jobCode  + "'>" + obj.JSON_JobCode[i].PositionName + "</option>";
			}
			document.getElementById('jobDescription').innerHTML = dropDownData2;
		}
	});
	request.open("GET", JobCodeDropDownListPHPFile, true);
	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
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
			document.getElementById("ODDFinishMsg1").setAttribute("class", "ODD_Finish_Msgs");
			document.getElementById("ODDFinishMsg2").innerText = obj.oddstats[i].msg2;
			document.getElementById("ODDFinishMsg2").setAttribute("class", "ODD_Finish_Msgs");				
		}
	});
	self.setInterval(() => PullODDProgress(request),400)
}

function PullODDProgress(request)
{
    request.open("GET", StatusOfODDProgressPHPFile, true);
    request.send();
}

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

const ModifyUsersRoles = (Counter) => {
	let thisEmpID = 'EmpID' + Counter;
	let thisName = 'Name' + Counter;
	let thisDeleteUser = 'deleteuser' + Counter;
	let NameToDelete = document.getElementById(thisName).value;
	let EmpIDToDelete = document.getElementById(thisEmpID).value;
	document.getElementById(thisDeleteUser).checked = true;
	let response = confirm("Are you sure you want to delete " + NameToDelete + " ?");
	document.getElementById(thisDeleteUser).checked = true;
	if(response == true)
	{
		// To remove the user, we need to perform four steps:
		
		// 1. Delete the user's entry from the WebNewUsers table.
		// 2. Delete the user's entry from the WebUserRoles table.
		// 3. Recreate the CreateModifyUserAttributesPage.txt file
		// 4. Post the form to CreateModifyUserAttributesPage.pl 
		
		txt = "Deleting user";
		// Call DeleteUserFromAdminPortal.php script | Use DeleteUserFromAdminPortalURL and pass the EmpID parameter.
		var params = 'EmpID=' + EmpIDToDelete;
		var xhr = new XMLHttpRequest();
		xhr.open("POST", DeleteUserFromAdminPortalURL, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.send(params);
		
		// Call CreateModifyUserAttributesPage.php script Use CreateModifyUserAttributesPageURL with no parameters
		var params = 'illegalAccess=' + 'No';
		var xhr = new XMLHttpRequest();
		xhr.open("POST", CreateModifyUserAttributesPageURL, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.send(params);
		
		// Now post the form
		let form = document.getElementById("ModifyUsersRole");
		form.submit();
	}
	else
	{
		document.getElementById(thisDeleteUser).checked = false;
		txt = "User not deleted";
	}
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

const ShowNotAuthorizedMsg = () => {
	top.mainpanel.location='http://idmgmtapp01/webpages/NotAuthorized.html';
	top.leftpanel.location='http://idmgmtapp01/webpages/quicklinks.html';
}

/*
===================================================================================================
|                                 Section Ten: Graphical Functions                                |
=================================================================================================== 

----------------------------------------------------------------------------------------
|    Pie chart representing breakdown of number of associates in each Business Unit.   |
---------------------------------------------------------------------------------------- */

const PullBUData = (returnBUListing) => {
	const BUListing = [];
	const requestBUListing = new XMLHttpRequest();
	requestBUListing.addEventListener('readystatechange', () => {
		if(requestBUListing.readyState === 4 && requestBUListing.status === 200) 
		{
			const str = requestBUListing.responseText;
			const obj = JSON.parse(str);
			let arrayLength = obj.ListOfBUNumbers.length;
			var detailLine = '';
			for(let i=0;i<arrayLength;i++)
			{
				BUName = obj.ListOfBUNumbers[i].BUName;
				BUNumber = obj.ListOfBUNumbers[i].BUNumber;
				let BUElement = {x: BUName, value: BUNumber};
				BUListing.push(BUElement);
			}
			returnBUListing(BUListing);
		}
	});
	requestBUListing.open("GET", PullBUListingURL, true);
	requestBUListing.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestBUListing.send();
}

function CreateBUChart() {
	anychart.onDocumentReady(function() {

		// create the chart
		var chart = anychart.pie();

		// set the chart title
		chart.title("Breakdown of Active Employee Enrollments Based on Business Unit");
		
		// Set chart design
		chart.fill("aquastyle");
	
		// set legend position
		chart.legend().position("right");
	
		// set items layout
		chart.legend().itemsLayout("vertical");
		
		var background = chart.background();
		background.stroke('2 #0F0141');
		background.corners(10);
		background.fill({
			keys: [
				'#0F0141 0.2',
				'#FFE082',
				'#0F0141 0.2'
			],
			angle: -90
		});
	
		// Pull the data from the PullBUData.php script
		PullBUData(function(data)
		{
			// add the data
			chart.data(data);

			// display the chart in the BUContainer
			chart.container('BUContainer');
			chart.draw();
		});
	});
}

/*
----------------------------------------------------------------------------------------
|  Line chart representing employee enrollment change since the beginning of the year. |
---------------------------------------------------------------------------------------- */

const PullWGData = (returnGrowthListing) => {
	const GrowthListing = [];
	const requestGrowthListing = new XMLHttpRequest();
	requestGrowthListing.addEventListener('readystatechange', () => {
		if(requestGrowthListing.readyState === 4 && requestGrowthListing.status === 200) 
		{
			const str = requestGrowthListing.responseText;
			const obj = JSON.parse(str);
			let arrayLength = obj.ListOfWGNumbers.length;
			var detailLine = '';
			for(let i=0;i<arrayLength;i++)
			{
				let WGName = obj.ListOfWGNumbers[i].WGName;
				let WGNumber = obj.ListOfWGNumbers[i].WGNumber;
				let thisyear = WGName.substr(0,4);
				let thismon = WGName.substr(4,2);
				let thisday = WGName.substr(6,2);
				let month = '';
				switch(thismon)
				{
					case '01':
						month = "January";
						break;
					case '02':
						month = "February";
						break;
					case '03':
						month = "March";
						break;
					case '04':
						month = "April";
						break;
					case '05':
						month = "May";
						break;
					case '06':
						month = "June";
						break;
					case '07':
						month = "July";
						break;
					case '08':
						month = "August";
						break;
					case '09':
						month = "September";
						break;
					case '10':
						month = "October";
						break;
					case '11':
						month = "November";
						break;
					case '12':
						month = "December";
						break;
				}
				let thisDate = month + ' ' + thisday;
				let WGElement = {x: thisDate, value: WGNumber};
				GrowthListing.push(WGElement);
			}
			returnGrowthListing(GrowthListing);
		}
	});
	requestGrowthListing.open("GET", PullGrowthListingURL, true);
	requestGrowthListing.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestGrowthListing.send();
}

function CreateWGChart() {
	anychart.onDocumentReady(function() {

		// create the chart
		var chart = anychart.line();

		// set the chart title
		chart.title("Employee enrollment deviations since the beginning of the year");
	
		// set legend position
		chart.legend().position("right");
	
		// set items layout
		chart.legend().itemsLayout("vertical");
		
		var background = chart.background();
		background.stroke('2 #0F0141');
		background.corners(10);
		background.fill({
			keys: [
				'#0F0141 0.2',
				'#FFE082',
				'#0F0141 0.2'
			],
			angle: -90
		});
	
		// Pull the data from the PullWGData.php script.
		PullWGData(function(data)
		{
			// Add the data to the chart.
			var series = chart.line(data);

			// Display the line chart in the Weekly Growth container.
			chart.container('WGContainer');
			chart.draw();
		});
	});
}

/*
--------------------------------------------------------------------
|  Bar chart representing percentages of Access Reviews completed. |
-------------------------------------------------------------------- */

const PullAccessReviewData = (PullARDataURL,returnARData) => {		
	const requestARData = new XMLHttpRequest();
	requestARData.addEventListener('readystatechange', () => {
		if(requestARData.readyState === 4 && requestARData.status === 200) 
		{
			returnARData(requestARData.responseText);
		}
	});
	requestARData.open("GET", PullARDataURL, true);
	requestARData.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestARData.send();
}

const CreateAccessReviewChart = () => {
	anychart.theme(anychart.themes.darkEarth);
	anychart.onDocumentReady(function() {

		// create the chart

		// Make the bar chart
		// var chart = anychart.bar();
		
		// To make a column chart instead of a bar chart, use: 
		var chart = anychart.column();

		// set the chart title
		chart.title("Access Review Completion Percentages For This Period");
	
		// set legend position
		chart.legend().position("right");
	
		// set items layout
		chart.legend().itemsLayout("vertical");
		
		var background = chart.background();
		background.stroke('2 #0F0141');
		background.corners(10);
		background.fill({
			keys: [
				'#0F0141 0.2',
				'#0F0141',
				'#0F0141 0.2'
			],
			angle: -90
		});
	
		// Pull the data from the PullAccessReviewData.php script
		PullAccessReviewData(PullARDataURL,function(data)
		{
			data = data.trim();
			const objData = JSON.parse(data);
			chart.data(objData);

			// display the chart in the BUContainer
			chart.container('ARContainer');
			chart.draw();
		});
	});
}

/*
===================================================================================================
|                             Section Eleven: Promotion of website code                           |
=================================================================================================== 

----------------------------------------------------------------------------------------
|          Create the Promote application menu and subsequent functionality.           |
---------------------------------------------------------------------------------------- */

// This function builds the buttons we only see within the Admin Portal section of the website.

const KickOffPromotion = () => {
	sendGoodRequest = new XMLHttpRequest();
	sendGoodRequest.open("POST", KickOffPromotionURL, true);
	sendGoodRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	sendGoodRequest.send();
}

const MonitorPromotionProgressRefresh = () => {
	var int = self.setInterval(function ()
	{
		MonitorPromotionProgress();
	}, 100);
}

function MonitorPromotionProgress()
{
	var xhr;
	if (window.XMLHttpRequest)
	{
		xhr = new XMLHttpRequest();
	}
	else if (window.ActiveXObject)
	{
		xhr = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xhr.open("GET", DisplayPromotionProgressURL, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.send();
	xhr.onreadystatechange = display_Promote_detaildata;

	function display_Promote_detaildata()
	{
		if (xhr.readyState == 4)
		{
			if (xhr.status == 200)
			{
				var str = xhr.responseText;
				const obj = JSON.parse(str);
				let arrayLength = obj.PromotionData.length;
				var detailLine = '';
				for(let i=0;i<arrayLength;i++)
				{
					status = obj.PromotionData[i].status;
					task = obj.PromotionData[i].task;
					message = obj.PromotionData[i].message;
					percentage = obj.PromotionData[i].percentage;
					started = obj.PromotionData[i].started;
					completed = obj.PromotionData[i].completed;
					Header1 = obj.PromotionData[i].Header1;
					Header2 = obj.PromotionData[i].Header2;
					Header3 = obj.PromotionData[i].Header3;
					Header4 = obj.PromotionData[i].Header4;
					Header5 = obj.PromotionData[i].Header5;
					MainHeader = obj.PromotionData[i].MainHeader;
					document.getElementById('task').innerText = task;
					document.getElementById('message').innerText = message;
					document.getElementById('starttime').innerText = started;
					document.getElementById('stoptime').innerText = completed;
					document.getElementById('Header1').innerText = Header1;
					document.getElementById('Header2').innerText = Header2;
					document.getElementById('Header3').innerText = Header3;
					document.getElementById('Header4').innerText = Header4;
					document.getElementById('Header5').innerText = Header5;
					document.getElementById('MainHeader').innerText = MainHeader;
					document.getElementById("task").setAttribute("class", "WhiteText_P18");
					document.getElementById("Header5").setAttribute("class", "WhiteText_P18");
					document.getElementById("starttime").setAttribute("class", "WhiteText_P18");
					document.getElementById("stoptime").setAttribute("class", "WhiteText_P18");
					document.getElementById("Header1").setAttribute("class", "NoticeBlueUnderline");
					document.getElementById("Header2").setAttribute("class", "NoticeBlueUnderline");
					document.getElementById("Header3").setAttribute("class", "NoticeBlueUnderline");
					document.getElementById("Header4").setAttribute("class", "NoticeBlueUnderline");
					document.getElementById("MainHeader").setAttribute("class", "MainHeader");
					
					console.log('status = [' + status + ']');
					switch(status)
					{
						case "Complete":
							document.getElementById("message").setAttribute("class", "PromoteMessage_Green");
							break;
						case "Running":
							document.getElementById("message").setAttribute("class", "PromoteMessage_Orange");
							break;
						default:
							document.getElementById("message").setAttribute("class", "PromoteMessage_Orange");
							break;
					}
				}
			}
		}
	}
}

const GetPromoteApplicationURL = (application,GetPromoteApplicationURLValues,returnApplicationURL) => {		
	let applicationURL = "";
	let getInfoParams = 'application=' + application;
	const requestApplicationURL = new XMLHttpRequest();
	requestApplicationURL.addEventListener('readystatechange', () => {
		if(requestApplicationURL.readyState === 4 && requestApplicationURL.status === 200) 
		{
			returnApplicationURL(requestApplicationURL.responseText);
		}
	});
	requestApplicationURL.open("POST", GetPromoteApplicationURLValues, true);
	requestApplicationURL.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestApplicationURL.send(getInfoParams);
}

// Check if current user is authorized to perform administrative tasks.
const CreatePromoteHTMLResponse = (application) => {
	GetPromoteApplicationURL(application,GetPromoteApplicationURLValues,function(applicationURL)
	{
		let EmployeeID = getCookie("ProdEmpID");
		console.log('EmployeeID = [' + EmployeeID + ']');
		console.log('Accessing ' + applicationURL);
		PullListOfAdminUsers(function(GetAdminUserList)
		{
			if(GetAdminUserList.includes(EmployeeID))
			{
				// User is eligable to make Housekeeping administrative changes.
				let illegalAccess = "No";
				switch(application)
				{
					case "Promote":
						top.topmainpanel.location='http://idmgmtapp01/webpages/PromoteTopPanel.htm';
						break;
					case "Revert":
						top.topmainpanel.location='http://idmgmtapp01/webpages/ModifyUsersTitleBar.htm';
						break;
					case "GIT":
						top.topmainpanel.location='http://idmgmtapp01/webpages/RestoreWebsiteData.htm';
						break;
				}
				CallNonUserBasedApplication(illegalAccess,applicationURL);
			}
			else
			{
				// User is NOT eligable to make Housekeeping administrative changes.
				let illegalAccess = "Yes";
				console.log('Access not allowed to ' + applicationURL);
				CallNonUserBasedApplication(illegalAccess,applicationURL);
			}
		});
	});	
}

const BuildPromotionSelectionButtons = (applicationName) => {		
	let FunctionName = "";
	let FunctionID = "";
	let Value = "";
	let Image = "";
	let Width = "";
	let Height = "";
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
				Value = obj.ApplicationValues[i].FunctionID;
				OnClick = obj.ApplicationValues[i].OnClick;
				Image = obj.ApplicationValues[i].Image;
				Width = obj.ApplicationValues[i].Width;
				Height = obj.ApplicationValues[i].Height;
				let Link = "<input id='Submit' name='Submit' value='" + Value + "' type='image' src='" + Image + "' width=" +  Width + " height=" +  Height + " align='middle' border='0' onMouseOver='ODD_Description();' onMouseLeave='MainTopDisplay();' onClick='SetShowDescriptionsOff();" + OnClick + "();" + FunctionName + "(id=" + '"' + FunctionID + '"' + ");'>";
				switch(FunctionID)
				{
					case "Promote":
						document.getElementById('Promote').innerHTML = Link;
						break;
					case "Revert":
						document.getElementById('Revert').innerHTML = Link;
						break;
					case "GIT":
						document.getElementById('GIT').innerHTML = Link;
						break;
				}
			}
		}
	});
	requestValues.open("GET", BuildPromoteSelectionButtonsURL, true);
	requestValues.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	requestValues.send();	
}
