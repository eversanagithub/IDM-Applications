#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: DisplayAboutThisWebsite.pl                                                #
#           Language: Perl v5.16.3                                                              #
#       Date Written: July 2nd, 2023                                                            #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Displays the history of the IDM web site.                                 #
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
my $query = CGI->new();
my $EventLogs = $query->param('EventLogs');
my $AboutThisWebsite = $query->param('AboutThisWebsite');

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
my @EncryptedCredentialsArray = ();
my @EncryptedCredentialFields = ();
my $EncryptedCredentialLine;
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()
my $AboutThisWebsiteFile = "C:/Apache24/credentials/AboutThisWebsite.txt";
my @AboutThisWebsiteArray = ();
my $AboutThisWebsiteLine;
# Grab the encrypted username and password for SQL
my $EncryptedCredentialsFile = "C:/Apache24/htdocs/credentials/EncryptedCredentials.txt";
open EncryptedCredentialsFile, "<$EncryptedCredentialsFile" or die;
@EncryptedCredentialsArray = <EncryptedCredentialsFile>;
close EncryptedCredentialsFile;
foreach $EncryptedCredentialLine (@EncryptedCredentialsArray)
{
	@EncryptedCredentialFields = split(';', $EncryptedCredentialLine);
	$username = $EncryptedCredentialFields[0];
	$password = $EncryptedCredentialFields[1];
	chomp($username,$password);
}

AboutThisWebsite();

sub AboutThisWebsite
{
	open AboutThisWebsite, "<$AboutThisWebsiteFile" or die;
	@AboutThisWebsiteArray = <AboutThisWebsite>;
	close AboutThisWebsite;
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "</head>\n";
	print "<body  bgcolor='#0F0141'>\n";
	print "<center>\n";
	print "<br>\n";
	print "<table width='100%' border='0'>\n";
	print "<tr>\n";
	foreach $AboutThisWebsiteLine (@AboutThisWebsiteArray)
	{
		chomp($AboutThisWebsiteLine);
		print "<tr><td width='12%'><p class='WebsiteStory'>$AboutThisWebsiteLine</p></td></tr>\n";
	}
	print "</table>\n";
	print "</center>\n";
	print "</body>\n";
	print "</html>\n";
}
