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

my $Output;

$dbh = DBI->connect('dbi:ODBC:DSN=dbAccessReview;MARS_Connection=Yes;');
$SQLString = "delete from WebARData;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$dbh->disconnect;

$dbh = DBI->connect('dbi:ODBC:DSN=dbAccessReview;MARS_Connection=Yes;');
$SQLString = "exec AR_GetAccessReviewNumbers;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$dbh->disconnect;

