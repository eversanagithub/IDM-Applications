#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ModifyUserAttributes.pl                                                   #
#           Language: Perl v5.16.3                                                              #
#       Date Written: June 14th, 2023                                                           #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Modifies users attributes registered within the IDM website.              #
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

my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $WebNewUsers = "WebNewUsers";
my $dbh;
my $sth;
my $row;
my $username;
my $password;

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

my $AssociateID;
my $Name;
my $AccessLevel;
my $Registered;
my $Authorized;
my $AdminAccess;
my $LastLogin;

# Now kick off DisplayAssociateListings subroutine.
DisplayAssociateListings();

sub DisplayAssociateListings
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	print "</head>\n";
	print "<BODY bgcolor='#0F0141'>\n";
	print "<FORM id='ModifyUserAttributes' METHOD='POST' ACTION='/cgi-bin/AssociateTerminations/ProcessTermination.pl'>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleHeader_Gold'>Modify User Attribute Setting Page</p></th></tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<tr>\n";
	print "<td width='13%'><p class='Heading'>Associate ID</p></td>\n";
	print "<td width='22%'><p class='Heading'>Name</p></td>\n";
	print "<td width='13%'><p class='Heading'>Access LVL</p></td>\n";
	print "<td width='13%'><p class='Heading'>Registered</p></td>\n";
	print "<td width='13%'><p class='Heading'>Authorized</p></td>\n";
	print "<td width='13%'><p class='Heading'>Admin Access</p></td>\n";
	print "<td width='13%'><p class='Heading'>Last Login</p></td>\n";
	print "</tr>\n";
	my $SQLString = "SELECT * FROM $WebNewUsers;";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$AssociateID = $row[0];
		$Name = $row[1];
		$AccessLevel = $row[2];
		$Registered = $row[3];
		$Authorized = $row[4];
		$AdminAccess = $row[5];
		$LastLogin = $row[6];
		print "<tr>\n";
		print "<td width='13%'><p class='Detail'>$AssociateID</p></td>\n";
		print "<td width='22%'><p class='Detail'>$Name</p></td>\n";
		print "<td width='13%'><p class='Detail'>$AccessLevel</p></td>\n";
		print "<td width='13%'><p class='Detail'>$Registered</p></td>\n";
		print "<td width='13%'><p class='Detail'>$Authorized</p></td>\n";
		print "<td width='13%'><p class='Detail'>$AdminAccess</p></td>\n";
		print "<td width='13%'><p class='Detail'>$LastLogin</p></td>\n";
		print "</tr>\n";
	}
	$dbh->disconnect;
	print "</table>\n";
	print "</form>\n";
	print "</body>\n";
	print "</html>\n";	
}
