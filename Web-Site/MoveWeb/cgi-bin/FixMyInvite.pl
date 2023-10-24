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
my $EMailAddress = 'dave.jaynes@eversana.com';
my $EmplID = "103257";
my $firstName = "Dave";
my $lastName = "Jaynes";
my $accessLevel = "1";
my $adminAccess = "Yes";
my $Space = ' ';
my $FullName = $firstName . $Space . $lastName;

# SQL Connectivity Variables
my $dsn = "dbi:ODBC:DSN=ProdDBWebConnection";
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
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

$HTMLFile = "C:/temp/HTMLInviteFile.txt";
$HTMLFailedFile = "C:/temp/HTMLInviteFailedFile.txt";

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

$dbh = DBI->connect($dsn,$username,$password, \%attr);
$SQLString = "insert into $WebNewUsers(EmpID,Name,AccessLevel,Registered,Authorized,AdminAccess) values ('$EmplID','$FullName','$accessLevel','No','No','$adminAccess');";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$SQLString = "insert into $WebRegisteredUsers(userID,lastName,firstName,phoneNumber,textCode,userTextCode) values ('$EmplID','$lastName','$firstName','0000000000','000000','000000');";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$dbh->disconnect;

open(OutputFile,">$HTMLFile") or die "$!";

print OutputFile "<html>\n";
print OutputFile "<head>\n";
print OutputFile "<link rel='stylesheet' href='http://iuatidmgmtapp01/Applications/css/styles.css'>\n";
print OutputFile "</head>\n";
print OutputFile "<body>\n";
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
print OutputFile "<tr><td><p class='EMailGreeting'>You are receiving this e-mail as you have been identified as someone who required Admin Portal access to the IDM website.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>The IDM website is a new feature within Identity Management which allows our HR and IDM team to easily perform administrative tasks.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Admin Portal access is the advanced set of applications such as Employee Terminations and New Employee Creation in Active Directory.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>You can obtain Admin Portal access by clicking on the Register link below:</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td text-align='center'><a href='http://iuatidmgmtapp01/Applications/Register.html'>Register</a></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>This will take you to the IDM Website Registration page.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Once there, simply select your name from the drop-down list at the top of the page and click on the registration button.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Its that easy! From there, a link is provided to access the main page of the website.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Services provided are listed to the lefdt of the page and can be accessed by clicking on the button labeled with its function.</p></td></tr>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>The Admin Portal section can be accessed by the very top button.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>If you have any further questions, please contact the Identity Management team.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br>\n";
print OutputFile "<table width=100%>\n";
print OutputFile "<tr><td><p class='EMailGreeting'>Thanks ${firstName}!.</p></td></tr>\n";
print OutputFile "</table>\n";
print OutputFile "<br><br>\n";
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
print "<link rel='stylesheet' href='http://iuatidmgmtapp01/Applications/css/styles.css'>\n";
print "</head>\n";
print "<body bgcolor='#0F0141'>\n";
print "<center>\n";
print "<table width=100%>\n";
#print "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
print "</table>\n";
print "</br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='White_P25'>The invite for $firstName $lastName has been issued</p></td></tr>\n";
print "</table>\n";
print "</br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='White_P25'>$firstName will receive an e-mail with instructions on how to proceed.</p></td></tr>\n";
print "</table>\n";
print "<table width=100%>\n";
print "<tr><td><p class='White_P25'>This associate will be added to the appropriate SQL tables with the following attributes:</p></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='White_P25'>Access level: $accessLevel</p></td></tr>\n";
print "<tr><td><p class='White_P25'>Admin Access: $adminAccess</p></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='White_P25'>These changes will happen immediately</p></td></tr>\n";
print "</table>\n";
print "</body>\n";
print "</html>\n";

$Code = `C:\\Apache24\\cgi-bin\\Applications\\SendClientWebsiteInvite.exe $EMailAddress $firstName $lastName`;
