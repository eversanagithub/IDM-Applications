#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CreateInitiateTables.pl                                                   #
#           Language: Perl v5.16.3                                                              #
#       Date Written: July 9, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Restores all the IDM Website SQL tables to a specific point in time.      #
#                     This script is created by the master script below:                        #
#                                                                                               #
#                     C:\Apache24\cgi-bin\DailyTableRecreation.exe                              #
#                                                                                               #
#                     The recovery date for this script is: 2023-07-13                          #
#                                                                                               #
#                     This script should only be run if you need to totally wipe out the        #
#                     existing IDM Website database tables and replace them with the data       #
#                     from the date listed above. This will be a Website data recovery effort.  #
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
	DeleteWebBuildHousekeepingButtons();
}

sub CreateAllTables
{
	CreateWebBuildHousekeepingButtons();
}

#################################################
#            Begin Subroutine Section           #
#################################################

# Delete Tables

sub DeleteWebBuildHousekeepingButtons
{
    $dbh = DBI->connect($dsn);

    $SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildHousekeepingButtons' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebBuildHousekeepingButtons;";
    $sth = $dbh->prepare($SQLString);
    $sth->execute();

    $dbh->disconnect;
}

sub CreateWebBuildHousekeepingButtons
{
    $dbh = DBI->connect($dsn);

    $SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebBuildHousekeepingButtons' AND TABLE_SCHEMA = 'dbo') create table WebBuildHousekeepingButtons(FunctionName varchar(40),FunctionID varchar(40),OnClick varchar(60), MouseOver varchar(40),MouseLeave varchar(40),Image varchar(255),Width int,Height int);";

    $sth = $dbh->prepare($SQLString);
    $sth->execute();

    $SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,OnClick,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','AddUserToPortal','AddUserToPortalInstructions','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/AddUserToPortal.jpg','200','45');";

    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,OnClick,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','ModifyUserAttributes','ModifyUserAttributesInstructions','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/ModifyUserAttributes.jpg','200','45');";

    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $SQLString = "insert into WebBuildHousekeepingButtons(FunctionName,FunctionID,OnClick,MouseOver,MouseLeave,Image,Width,Height) values ('CreateHKHTMLResponse','RestoreWebsiteData','RestoreWebsiteDataInstructions','BlueBlank_Description','initialTopDisplay','http://idmgmtapp01/images/buttons/FullDatabaseRestore.jpg','200','45');";

    $sth = $dbh->prepare($SQLString);
    $sth->execute();

    $dbh->disconnect;
}
