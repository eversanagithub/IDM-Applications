#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: InitiateTables.pl                                                         #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 23, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Quickly initiate all the Web development page tables.                     #
#                                                                                               #
#################################################################################################

# Load external modules
use DBI;
use CGI;
use Time::HiRes qw(sleep);
use POSIX qw/strftime/;
use Term::ANSIColor;
use DateTime;
use File::Spec;
use File::Copy;
use File::Path qw(make_path remove_tree);
use Switch;

my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $dbh;
my $sth;
my $SQLString = "";

#######################
#   Control Center    #
#######################
   DeleteAllTables(); #
   CreateAllTables(); #
#######################

sub DeleteAllTables
{
	DeleteWebAdminPortalApplicationURL();
	DeleteWebAdminPortalLoginDetails();
	DeleteWebBuildHousekeepingButtons();
	DeleteWebBuildMainSelectionButtons();
	DeleteWebBuildSelectionButtons();
	#DeleteWebDelegatesAlreadyProcessed();
	DeleteWebEncryptedKeys();
	DeleteWebHousekeepingApplicationURL();
	DeleteWebIDMWebsiteLoggedEvents();
	DeleteWebLatestWebUserDTG();
	DeleteWebMainApplicationURL();
	DeleteWebNewUsers();
	DeleteWebProcessAccessRequest();
	DeleteWebRegisteredUsers();
  DeleteWebRequests();
	DeleteWebSearchFields();
	DeleteWebStatusOfODDProgress();
	DeleteWebUserRoles();
	DeleteWebWhoAmI();
}

sub CreateAllTables
{
	CreateWebAdminPortalApplicationURL();
	CreateWebAdminPortalLoginDetails();
	CreateWebBuildHousekeepingButtons();
	CreateWebBuildMainSelectionButtons();
	CreateWebBuildSelectionButtons();
	#CreateWebDelegatesAlreadyProcessed();
	CreateWebEncryptedKeys();
	CreateWebHousekeepingApplicationURL();
	CreateWebIDMWebsiteLoggedEvents();
	CreateWebLatestWebUserDTG();
	CreateWebMainApplicationURL();
	CreateWebNewUsers();
	CreateWebProcessAccessRequest();
	CreateWebRegisteredUsers();
  CreateWebRequests();
	CreateWebSearchFields();
	CreateWebStatusOfODDProgress();
	CreateWebUserRoles();
	CreateWebWhoAmI();
}

#################################################
#			Begin Subroutine Section			#
#################################################

# Delete Tables

sub DeleteWebAdminPortalLoginDetails
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebAdminPortalLoginDetails' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebAdminPortalLoginDetails;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebAdminPortalApplicationURL
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebAdminPortalApplicationURL' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebAdminPortalApplicationURL;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebBuildHousekeepingButtons
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildHousekeepingButtons' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebBuildHousekeepingButtons;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebBuildMainSelectionButtons
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildMainSelectionButtons' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebBuildMainSelectionButtons;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebBuildSelectionButtons
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildSelectionButtons' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebBuildSelectionButtons;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebDelegatesAlreadyProcessed
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebDelegatesAlreadyProcessed' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebDelegatesAlreadyProcessed;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebEncryptedKeys
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebEncryptedKeys' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebEncryptedKeys;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebHousekeepingApplicationURL
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebHousekeepingApplicationURL' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebHousekeepingApplicationURL;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebIDMWebsiteLoggedEvents
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebIDMWebsiteLoggedEvents' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebIDMWebsiteLoggedEvents;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebLatestWebUserDTG
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebLatestWebUserDTG' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebLatestWebUserDTG;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebMainApplicationURL
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebMainApplicationURL' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebMainApplicationURL;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebNewUsers
{
	my $LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;
	
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebNewUsers' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebNewUsers;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebProcessAccessRequest
{
	my $LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;
	
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebProcessAccessRequest' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebProcessAccessRequest;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebRegisteredUsers
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebRegisteredUsers' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebRegisteredUsers;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebRequests
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebRequests' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebRequests;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebSearchFields
{
	$dbh = DBI->connect($dsn);
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebSearchFields' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebSearchFields;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebStatusOfODDProgress
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebStatusOfODDProgress' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebStatusOfODDProgress;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebUserRoles
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebUserRoles' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebUserRoles;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub DeleteWebWhoAmI
{
	$dbh = DBI->connect($dsn);
	
	$SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebWhoAmI' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebWhoAmI;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

# Create Tables

sub CreateWebAdminPortalLoginDetails
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebAdminPortalLoginDetails' AND TABLE_SCHEMA = 'dbo') create table WebAdminPortalLoginDetails(WebUserDTG varchar(15),userID varchar(20),lastName varchar(50),firstName varchar(50),IDActive bit,adminPortalLoginAttempt varchar(15),loginDTG datetime);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebAdminPortalApplicationURL
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebAdminPortalApplicationURL' AND TABLE_SCHEMA = 'dbo') create table WebAdminPortalApplicationURL(application varchar(40),level integer,applicationURL varchar(255));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebAdminPortalApplicationURL(application,level,applicationURL) values ('OneDriveDelegation',3,'http://idmgmtapp01/OneDriveDelegation/php/CreateODDHTMLResponse.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebAdminPortalApplicationURL(application,level,applicationURL) values ('ADAccountCreation',2,'http://idmgmtapp01/ADAccountCreation/php/CreateADACHTMLResponse.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebAdminPortalApplicationURL(application,level,applicationURL) values ('TerminateAssociate',1,'http://idmgmtapp01/AssociateTerminations/php/CreateTERMHTMLResponse.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebBuildHousekeepingButtons
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildHousekeepingButtons' AND TABLE_SCHEMA = 'dbo') create table WebBuildHousekeepingButtons(FunctionName varchar(40),FunctionID varchar(40),MouseOver varchar(40), MouseLeave varchar(40),Image varchar(255),Width int,Height int);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','AddUserToPortal','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/AddUserToPortal.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','ModifyUserAttributes','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/ModifyUserAttributes.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','ModifyApplicationAttributes','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/appattributes.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebBuildMainSelectionButtons
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildMainSelectionButtons' AND TABLE_SCHEMA = 'dbo') create table WebBuildMainSelectionButtons(FunctionName varchar(40),FunctionID varchar(40),MouseOver varchar(40), MouseLeave varchar(40),Image varchar(255),Width int,Height int);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildMainSelectionButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateMainHTMLResponse','adminPortal','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/adminportal.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebBuildSelectionButtons
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildSelectionButtons' AND TABLE_SCHEMA = 'dbo') create table WebBuildSelectionButtons(FunctionName varchar(40),FunctionID varchar(40),Value varchar(40),Image varchar(255), Width integer, Height integer);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','OneDriveDelegation','OneDriveDelegation','http://idmgmtapp01/images/buttons/oddelegation.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','ADAccountCreation','ADAccountCreation','http://idmgmtapp01/images/buttons/adaccountcreation.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','TerminateAssociate','TerminateAssociate','http://idmgmtapp01/images/buttons/terminateassociate.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','DisplayLogs','TerminateAssociate','http://idmgmtapp01/images/buttons/DisplayEventLogs.jpg',200,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebDelegatesAlreadyProcessed
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebDelegatesAlreadyProcessed' AND TABLE_SCHEMA = 'dbo') create table WebDelegatesAlreadyProcessed(Owner varchar(70),Manager bit,URL varchar(255),DelegatedTo varchar(255),DelegatedOn datetime,DelegatedURL varchar(255),DelegationExpires datetime,TargetFolder varchar(100),Valid bit,ReminderModify bit,ReminderSentOn datetime);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub CreateWebEncryptedKeys
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebEncryptedKeys' AND TABLE_SCHEMA = 'dbo') create table WebEncryptedKeys(EmpID varchar(7),UnEncryptedKey varchar(20),EncryptedKey varchar(512));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebEncryptedKeys(EmpID,UnEncryptedKey,EncryptedKey) values ('103257','1232275941','01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000f071b55641ec17231581a5919be095900000000004800000a000000010000000d1fff6040f7070ed19c5c3cbbc08a051180000000273d29bf97b6724bfa9604c4fd2d0e37a1c3656c17832f914000000292f9acdb478c8b017e74199e4b21bb3f8323f76');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebEncryptedKeys(EmpID,UnEncryptedKey,EncryptedKey) values ('103882','1232275941','01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000ae0210419f995caf18f4a58b57efb4730000000004800000a00000001000000085df7ac4fbb6335fb1b94afc537a16fc18000000909fb60595c6896ed8f55397ae6f44a5c7d9427050b2902d14000000e2af722eefb8d9fbc249d41caa79621597617908');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebEncryptedKeys(EmpID,UnEncryptedKey,EncryptedKey) values ('101971','1232275941','01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000628abc218c904144202f770516b8b6220000000004800000a0000000100000005d900db721b35bf8726b28a4d330c4b4180000009ae331fbd24d3879a2738b8cac8354eb6a7ee68ecd2ba36c1400000065e34023301261ae194cf8c80fd4c7af1425a85a');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebEncryptedKeys(EmpID,UnEncryptedKey,EncryptedKey) values ('120441','1232275941','01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c000000010000000a49aa4251e866ff80eeea3fd8aeb39da0000000004800000a000000010000000de3a1f02f825f8b912b1b0151f245cad18000000fcde2ce848293e38e151303582e9ef9cf7a5d8e8d1060f61140000001beeb29a556995b3026a07687830c071f645f8aa');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebEncryptedKeys(EmpID,UnEncryptedKey,EncryptedKey) values ('120405','1232275941','01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ca7fe8542a37a145b17385ab01fd71c40000000002000000000003660000c0000000100000000797d454521a958357bcce45cc6e70a60000000004800000a0000000100000009e442293b63034353ac90120adc7b09318000000039e43c655bbaead38c0541f642db337cd5d0fefd955b8d914000000f9200f6ac4200e062bdf408367d263e61652fbbb');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();	
	
	$dbh->disconnect;
}

sub CreateWebHousekeepingApplicationURL
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebHousekeepingApplicationURL' AND TABLE_SCHEMA = 'dbo') create table WebHousekeepingApplicationURL(application varchar(40),applicationURL varchar(255));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebHousekeepingApplicationURL(application,applicationURL) values ('AddUserToPortal','http://idmgmtapp01/php/BuildWebpageScripts/CreateAddUserToPortalHTMLResponse.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebHousekeepingApplicationURL(application,applicationURL) values ('ModifyUserAttributes','http://idmgmtapp01/php/HousekeepingScripts/CreateModifyUserAttributesPage.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebHousekeepingApplicationURL(application,applicationURL) values ('ModifyApplicationAttributes','http://idmgmtapp01/php/HousekeepingScripts/CreateModifyApplicationAttributesPage.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebIDMWebsiteLoggedEvents
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebIDMWebsiteLoggedEvents' AND TABLE_SCHEMA = 'dbo') create table WebIDMWebsiteLoggedEvents(ExecutedBy varchar(20),application varchar(70),time_of_execution datetime,description varchar(500));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub CreateWebLatestWebUserDTG
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebLatestWebUserDTG' AND TABLE_SCHEMA = 'dbo') create table WebLatestWebUserDTG(WebUserDTG varchar(20));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh = DBI->connect($dsn);
	$SQLString = "insert into WebLatestWebUserDTG(WebUserDTG) values ('20000101000000');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebMainApplicationURL
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebMainApplicationURL' AND TABLE_SCHEMA = 'dbo') create table WebMainApplicationURL(application varchar(40),applicationURL varchar(255));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebMainApplicationURL(application,applicationURL) values ('adminPortal','http://idmgmtapp01/php/BuildWebpageScripts/CreateAdminPortalHTMLResponse.php');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebNewUsers
{
	my $LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;
	
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebNewUsers' AND TABLE_SCHEMA = 'dbo') create table WebNewUsers(EmpID varchar(10),Name varchar(60),EMail varchar(80),AccessLevel integer,Registered varchar(3),Authorized varchar(3),AdminAccess varchar(3),LastLogin datetime);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$SQLString = "insert into WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('103257','Dave Jaynes','dave.jaynes\@eversana.com',1,'Yes','Yes','Yes','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('103882','Ted Schuette','ted.schuette\@eversana.com',2,'No','No','No','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('101971','Nicole Bartelt','nicole.bartelt\@eversana.com',1,'No','No','No','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('120441','ReddiRani TR','reddirani.tr\@eversana.com',1,'No','No','No','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('120405','Sweety Panpatte','sweety.panpatte\@eversana.com',1,'No','No','No','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
		
	$dbh->disconnect;
}

sub CreateWebProcessAccessRequest
{
	my $LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;
	
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebProcessAccessRequest' AND TABLE_SCHEMA = 'dbo') create table WebProcessAccessRequest(RecNo int IDENTITY(1,1) PRIMARY KEY,Employee varchar(70),PersonRequestingAccess varchar(70),Incident varchar(20),Action varchar(10),Status varchar(20),TimeStamp datetime,CurrentlyProcessing bit);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh->disconnect;
}

sub CreateWebRegisteredUsers
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebRegisteredUsers' AND TABLE_SCHEMA = 'dbo') create table WebRegisteredUsers(userID varchar(20),lastName varchar(60),firstName varchar(60),phoneNumber varchar(20),textCode varchar(7),userTextCode varchar(7));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh = DBI->connect($dsn);
	$SQLString = "insert into WebRegisteredUsers(userID,lastName,firstName,phoneNumber,textCode,userTextCode) values ('103257','Jaynes','Dave','5133059762','Empty','Empty');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$dbh = DBI->connect($dsn);
	$SQLString = "insert into WebRegisteredUsers(userID,lastName,firstName,phoneNumber,textCode,userTextCode) values ('103882','Schuette','Ted','2625274493','Empty','Empty');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebRequests
{
 	$dbh = DBI->connect($dsn);

	$dbh = DBI->connect($dsn);
	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebRequests' AND TABLE_SCHEMA = 'dbo') create table WebRequests(status varchar(15),EmpID varchar(15),lastName varchar(50),firstName varchar(50),EMail varchar(50),onedrivedelegation varchar(3),adaccountcreation varchar(3),associatetermination varchar(3));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
  
	$dbh->disconnect;

}

sub CreateWebSearchFields
{
	$dbh = DBI->connect($dsn);

	$dbh = DBI->connect($dsn);
	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebSearchFields' AND TABLE_SCHEMA = 'dbo') create table WebSearchFields(EmpID varchar(15),srchAssocID varchar(20));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh = DBI->connect($dsn);
	$SQLString = "insert into WebSearchFields(EmpID,srchAssocID) values ('000000','empty');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
	
	$dbh->disconnect;
}

sub CreateWebStatusOfODDProgress
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebStatusOfODDProgress' AND TABLE_SCHEMA = 'dbo') create table WebStatusOfODDProgress(pctdone varchar(10),msg varchar(200),msg1 varchar(100),msg2 varchar(200));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$SQLString = "insert into WebStatusOfODDProgress(pctdone,msg,msg1,msg2) values (' ',' ',' ',' ');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebUserRoles
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebUserRoles' AND TABLE_SCHEMA = 'dbo') create table WebUserRoles(EmpID varchar(15),OneDriveDelegation varchar(3),ADAccountCreation varchar(3),TerminateAssociate varchar(3),Authorized varchar(3),AdminAccess varchar(3));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('103257','Yes','Yes','Yes','Yes','Yes');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('103882','Yes','Yes','Yes','Yes','Yes');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('120441','Yes','Yes','Yes','Yes','Yes');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('120405','Yes','Yes','Yes','Yes','Yes');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('101971','Yes','Yes','Yes','Yes','Yes');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebWhoAmI
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebWhoAmI' AND TABLE_SCHEMA = 'dbo') create table WebWhoAmI(WhoAmI varchar(20));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$SQLString = "insert into WebWhoAmI(WhoAmI) values ('Nobody');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

