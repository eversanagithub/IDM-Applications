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

my $dsn = "dbi:ODBC:DSN=ProdDBWebConnection";
my $dbh;
my $sth;
my $SQLString = "";

#######################
#   Control Center    #
#######################
  DeleteAllTables();  #
  CreateAllTables();  #
#######################
DeleteWebIDMWebsiteLoggedEvents();
CreateWebIDMWebsiteLoggedEvents();
sub DeleteAllTables
{
	DeleteWebAdminPortalLoginDetails();
	DeleteWebAdminPortalApplicationURL();
	DeleteWebBuildHousekeepingButtons();
	DeleteWebBuildMainSelectionButtons();
	DeleteWebBuildSelectionButtons();
	DeleteWebDelegatesAlreadyProcessed();
	DeleteWebEncryptedKeys();
	DeleteWebHousekeepingApplicationURL();
	DeleteWebIDMWebsiteLoggedEvents();
	DeleteWebLatestWebUserDTG();
	DeleteWebMainApplicationURL();
	DeleteWebNewUsers();
	DeleteWebProcessAccessRequest();
	DeleteWebRegisteredUsers();
	DeleteWebSearchFields();
	DeleteWebStatusOfODDProgress();
	DeleteWebWhoAmI();
}

sub CreateAllTables
{
	CreateWebAdminPortalLoginDetails();
	CreateWebAdminPortalApplicationURL();
	CreateWebBuildHousekeepingButtons();
	CreateWebBuildMainSelectionButtons();
	CreateWebBuildSelectionButtons();
	CreateWebDelegatesAlreadyProcessed();
	CreateWebEncryptedKeys();
	CreateWebHousekeepingApplicationURL();
	CreateWebIDMWebsiteLoggedEvents();
	CreateWebLatestWebUserDTG();
	CreateWebMainApplicationURL();
	CreateWebNewUsers();
	CreateWebProcessAccessRequest();
	CreateWebRegisteredUsers();
	CreateWebSearchFields();
	CreateWebStatusOfODDProgress();
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
	
	$SQLString = "insert into WebAdminPortalApplicationURL(application,level,applicationURL) values ('OneDriveDelegation',2,'http://idmgmtapp01/OneDriveDelegation/php/CreateODDHTMLResponse.php');";
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
	
	$SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','AddUserToPortal','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/AddUserToPortal.jpg',180,40);";
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
	
	$SQLString = "insert into WebBuildMainSelectionButtons(FunctionName,FunctionID,MouseOver,MouseLeave,Image,Width,Height) values ('CreateMainHTMLResponse','adminPortal','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/adminportal.jpg',150,40);";
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
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','OneDriveDelegation','OneDriveDelegation','http://idmgmtapp01/images/ODDelegation.jpg',132,47);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','ADAccountCreation','ADAccountCreation','http://idmgmtapp01/images/ADAcctCreation.jpg',130,45);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebBuildSelectionButtons(FunctionName,FunctionID,Value,Image,Width,Height) values ('CreateAPApplicationHTMLResponse','TerminateAssociate','TerminateAssociate','http://idmgmtapp01/images/Termination.jpg',134,49);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$dbh->disconnect;
}

sub CreateWebDelegatesAlreadyProcessed
{
	$dbh = DBI->connect($dsn);

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebDelegatesAlreadyProcessed' AND TABLE_SCHEMA = 'dbo') create table WebDelegatesAlreadyProcessed(Owner varchar(70),Manager bit,URL varchar(255),DelegatedTo varchar(255),DelegatedOn datetime,DelegatedURL varchar(255),DelegationExpires datetime,TargetFolder  varchar(100),Valid bit,ReminderModify bit,ReminderSentOn  datetime);";
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

	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebNewUsers' AND TABLE_SCHEMA = 'dbo') create table WebNewUsers(EmpID varchar(10),Name varchar(60),AccessLevel integer,Registered varchar(3),Authorized varchar(3),AdminAccess varchar(3),LastLogin datetime);";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
	$SQLString = "insert into WebNewUsers(EmpID,Name,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('103882','Ted Schuette',1,'No','No','Yes','$LastLogin');";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();

	$SQLString = "insert into WebNewUsers(EmpID,Name,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('103257','Dave Jaynes',1,'No','No','Yes','$LastLogin');";
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

sub CreateWebSearchFields
{
	$dbh = DBI->connect($dsn);

	$dbh = DBI->connect($dsn);
	$SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebSearchFields' AND TABLE_SCHEMA = 'dbo') create table WebSearchFields(EmpID varchar(15),srchAssocID varchar(20));";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	
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

