#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: PortalRequestForm.pl                                                      #
#       Date Written: May 29, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates E-Mail responces to requests made for Admin Portal                #
#                     access as sent via the RegistrationForm.html page.                        #                                   
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
my $Space = ' ';
my $Counter = 0;
my $firstName;
my $lastName;
my $SurName;
my $GivenName;
my $FName;
my $LName;
my $EmplID;
my $FullName;
my $FN;
my $LN;
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

my $Associate_EMail_HTMLFile = "C:/Apache24/cgi-bin/HTMLRegistrationRequestResponse.txt";
my $IDM_EMail_HTMLFile = "C:/Apache24/cgi-bin/HTMLRegistrationIDMInfo.txt";
my $HTMLFailedFile = "C:/Apache24/cgi-bin/HTMLInviteFailedFile.txt";
if (-e $Associate_EMail_HTMLFile) { unlink($Associate_EMail_HTMLFile); }
if (-e $IDM_EMail_HTMLFile) { unlink($IDM_EMail_HTMLFile); }
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
$SQLString = "SELECT PrefFName,PrefLName,SURNAME,GIVENNAME,EMPLID from Profile where EMail = '$EMailAddress';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$FN = $row[0];
	$LN = $row[1];
	$SurName = $row[2];
	$GivenName = $row[3];
	$EmplID = $row[4];
}
$dbh->disconnect;
if($FN ne '') { $firstName = $FN } else { $firstName = $GivenName }
if($LN ne '') { $lastName = $LN } else { $lastName = $SurName }
$FullName = $FName . " " . $LastName;
$LastLogin = strftime "%Y-%m-%d %H:%M:%S", localtime;

$Counter = 0;
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$SQLString = "SELECT * from webrequests where EmpID = '$EmplID';";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$Counter++;
}
if($Counter == 0)
{
  $SQLString = "insert into WebRequests(status,EmpID,lastName,firstName,EMail) values ('Pending','$EmplID','$lastName','$firstName','$EMailAddress');";
  $sth = $dbh->prepare($SQLString);
  $sth->execute();
}
$dbh->disconnect;

open(Associate_EMail_File,">$Associate_EMail_HTMLFile") or die "$!";

print Associate_EMail_File "<html>\n";
print Associate_EMail_File "<head>\n";
print Associate_EMail_File "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print Associate_EMail_File "</head>\n";
print Associate_EMail_File "<body bgcolor='white'>\n";
print Associate_EMail_File "<center>\n";
print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "</br>\n";
print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Hi $firstName $lastname,</p></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "</br>\n";
print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>You are receiving this e-mail in response to your registration request for Admin Portal access to the IDM website.</p></td></tr>\n";

print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Once approved and successfully registered, you will be given access to the appropriate applications.</p></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "</br>\n";

print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>You are now recorded in our system as a pending registration.</p></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "<br>\n";
print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Someone from the IDM team will be reaching out to you soon to discuss you access request.</p></td></tr>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>If access is approved, your will be receiving another E-Mail with the registration link in it.</p></td></tr>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Simply click on that link and follow the instructions. Registration is really fast and easy.</p></td></tr>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Again, if you have any further questions please contact a member of the IDM department .</p></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "<br>\n";
print Associate_EMail_File "<table width=100%>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>Thanks $firstName,</p></td></tr>\n";
print Associate_EMail_File "<tr><td><p class='RegistrationResponse3'>The IDM team</p></td></tr>\n";
print Associate_EMail_File "</table>\n";
print Associate_EMail_File "</center>\n";
print Associate_EMail_File "</body>\n";
print Associate_EMail_File "</html>\n";
close Associate_EMail_File;

# E-Mail to IDM Team
open(IDM_EMail_File,">$IDM_EMail_HTMLFile") or die "$!";

print IDM_EMail_File "<html>\n";
print IDM_EMail_File "<head>\n";
print IDM_EMail_File "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print IDM_EMail_File "</head>\n";
print IDM_EMail_File "<body bgcolor='white'>\n";
print IDM_EMail_File "<center>\n";
print IDM_EMail_File "<table width=100%>\n";
print IDM_EMail_File "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
print IDM_EMail_File "</table>\n";
print IDM_EMail_File "</br>\n";
print IDM_EMail_File "<table width=100%>\n";
print IDM_EMail_File "<tr><td><p class='RegistrationResponse3'>IDM Team,</p></td></tr>\n";
print IDM_EMail_File "</table>\n";
print IDM_EMail_File "</br>\n";
print IDM_EMail_File "<table width=100%>\n";
print IDM_EMail_File "<tr><td><p class='RegistrationResponse3'>$firstName $lastName has submitted a registration request for Admin Portal access to the IDM website.</p></td></tr>\n";
print IDM_EMail_File "<br>\n";
print IDM_EMail_File "<table width=100%>\n";
print IDM_EMail_File "<tr><td><p class='RegistrationResponse3'>The associates E-Mail address is $EMailAddress.</p></td></tr>\n";
print IDM_EMail_File "</table>\n";
print IDM_EMail_File "<br>\n";
print IDM_EMail_File "<table width=100%>\n";
print IDM_EMail_File "<tr><td><p class='RegistrationResponse3'>The IDM team</p></td></tr>\n";
print IDM_EMail_File "</table>\n";
print IDM_EMail_File "</center>\n";
print IDM_EMail_File "</body>\n";
print IDM_EMail_File "</html>\n";
close IDM_EMail_File;

# CGI Output back to screen
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print "</head>\n";
print "<body bgcolor='white'>\n";
print "<center>\n";
print "<table width=100%>\n";
print "<tr><td><img src='https://www.eversana.com/wp-content/uploads/2019/05/EmailHeaderTECHNOLOGYComm.png' width='545' height='85'></td></tr>\n";
print "</table>\n";
print "</br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='RegistrationResponse'>Hi $firstName $lastName,</p></td></tr>\n";
print "</table>\n";
print "</br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='RegistrationResponse'>You are receiving this e-mail in response to your registration request for Admin Portal access to the IDM website.</p></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='RegistrationResponse'>You are recorded in our system as a pending registration.</p></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='RegistrationResponse'>Someone from the IDM team will be reaching out to you soon to schedule the official Admin Portal registration timeslot.</p></td></tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width=100%>\n";
print "<tr><td><p class='RegistrationResponse'>Thanks $firstName,</p></td></tr>\n";
print "<tr><td><p class='RegistrationResponse'>The IDM team</p></td></tr>\n";

print "</table>\n";
print "</center>\n";
print "</body>\n";
print "</html>\n";

$Code = `C:\\Apache24\\cgi-bin\\SendRegistrationRequestResponse.exe $EMailAddress $firstName $lastName`;
sleep 10;
$Code = `C:\\Apache24\\cgi-bin\\SendIDMWebsiteRegisterNotice.exe $EMailAddress $firstName $lastName`;
