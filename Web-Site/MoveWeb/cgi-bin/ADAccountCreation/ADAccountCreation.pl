#!c:\Strawberry\perl\bin\perl.exe

#######################################################################################
#                                                                                     #
#         Program Name: ADAccountCreation.pl                                          #
#         Date Written: May 15th, 2023                                                #
#           Written By: Dave Jaynes                                                   #
#          Description: Spawned by the ADAccountEntry.html form, this script creates  #
#                       a new Active Directory account in the Eversana environment.   #
#                                                                                     #
#######################################################################################

# Load external modules
use DBI;
use CGI;
use DateTime;
use Date::Simple ('date', 'today');
use Date::DayOfWeek;
use DateTime::Format::Strptime qw( );
use Date::Calc qw(Add_Delta_Days);
use Time::HiRes qw(sleep);
use Time::Seconds;
use Time::Piece;
use Date::Parse;
use Time::HiRes qw(sleep);
use POSIX qw(strftime);
use Term::ANSIColor;
use Time::Seconds;
use Time::Piece;
use Date::Calc qw(Add_Delta_Days);

my $query = CGI->new();
my $firstName = $query->param('firstName');
my $lastName = $query->param('lastName');
my $jobDescription = $query->param('jobDescription');
my $manager = $query->param('manager');

chomp($firstName,$lastName,$jobDescription,$manager);

my $dsn = "dbi:ODBC:DSN=ProdDBWebConnection";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString;
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()
my $WhoAmI;

# Grabs the encrypted username and password for SQL
$EncryptedCredentials = "C:/Apache24/htdocs/credentials/EncryptedCredentials.txt";
open EncryptedCredentials, "<$EncryptedCredentials" or die;
@Credentials = <EncryptedCredentials>;
close EncryptedCredentials;
foreach $Reportline (@Credentials)
{
	@Reportfields = split(';', $Reportline);
	$username = $Reportfields[0];
	$password = $Reportfields[1];
	chomp($username,$password);
}

# Find out who the web user is
$SQLString = "SELECT WhoAmI FROM WebProdWhoAmI;";
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$WhoAmI = $row[0];
}
$dbh->disconnect;

#-------------------#
#  Main Processing  #
#-------------------#
LogTheEvent();
#ExecuteStoredProcedure();
SendBackConfirmation();

sub LogTheEvent
{
	# Log the event
	my $CurrentTimeStamp = DateTime->now;
	$SQLString = "insert into WebProdIDMWebsiteLoggedEvents(ExecutedBy,application,time_of_execution,description) values('$WhoAmI','ADAcctCreation','$CurrentTimeStamp','Added user $firstName $lastName to Active Directory');";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	$dbh->disconnect;	
}

sub ExecuteStoredProcedure
{
	$SQLString = "exec AD_Universal_IDMUI_CreateAccount $firstName,$lastName,$jobDescription,$manager;";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
}

sub SendBackConfirmation
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "	<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "	<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	print "</HEAD>\n";
	print "<BODY onLoad='ResetTimer($WhoAmI)' bgcolor='#0F0141'>\n";
	print "<br>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<p class='TitleHeader_Gold'>Account creation for $firstName $lastName is underway!</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<br>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img width=1000 height=500 src='http://idmgmtapp01/images/ADAccountCreated.jpg'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
}