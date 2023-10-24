#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: SendClientWebsiteInvite.pl                                                #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 29, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Adds new users to database tables and invite email to user.               #
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
my $EMailAddress = $query->param('requesterNames');
my $accessLevel = 1;
my $adminAccess = "No";
my $Space = ' ';
my $PrefFName;
my $PrefLName;
my $GIVENNAME;
my $SURNAME;
my $EmplID;
my $firstName;
my $lastName;
my $FullName;
my $LastLogin;

# SQL Connectivity Variables
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $TextTracking = "TextTracking";
my $dbh;
my $sth;
my $row;
my $WebNewUsers = "WebNewUsers";
my $WebRegisteredUsers = "WebRegisteredUsers";
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my @row = ();
my @EncryptedCredentialsArray = ();
my @EncryptedCredentialFields = ();
my $EncryptedCredentialLine;
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

my $HTMLFile = "C:/Apache24/htdocs/webpages/Registration/HTMLInviteFile.txt";
my $HTMLFailedFile = "C:/Apache24/htdocs/webpages/Registration/HTMLInviteFailedFile.txt";
if (-e $HTMLFile) { unlink($HTMLFile); }
if (-e $HTMLFailedFile) { unlink($HTMLFailedFile); }

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

# Pull the remaining associate data
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$SQLString = "SELECT PrefFName,PrefLName,GIVENNAME,SURNAME,EMPLID from Profile where EMail = '$EMailAddress';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$PrefFName = $row[0];
	$PrefLName = $row[1];
	$GIVENNAME = $row[2];
	$SURNAME = $row[3];
	$EmplID = $row[4];
}
$dbh->disconnect;

if($PrefFName ne '') { $firstName = $PrefFName; } else { $firstName = $GIVENNAME; }
if($PrefLName ne '') { $lastName = $PrefLName; } else { $lastName = $SURNAME; }

$FullName = $firstName . $Space . $lastName;
$LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;

# Nuke and create new WebNewUsers entry.
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$SQLString = "delete from $WebNewUsers where EmpID = '$EmplID';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$SQLString = "insert into $WebNewUsers(EmpID,Name,EMail,AccessLevel,Registered,Authorized,AdminAccess,LastLogin) values ('$EmplID','$FullName','$EMailAddress','$accessLevel','No','Yes','$adminAccess','$LastLogin');";
$sth = $dbh->prepare($SQLString);
$sth->execute();

# Nuke and create new WebRegisteredUsers entry.
$SQLString = "delete from $WebRegisteredUsers where userID = '$EmplID';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$SQLString = "insert into $WebRegisteredUsers(userID,lastName,firstName,phoneNumber,textCode,userTextCode) values ('$EmplID','$lastName','$firstName','0000000000','000000','000000');";
$sth = $dbh->prepare($SQLString);
$sth->execute();

# Nuke and create new WebSearchFields entry.
$SQLString = "delete from WebSearchFields where EmpID = '$EmplID';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$SQLString = "insert into WebSearchFields(EmpID,srchAssocID) values ('$EmplID','Empty');";
$sth = $dbh->prepare($SQLString);
$sth->execute();

# Nuke and create new WebUserRoles entry.
$SQLString = "delete from WebUserRoles where EmpID = '$EmplID';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$SQLString = "insert into WebUserRoles(EmpID,OneDriveDelegation,ADAccountCreation,TerminateAssociate,Authorized,AdminAccess) values ('$EmplID','No','No','Yes','Yes','No');";
$sth = $dbh->prepare($SQLString);
$sth->execute();

$dbh->disconnect;

# Create the encripted key for the new user in the WebEncryptedKeys table.
$CreateEncryptedKey = "c:/Apache24/cgi-bin/CreateEncryptedKey.exe";
my $junk = `$CreateEncryptedKey $EmplID`;

open(OutputFile,">$HTMLFile") or die "$!";

print OutputFile "<html>\n";
print OutputFile "<head>\n";
print OutputFile "<style>\n";
print OutputFile ".bodyBackground {\n";
print OutputFile "	background:white;\n";
print OutputFile "}\n\n";
print OutputFile "p.EMailGreeting {\n";
print OutputFile "	font-family: 'Times New Roman', Times, serif;\n";
print OutputFile "	color: Black;\n";
print OutputFile "	font-size: 20px;\n";
print OutputFile "	font-style: normal;\n";
print OutputFile "	font-weight: normal;\n";
print OutputFile "	text-align: left;\n";
print OutputFile "}\n\n";
print OutputFile "p.EMailFooter {\n";
print OutputFile "	font-family: 'Times New Roman', Times, serif;\n";
print OutputFile "	color: Blue;\n";
print OutputFile "	font-size: 24px;\n";
print OutputFile "	font-style: italic;\n";
print OutputFile "	font-weight: normal;\n";
print OutputFile "	text-align: left;\n";
print OutputFile "}\n\n";
print OutputFile "p.RegisterUser {\n";
print OutputFile "	font-family: 'Times New Roman', Times, serif;\n";
print OutputFile "	color: Blue;\n";
print OutputFile "	font-size: 36px;\n";
print OutputFile "	font-style: italic;\n";
print OutputFile "	font-weight: normal;\n";
print OutputFile "	text-align: left;\n";
print OutputFile "}\n\n";
print OutputFile "</style>\n";
print OutputFile "</head>\n";
print OutputFile "<body class='bodyBackground'>\n";
print OutputFile "<center>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "</br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Hi $firstName,</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "</br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>You are receiving this e-mail as you have been identified as someone who requires Admin Portal access within the IDM website.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>The IDM website is a new feature within Identity Management which allows our HR and IDM team to easily perform administrative tasks.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>The Admin Portal is a secure location where advanced sets of applications such as Employee Termination can be easily utilized.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>To obtain your Admin Portal access, click on the Register link below:</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td width='20%'>&nbsp</td>\n";
print OutputFile "<td width='80%'<a href='http://idmgmtapp01/Register.html'><p class='RegisterUser'>Click Here To Register!</p></a></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>This will take you to the IDM Website Registration page.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Once there, simply select your name from the drop-down list at the top of the page and click on the registration button.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>It&#39s that easy! From there, you will automatically be redirected to the IDM website.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>To enter the Admin Portal once you arive, simply click on the Admin Portal button to the left.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Applications provided are listed from top down and can be accessed by clicking on the button labeled with its function.</p></td></tr>\n";

print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>If you have any further questions, please contact the Identity Management team.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Thanks ${firstName}!.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailFooter'>The Identity Management Team</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "</center>\n";
print OutputFile "</body>\n";
print OutputFile "</html>\n";
close OutputFile;

print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print "</head>\n";
print "<body bgcolor='#0F0141'>\n";
print "<center>\n";
print "<table width=100%>\n";
print "<tr><td align='center'><img src='http://idmgmtapp01/images/AdminTaskBanner.jpg' width='1000' height='68'></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td width='100%'>\n";
print "<p class='RegisteredMessage'>The registration for access to the Admin Portal has just been sent to $FullName.</p></td></tr>\n";
print "</table>\n";
print "</body>\n";
print "</html>\n";

$Code = `C:\\Apache24\\cgi-bin\\SendClientWebsiteInvite.exe $EMailAddress $firstName $lastName`;
