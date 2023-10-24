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
my $associateName = $query->param('associateNames');
my $requesterName = $query->param('requesterNames');
my $Incident = $query->param('incidentNumber');
#my $associateName = "alexandra.moore@eversana.com";
#my $requesterName = "dave.jaynes@eversana.com";
#my $Incident = "";

if($Incident eq '') { $Incident = "No-Incident"; }
chomp($associateNames,$requesterName,$Incident);

my $ThisStatus;
my $dbh;
my $sth;
my $row;
my @row = ();

my $ExecuteMonitoring = "No";
my $SummaryTableStatus = 0;
my $AdhocTableStatus;
my $ProcessTotals = 0;
my $Started;
my $CurrentCount = 0;
my $SummaryCount = 0;
my $ProcessTotals = 0;
my $PendingEntries;
my $TermedUser;
my $RequestingUser;
my $SummaryTermedUser;
my $SummaryRequestingUser;
my $AlreadyRanCount;
my $CurrentlyRunningCount;
my $WhoAmI;

my $ProcessingTable = "WebAdhocODDProcess";
my $StatusTable = "WebAdhocODDRunSummary";

# Pull the current Date/Time
$Today = DateTime->now( time_zone => 'local' )->strftime('%Y-%m-%d %H:%M:%S');

# Update the WebAdhocODDProcess and WebAdhocODDRunSummary SQL tables with CGI passed information
$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("update $ProcessingTable set TermedUser = '$associateName', RequestingUser = '$requesterName', DateTimeProcessed = '$Today', OverallStatus = 'Pending', CurrentModuleProcessing = 'Waiting';");
$sth->execute();
$sth = $dbh->prepare("insert into $StatusTable(RunDate,Status,TermedUser,RequestingUser) values ('$Today','Pending','$associateName','$requesterName');");
$sth->execute();

#      Here we will do the QA checks on the SQL tables to see if they are ready to process
#    ---------------------------------------------------------------------------------------
#   1. Check to see if this same job has been run before. If so, the requesting user already has access.
#   2. Check to see if this job is currently running. If so, warn the user that job is already running.
#	3. Check to make sure there is only one Pending entry in both the SQL tables.
#	4. Make sure the submitted termed associate and requester are in both SQL tables.
#	5. Check if this job was previously ran on the termed user for another person. 
#      If so, just apply read-only rights to the current requester, don't re-pack the files.

#####################################################################################
# 1. Check to see if this same job has been run before. If so,requesting has access #
#####################################################################################

$sth = $dbh->prepare("select count(*) as count from $StatusTable where Status = 'Completed' and TermedUser = '$associateName' and RequestingUser = '$requesterName';");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $AlreadyRanCount = $row->{count};
}
chomp($AlreadyRanCount);
if($AlreadyRanCount > 0) { DisplayAlreadyRanForThisCombination(); }

#####################################################################################
# 2. Check to see if this job is currently running and alert user if it is.         #
#####################################################################################

$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("select count(*) as count from $ProcessingTable where TermedUser = '$associateName' and RequestingUser = '$requesterName' and (OverallStatus = 'Waiting' or OverallStatus = 'Running');");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $CurrentlyRunningCount = $row->{count};
}
chomp($CurrentlyRunningCount);
if($CurrentlyRunningCount == 1) { DisplayCurrentlyRunning(); }

#####################################################################################
# 3. Check to make sure there is only one Pending entry in both the SQL tables.     #
#####################################################################################

$sth = $dbh->prepare("select count(*) as count from $ProcessingTable where OverallStatus = 'Pending';");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $CurrentCount = $row->{count};
}
chomp($CurrentCount);

# Check to see how many pending entries there are in the $StatusTable table. There should only be one.
$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$sth = $dbh->prepare("select count(*) as count from $StatusTable where Status = 'Pending';");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $SummaryCount = $row->{count};
}
chomp($SummaryCount);

$TotalCount = $CurrentCount + $SummaryCount;
# Alert the user there are no entries for this Termed Associate/Requester combination in the tables.
if($TotalCount == 0) { NoEntriesExistInTables(); }

# Alert the user there is some kind of mis-configuration in the tables that requires manual intervention.
if(($CurrentCount == 1) and ($SummaryCount == 1)) { $PendingEntries = "Good"; } else { MultiplePendingEntriesIssue(); }

#####################################################################################
# 4. Make sure the submitted termed associate and requester are in both SQL tables. #
#####################################################################################

# Pull the Termed user from the Processing table.
$sth = $dbh->prepare("select * from $ProcessingTable where OverallStatus = 'Pending';");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $TermedUser = $row->{TermedUser};
  $RequestingUser = $row->{RequestingUser};
}
chomp($TermedUser);

# Pull the Termed user from the Summary table.
$sth = $dbh->prepare("select * from $StatusTable where Status = 'Pending';");
$sth->execute();
while (my $row = $sth->fetchrow_hashref())
{
  $SummaryTermedUser = $row->{TermedUser};
  $SummaryRequestingUser = $row->{RequestingUser};
}
chomp($SummaryTermedUser);
# Now make sure the Termed and Requesting users match in each table.
if(($TermedUser eq $SummaryTermedUser) and ($RequestingUser eq $SummaryRequestingUser)) { $UsersMatched = "Yes"; } else { MultiplePendingEntriesIssue(); }

#########################################################################
# If program control has made it this far, we have a go for processing! #
#########################################################################

# First let's find out who is doing the ODD processing and log this event.

# Pull the web user's name
$dbh = DBI->connect('dbi:ODBC:DSN=DBWebConnection;MARS_Connection=Yes;');
$SQLString = "SELECT WhoAmI FROM WebWhoAmI;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$WhoAmI = $row[0];
}

# Log the event to the logging table
my $CurrentTimeStamp = DateTime->now;
#$SQLString = "insert into $IDMWebsiteLog(ExecutedBy,application,time_of_execution,description) values('$WhoAmI','One Drive Delegation','$CurrentTimeStamp','Providing ${Employee}&#39s One-Drive Account as Read-Only access to ${PersonRequestingAccess}.');";
#$sth = $dbh->prepare($SQLString);
#$sth->execute();
#$dbh->disconnect;

# Now we will return the HTML code to the Apache Web Service and let the AdhocOneDriveDelegation PowerShell script take over control.
print "Content-type: text/html\n\n";
print "<HTML>\n";
print "<HEAD>\n";
print "	<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print "	<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
print "</HEAD>\n";
print "<BODY bgcolor='#0F0141' onLoad='DisplayIDMBanner();StatusOfODDProcess()'>\n";
print "<center>\n";
print "<div id='ODDImage'></div>\n";
print "</center>\n";
print "</BODY>\n";
print "</HTML>\n";
# For a successful job run, processing ends here for this script.

# The AdhocOneDriveDelegation PowerShell script is launched by the job scheduler
# and updates the OverallStatus and CurrentModuleProcessing fields as it processed
# the users request via the SharePoint PnP commands.

# The StatusOfODDProcess() JavaScript function called in the <BODY> tag of the HTML 
# code pulls the value of the CurrentModuleProcessing SQL field and displays the images
# on the screen by use of the 'CurrentModuleImage' ID tag working in conjunction with JavaScript.

######################################
# Job Exception Subroutine Code Area #
######################################

sub DisplayNoGoMessage
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
	print "			<p class='ODD_P32_Heading'>Attempting to allocate One-Drive accounts files for $associateName to $requesterName</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR><BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img src='http://idmgmtapp01/images/ODDRecordNotFound.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='1200' height='500'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<p class='ODD_P24_Heading_White'>Choose another Former Associate/Requester combination above or choose another application.</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	
}

sub MultiplePendingEntriesIssue
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
	print "			<p class='ODD_P32_Heading'>Attempting to allocate One-Drive accounts files for $associateName to $requesterName</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR><BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img src='http://idmgmtapp01/images/ODDSQLTableEntryProblem.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='1200' height='500'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit 0
}

sub NoEntriesExistInTables
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
	print "			<p class='ODD_P32_Heading'>Attempting to allocate One-Drive accounts files for $associateName to $requesterName</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR><BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img src='http://idmgmtapp01/images/ODDSQLTableNoAssociateEntryProblem.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='1200' height='500'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit 0
}

sub DisplayAlreadyRanForThisCombination
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
	print "			<p class='ODD_P32_Heading'>Attempting to allocate One-Drive accounts files for $associateName to $requesterName</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR><BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img src='http://idmgmtapp01/images/ODDJobAlreadyRanProblem.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='1200' height='500'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit 0
}

sub DisplayCurrentlyRunning
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
	print "			<p class='ODD_P32_Heading'>Attempting to allocate One-Drive accounts files for $associateName to $requesterName</p>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "<BR><BR>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "			<img src='http://idmgmtapp01/images/ODDJobIsCurrentlyRunningProblem.jpg' style='background-color:#0F0141;' alt='Sharepoint' width='1200' height='500'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit 0
}
