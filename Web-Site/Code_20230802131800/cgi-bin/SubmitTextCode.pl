#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: SubmitTextCode.pl                                                         #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Display the Text Code entry screen.                                       #
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

my $query = CGI->new();
my $phoneNumber = $query->param('userNames');

$Code = `C:\\Apache24\\cgi-bin\\Applications\\sendtext.exe $phoneNumber`;
#$Code = "123456";

my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $TextTracking = "TextTracking";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

# Make the variables public so they can pass their values to the JavaScript function 'LogInitialVisit'.
my $SelectedPhoneNumber;
my $SelectedUserID;
my $SelecredFirstName;
my $SelecredLastName;
my $SelectedCode;
			
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

UpdateTextCodeField();
DisplayAssociateListings();

sub UpdateTextCodeField
{
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$SQLString = "update $TextTracking set textCode = '$Code' where phoneNumber = '$phoneNumber';";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	$dbh->disconnect;
}

sub DisplayAssociateListings
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/FormSubmitting_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/RollOver_functions.js></script>\n";
	print "	<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/AJAX_functions.js></script>\n";
	print "  <link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "</head>\n";
	print "<BODY style=";
	print '"';
	print "background-image: url('http://idmgmtapp01/images/bluebackground.jpg');";
	print '"';
	print ">\n";
	print "<FORM id='SubmitAccessCode' METHOD='POST' ACTION='/cgi-bin/CheckTextCode.pl'>\n";
	print "<br><br>\n";
	print "<table border=0 style='width:100%' align='center'>\n";
	print "<tr>\n";
	print "<td align='center'>\n";
	print "<img width=500 height=375 src='http://idmgmtapp01/images/mainimage.jpg'>\n";
	print "</td>\n";
	print "<tr>\n";
	print "</table>\n";
	print "<br><br><br>\n";
	print "<table border=0 style='width:100%'>\n";
	print "	<tr>\n";
	print "		<td align='center'>\n";
	print "			<p class='White_P25'>You will receive an SMS text with a 6-digit code. Enter that code below and click Submit</p>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "</table>\n";
	print "<br><br>\n";
	print "<table border=0 style='width:100%' align='center'>\n";
	print "	<tr>\n";
	print "		<td width='100%' align='center'>\n";
	print "			<select name='userNames' id='userNames'>\n";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$SQLString = "select * from $TextTracking;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		my $thisUserID = $row[0];
		my $thisLastName = $row[1];
		my $thisFirstName = $row[2];
		my $thisPhoneNumber = $row[3];
		my $thisTextCode = $row[4];
		my $thisUserTextCode = $row[5];
		if($phoneNumber eq $thisPhoneNumber)
		{
			print "<option value = ";
			print '"';
			print "$phoneNumber";
			print '"';
			print " selected>";
			print "$thisFirstName $thisLastName";
			print "</option>\n";
			$SelectedPhoneNumber = $thisPhoneNumber;
			$SelectedUserID = $thisUserID;
			$SelectedFirstName = $thisFirstName;
			$SelectedLastName = $thisLastName;
			$SelectedCode = $thisTextCode;
		}
		else
		{
			print "<option value = ";
			print '"';
			print "$phoneNumber";
			print '"';
			print ">";
			print "$thisFirstName $thisLastName";
			print "</option>\n";
		}
	}
	$dbh->disconnect;
	print "</select>\n";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<table border=0 style='width:100%'>\n";
	print "<tr>\n";
	print "<td width='35%'>&nbsp</td>\n";
	print "<td width='10%'>\n";
	print "<p class='WhiteText_P15_Right'>SMS Code: </p>\n";
	print "</td>\n";
	print "<td width='10%'>\n";
	print "<input id='userTextCode' name='userTextCode' type='text' placeholder='e.g. 123456'>\n";
	print "</td>\n";
	print "<td width='45%'>&nbsp</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<input id='phone' name='phone' type='hidden' value='$SelectedPhoneNumber'>\n";
	print "<input id='userID' name='userID' type='hidden' value='$SelectedUserID'>\n";
	print "<input id='firstName' name='firstName' type='hidden' value='$SelectedFirstName'>\n";
	print "<input id='lastName' name='lastName' type='hidden' value='$SelectedLastName'>\n";
	print "<input id='code' name='code' type='hidden' value='$SelectedCode'>\n";
	print "<br>\n";
	print "<table border=0 style='width:100%'>\n";
	print "<tr>\n";
	print "<td align='center'>\n";
	print "<input id='Submit' name='Submit' type='image' src='http://idmgmtapp01/images/buttons/Submit.jpg' width=75 height=38 align='middle' border='0' onClick='LogInitialVisit()'>\n";
	#print "<input id='Submit' name='Submit' type='radio' onChange='LogInitialVisit()'>\n";
	#print "<button class='styledButton' id='Submit' name='Submit' onChange='LogInitialVisit()'>Submit</button>\n";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";
}
