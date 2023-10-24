#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: DisplayEventLogs.pl                                                #
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
use DateTime::Format::Strptime;
use File::Spec;
use File::Copy;
use File::Path qw(make_path remove_tree);
use Switch;

####################################################################################
###########   S T A R T   V A R I A B L E   D E C L A I R A T I O N    #############
####################################################################################

# SQL Connectivity Variables
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $TextTracking = "TextTracking";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";

my $ExecutedBy;
my $Application;
my $TimeOfExecution;
my $TimeOfExecution2;
my $Description;
my $FirstName;
my $LastName;
my $SurName;
my $GivenName;
my $FName;
my $LName;
my $FullName;
my @CentralTime = ();
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

DisplayLogs();

sub DisplayLogs
{
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "</head>\n";
	print "<body  bgcolor='#0F0141'>\n";
	print "<center>\n";
	print "<br>\n";
	print "<table width='100%' border='1'>\n";
	print "<tr>\n";
	print "<th width='12%'><p class='EventLogHeadingLines'>Executed By</p></th>\n";
	print "<th width='15%'><p class='EventLogHeadingLines'>Application</p></th>\n";
	print "<th width='15%'><p class='EventLogHeadingLines'>Time Of Execution (CDT)</p></th>\n";
	print "<th width='58%'><p class='EventLogHeadingLines'>Description</p></th>\n";
	print "</tr>\n";
	print "</tr>\n";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$SQLString = "SELECT i.ExecutedBy,i.application,i.time_of_execution,i.description,p.PrefFName,p.PrefLName,p.SURNAME,p.GIVENNAME from WebIDMWebsiteLoggedEvents i left join Profile p on i.ExecutedBy = p.EMPLID where i.time_of_execution > getdate() - 14 order by i.time_of_execution desc;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$ExecutedBy = $row[0];
		$Application = $row[1];
		$TimeOfExecution3 = $row[2];
		$Description = $row[3];
		$FirstName = $row[4];
		$LastName = $row[5];
		$SurName = $row[6];
		$GivenName = $row[7];
		if($FirstName ne '') { $FName = $FirstName } else { $FName = $GivenName }
		if($LastName ne '') { $LName = $LastName } else { $LName = $SurName }
		$FullName = $FName . " " . $LastName;
		@CentralTime = split('\.',$TimeOfExecution3);
		$TimeOfExecution2 = $CentralTime[0];
		my $format = DateTime::Format::Strptime->new(
			pattern   => '%Y-%m-%d %H:%M:%S',
			time_zone => 'GMT',
			on_error  => 'croak',
		);
		$TimeOfExecution = $format->parse_datetime($TimeOfExecution2);
		$TimeOfExecution->set_time_zone('America/Chicago');
		print "<tr>\n";
		print "<td width='12%'><p class='EventLogDetailLinesCenter'>$FullName</p></td>\n";
		print "<td width='15%'><p class='EventLogDetailLinesCenter'>$Application</p></td>\n";
		print "<td width='15%'><p class='EventLogDetailLinesCenter'>$TimeOfExecution</p></td>\n";
		print "<td width='58%'><p class='EventLogDetailLines'>$Description</p></td>\n";
		print "</tr>\n";
	}
	$dbh->disconnect;
	print "</table>\n";
	print "</center>\n";
	print "</body>\n";
	print "</html>\n";
}
