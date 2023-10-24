#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CreateRegisterHTML.pl                                                     #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 26, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates the Register for Admin Portal screen.                             #
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

my $query = CGI->new();
#my $EmpEMail = $query->param('requesterNames');
my $EmpEMail = 'dave.jaynes@eversana.com';

my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $EmpID;
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

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
	
# Find out who is doing the termination
$SQLString = "select EMPLID from Profile where Email = '$EmpEMail';";
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$EmpID = $row[0];
}
$dbh->disconnect;
$SQLString = "update WebNewUsers set Registered = 'Yes',Authorized = 'Yes' where EmpID = '$EmpID';";
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$sth = $dbh->prepare($SQLString);
$sth->execute();
$dbh->disconnect;

q{
	This Perl script simply prints the already created HTML code for the 
	"AddUserToPortal" application to the screen.
	All the logic and file creation commands for the One-Drive delegation application
	are found in the CreateRegisterUserDropDown PHP script. That script is located at:

	C:\Apache24\htdocs\php\CreateRegisterUserDropDown.php
};

my $PHP = "C:\\php\\php.exe";
my $CreateRegisterHTMLMenu = "C:\\Apache24\\htdocs\\php\\DisplayCreateRegisterHTML.php";

my $phpOutput = `$PHP $CreateRegisterHTMLMenu`;
print "$phpOutput";
