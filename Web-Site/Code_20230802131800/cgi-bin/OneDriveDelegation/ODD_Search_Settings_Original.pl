#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ODD_Search_Settings.pl                                                    #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 20, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates the One-Drive Delegation associate selection screen.              #
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
my $CGCode = "1";
my $userTextCode = "1";

# SQL Connectivity Variables
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

# Grabs the encrypted username and password for SQL
$AllWorkingWeekRanges = "C:/Apache24/htdocs/credentials/EncryptedCredentials.txt";
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

CheckCodeVerification();

sub CheckCodeVerification
{
	if($userTextCode eq $CGCode)
	{
		DisplaySuccess();
	}
	else
	{
		DisplayFailure();
	}	
}

sub DisplaySuccess
{
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/FormSubmitting_functions.js></script>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/AJAX_functions.js></script>\n";
	print "</head>\n";
	print "<body onLoad='DisplayODDIntro();InitialFormerAssociateDropDownList();InitialRequesterDownList()' bgcolor='#0F0141'>\n";
	print "<FORM id='ViewListings' METHOD='POST' ACTION='/cgi-bin/OneDriveDelegation/GrantOneDriveFolderAccess.pl' target='mainpanel'>\n";
	print "<p class='Gold_P20'>Select the Terminated Associate from the drop-down menu, Enter the Managers E-Mail and Include the Incident Number.</p>\n";

	print "<table width='100%' align='center'>\n";
	print "	<tr>\n";
	print "		<th width='13%' align='center'>\n";
	print "			<p class='WhiteText_P15'>Narrow Associate Listing</p>\n";
	print "		</th>\n";
	print "		<th width='18%' align='center'>\n";
	print "			<p class='WhiteText_P15'>Select former Associate e-mail address</p>\n";
	print "		</th>\n";
	print "		<th width='%13' align='center'>\n";
	print "			<p class='WhiteText_P15'>Narrow Requester Listing</p>\n";
	print "		</th>\n";
	print "		<th width='18%' align='center'>\n";
	print "			<p class='WhiteText_P15'>Select requester e-mail address</p>\n";
	print "		</th>\n";
	print "		<th width='7%' align='center'>\n";
	print "			<p class='WhiteText_P15_Underline'>Add Access</p>\n";
	print "		</th>\n";
	print "		<th width='7%' align='center'>\n";
	print "			<p class='WhiteText_P15_Underline'>Remove Access</p>\n";
	print "		</th>\n";
	print "		<th width='12%' align='center'>\n";
	print "			<p class='WhiteText_P15'>Requesting Incident Number</p>\n";
	print "		</th>\n";
	print "		<th width='10%' align='center'>\n";
	print "			<p class='WhiteText_P15'>Execute Request</p>\n";
	print "		</th>\n";
	print "	</tr>\n";
	print "	<tr>\n";
	print "		<td width='13%' align='center'>\n";
	print "			<input id='assocName' name='assocName' type='text' placeholder='e.g. john.do' onkeyup='UpdateFormerAssociateDropDownList(this);'>\n";
	print "		</td>\n";
	print "		<td width='18%' align='center'>\n";
	print "			<select name='associateNames' id='associateNames'>\n";
	print "				<option value=";
	print '""';
	print "></option>\n";
	print "			</select>\n";
	print "		</td>\n";
	print "		<td width='13%' align='center'>\n";
	print "			<input id='requesterName' name='requesterName' type='text' placeholder='e.g. john.do' onkeyup='UpdateRequesterDropDownList(this);'>\n";
	print "		</td>\n";
	print "		<td width='18%' align='center'>\n";
	print "			<select name='requesterNames' id='requesterNames'>\n";
	print "				<option value=";
	print '""';
	print "></option>\n";
	print "			</select>\n";
	print "		</td>\n";
	print "		<td width='7%' align='center'>\n";
	print "			<input type='radio' id='Action' name='Action' value='ADD' checked>\n";
	print "		</td>\n";
	print "		<td width='7%' align='center'>\n";
	print "			<input type='radio' id='Action' name='Action' value='REMOVE'>\n";
	print "		</td>\n";
	print "		<td width='12%' align='center'>\n";
	print "			<input id='incidentNumber' name='incidentNumber' type='text' placeholder='Leave empty if no incident'>\n";
	print "		</td>\n";
	print "		<td width='10%' align='center'>\n";
	print "			<button class='styledButton' id='Submit' name='Submit' value='Submit' onClick='SubmitODDRequest()'>Submit</button>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "</table>\n";
	print "<table border='0' width=100%>\n";
	print "	<tr>\n";
	print "		<canvas id='myCanvas' width='1600' height='0' style='border:2px solid #DFAB17;'>\n";
	print "	</tr>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";
}

sub DisplayFailure
{
	my $AA = 0;
}
