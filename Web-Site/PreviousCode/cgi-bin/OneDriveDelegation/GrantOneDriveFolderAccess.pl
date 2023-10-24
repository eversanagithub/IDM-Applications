#!c:\Strawberry\perl\bin\perl.exe

#######################################################################################
#                                                                                     #
#         Program Name: GrantOneDriveFolderAccess.pl                                  #
#         Date Written: February 12th, 2023                                           #
#           Written By: Dave Jaynes                                                   #
#          Description: Spawns the GrantOneFriveFolderAccess.ps1 script which grants  #
#                       Read-Only access of a former employees One Drive Files.       #
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
my $Employee = $query->param('associateNames');
my $PersonRequestingAccess = $query->param('requesterNames');
my $Action = $query->param('Action');
my $Incident = $query->param('incidentNumber');
my $userID = $query->param('userID');
my $application = $query->param('application');
if($Incident eq '') { $Incident = "No-Incident"; }
chomp($Employee,$PersonRequestingAccess,$Action,$Incident);

my $FormerAssociate;
my $ThisStatus;
my $dbh;
my $sth;
my $row;
my @row = ();

my $thisRecord = 0;
my $Today;
my $ThisStatus;
my $ThisStatusCounter = 0;
my $Count = 'count(*)';
my $ProcessTotals = 0;
my $WhoAmI;

my $DAP = "WebDelegatesAlreadyProcessed";
my $ProcessRequest = "WebProcessAccessRequest";
my $SAP = "WebStatusOfODDProgress";
my $IDMWebsiteLog = "WebIDMWebsiteLoggedEvents";

$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$ProcessRequest' AND TABLE_SCHEMA = 'dbo') CREATE TABLE $ProcessRequest(RecNo int IDENTITY(1,1) PRIMARY KEY,Employee varchar(70),PersonRequestingAccess varchar(70),Incident varchar(20),Action varchar(10),Status varchar(20),TimeStamp datetime,CurrentlyProcessing bit);");
$sth->execute();
$dbh->disconnect;

# Check to ensure the former associate e-mail address entered is actually a 'former associate'.
$FormerAssociate = '';
$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("select Owner from $DAP where Owner = '$Employee';");
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$FormerAssociate = $row[0];
}
$dbh->disconnect;
chomp($FormerAssociate);

# Check to make sure a process for this employee isn't already running.
$ProcessTotals = 0;
$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("select * from $ProcessRequest where Employee = '$Employee' and PersonRequestingAccess = '$PersonRequestingAccess' and CurrentlyProcessing = 1;");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $ProcessTotals++;
}
$dbh->disconnect;
if($ProcessTotals > 0) { exit; }
if($Employee eq $FormerAssociate)
{
	ProcessFileAccessRequest();
}
else
{
	SendWrongFormerAssociate();
}

sub ProcessFileAccessRequest
{
	if($Employee ne '')
	{
		$Today =
		DateTime
		->now( time_zone => 'local' )
		->strftime('%Y-%m-%d %H:%M:%S');
		$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
		$sth = $dbh->prepare("update $SAP set pctdone = '5%',msg = 'Submitting request for $PersonRequestingAccess',msg1 = '',msg2 = '';");
		$sth->execute();
		$dbh->disconnect;
		$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
		$sth = $dbh->prepare("insert into $ProcessRequest(Employee,PersonRequestingAccess,Incident,Action,Status,TimeStamp,CurrentlyProcessing) values ('$Employee','$PersonRequestingAccess','$Incident','$Action','Pending','$Today',1);");
		$sth->execute();
		$dbh->disconnect;
		
		# Find out who is doing the termination
		$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
		$SQLString = "SELECT WhoAmI FROM WebWhoAmI;";
		$sth = $dbh->prepare($SQLString);
		$sth->execute();
		while (@row = $sth->fetchrow_array())
		{
			$WhoAmI = $row[0];
		}
		$dbh->disconnect;
		
		# Log the event
		my $CurrentTimeStamp = DateTime->now;
		$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
		if($Action eq 'ADD')
		{
			$SQLString = "insert into $IDMWebsiteLog(ExecutedBy,application,time_of_execution,description) values('$WhoAmI','One Drive Delegation','$CurrentTimeStamp','Providing ${Employee}&#39s One-Drive Account as Read-Only access to ${PersonRequestingAccess}.');";
		}
		else
		{
			$SQLString = "insert into $IDMWebsiteLog(ExecutedBy,application,time_of_execution,description) values('$WhoAmI','One Drive Delegation','$CurrentTimeStamp','Revoking access of ${Employee}&#39s One-Drive folder from ${PersonRequestingAccess}&#39s account.');";
		}		
		$sth = $dbh->prepare($SQLString);
		$sth->execute();
		$dbh->disconnect;

		print "Content-type: text/html\n\n";
		print "<HTML>\n";
		print "<HEAD>\n";
		print "	<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
		print "	<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
		print "</HEAD>\n";
		print "<BODY bgcolor='#0F0141' onLoad='DisplayIDMBanner();StatusOfODDProcess()'>\n";
		print "<TABLE width='100%'>\n";
		print "	<TR>\n";
		print "		<TD width='100%' align='center'>\n";
		print "			<p class='ODD_P48_Heading'>One Drive Delegation Process Has Started!</p>\n";
		print "		</TD>\n";
		print "	</TR>\n";
		print "</TABLE>\n";
		print "<BR>\n";
		print "<BR>\n";
		print "<TABLE width='100%'>\n";
		print "	<TR>\n";
		print "		<TD width='35%'>&nbsp</TD>\n";
		print "		<TD width='5%' align='right'><p class='Gold_P18'>Pct Done: </P></TD>\n";
		print "		<TD width='5% align='left' id='ODDPctDone'></TD>\n";
		print "		<TD width='1%'>&nbsp</TD>\n";
		print "		<TD width='5%' align='right'><p class='Gold_P18'>Status: </P></TD>\n";
		print "		<TD width='49% align='left' id='ODDStatus'></TD>\n";
		print "	</TR>\n";
		print "</TABLE>\n";
		print "<BR><BR>\n";	
		print "<TABLE width='100%'>\n";
		print "	<TR>\n";
		print "		<TD width='100% align='center' id='ODDFinishMsg1'></TD>\n";
		print "	</TR>\n";
		print "	<TR>\n";
		print "		<TD width='100% align='center' id='ODDFinishMsg2'></TD>\n";
		print "	</TR>\n";
		print "</TABLE>\n";
		print "<BR><BR>\n";
		print "<TABLE width='100%'>\n";
		print "	<TR>\n";
		print "		<TD width='100%' align='center'>\n";
		print "			<img src='http://idmgmtapp01/images/WaitForODD2.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='470' height='400'>\n";
		print "		</TD>\n";
		print "	</TR>\n";
		print "</TABLE>\n";
		print "</BODY>\n";
		print "</HTML>\n";
	}
	else
	{
		print "Content-type: text/html\n\n";
		print "<HTML>\n";
		print "<HEAD>\n";
		print "	<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
		print "	<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
		print "</HEAD>\n";
		print "<BODY bgcolor='#0F0141'>\n";
		print "<TABLE width='100%'>\n";
		print "	<TR>\n";
		print "		<TD width='100%' align='center'>\n";
		print "<img width=900 height=900 src='http://idmgmtapp01/images/IllegalAccess.jpg'>\n";
		print "		</TD>\n";
		print "	</TR>\n";
		print "</TABLE>\n";
		print "</BODY>\n";
		print "</HTML>\n";		
	}

}
