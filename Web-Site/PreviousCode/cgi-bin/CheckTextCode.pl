#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CheckTextCode.pl                                                          #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Checks to see if the Text Code entered matches the one sent out.          #
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

####################################################################################
###########   S T A R T   V A R I A B L E   D E C L A I R A T I O N    #############
####################################################################################

# CGI Post input variables
my $query = CGI->new();
my $phoneNumber = $query->param('phone');
my $userID = $query->param('userID');
my $firstName = $query->param('firstName');
my $lastName = $query->param('lastName');
my $CGCode = $query->param('code');
my $userTextCode = $query->param('userTextCode');

# SQL Connectivity Variables
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $TextTracking = "TextTracking";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

# Grabs the encrypted username and password for SQL
$AllWorkingWeekRanges = "C:/Apache24/htdocs/Applications/credentials/EncryptedCredentials.txt";
open WorkingWeekFile, "<$AllWorkingWeekRanges" or die;
@All_WorkingDates = <WorkingWeekFile>;
close WorkingWeekFile;
foreach $Reportline (@All_WorkingDates)
{
	@Reportfields = split(';', $Reportline);
	$username = $Reportfields[0];
	$password = $Reportfields[1];
	chomp($username,$password);
}

UpdateTextCodeField();
CheckCodeVerification();

sub UpdateTextCodeField
{
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$SQLString = "update $TextTracking set textCode = '$CGCode' where phoneNumber = '$phoneNumber';";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	$SQLString = "update $TextTracking set userTextCode = '$userTextCode' where phoneNumber = '$phoneNumber';";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	$dbh->disconnect;
}

sub CheckCodeVerification
{
	if($userTextCode eq $CGCode)
	{
		DisplaySuccess();
	}
	else
	{
		DisplayFailure();
	}	
}

sub DisplaySuccess
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/FormSubmitting_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/RollOver_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/AJAX_functions.js></script>\n";
	print "  <link rel='stylesheet' href='http://idmgmtapp01/Applications/css/styles.css'>\n";
	print "</head>\n";
	print "<BODY style=";
	print '"';
	print "background-image: url('http://idmgmtapp01/Applications/images/bluebackground.jpg');";
	print '"';
	print ">\n";
	print "<FORM id='LaunchAdminPortalBuildPage' METHOD='POST' ACTION='/cgi-bin/Applications/LaunchAdminPortalBuildPage.pl' target='_parent'>\n";
	print "<table border=0 style='width:100%'>\n";
	print "	<tr>\n";
	print "		<td align='center'>\n";
	print "<img width=600 height=600 src='http://idmgmtapp01/Applications/images/ThumbsUpLogin.jpg'>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "</table>\n";
	print "<br><br>\n";
	print "<table border=0 style='width:100%' align='center'>\n";
	print "<tr>\n";
	print "<td align='center'>\n";
	print "<p>\n";
	print "<input id='Launched' name='Launched' type='hidden' value='Launched'>\n";
	print "<input id='Submit' name='Submit' type='image' src='http://idmgmtapp01/Applications/images/buttons/ProceedToAdminPortal.jpg' width=200 height=47 align='middle' border='0' onClick='SetShowDescriptionsOff();LaunchAdminPortalBuildPage();'>\n";
	print "</p>\n";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";
}

sub DisplayFailure
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/FormSubmitting_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/RollOver_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/Applications/js/AJAX_functions.js></script>\n";
	print "  <link rel='stylesheet' href='http://idmgmtapp01/Applications/css/styles.css'>\n";
	print "</head>\n";
	print "<BODY style=";
	print '"';
	print "background-image: url('http://idmgmtapp01/Applications/images/bluebackground.jpg');";
	print '"';
	print ">\n";
	print "<table border=0 style='width:100%' align='center'>\n";
	print "	<tr>\n";
	print "		<td align='center'>\n";
	print "<img width=600 height=600 src='http://idmgmtapp01/Applications/images/LoginFailed.jpg'>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "</table>\n";
	print "<br><br>\n";
	print "<table border=0 style='width:100%' align='center'>\n";
	print "<tr>\n";
	print "<td align='center'>\n";
	print "<p>\n";
	print "<a href='http://idmgmtapp01/Applications/index.html' target='_parent'>\n";
	print "<img width=200 height=47 src='http://idmgmtapp01/Applications/images/buttons/ReturnToMainScreen.jpg' onClick='SetShowDescriptionsOff();'>\n";
	print "</a>\n";
	print "</p>\n";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";
}
