#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ListAssociates.pl                                                         #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Display the details of the selected Employee ID record.                   #
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
my $Assoc_ID = $query->param('associd');

# This line is for testing purposes only. Please commit out or remove when testing is completed.
#$Assoc_ID = "103257";

# Define database variables
# my $dsn = DBI->connect('dbi:ODBC:DSN=IDMUAT;MARS_Connection=Yes;');
my $dsn = "dbi:ODBC:DSN=ProdDBWebConnection";
my $UltiproADRpt = "Ultipro_ADRpt";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()

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

my $ActiveStatus;
my $AssociateID;
my $FirstName;
my $LastName;
my $PreferredName;
my $ManagersName;
my $JobTitle;
my $HomeDept;

# Now kick off DisplayAssociateListings subroutine.
DisplayAssociateListings();

sub DisplayAssociateListings
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	print "</head>\n";
	# print "<BODY onLoad='StoreEmployeeIDSearchString($Assoc_ID)' bgcolor='#0F0141'>\n";
	print "<BODY bgcolor='#0F0141'>\n";

	print "<FORM id='DetailedListings' METHOD='POST' ACTION='/cgi-bin/AssociateTerminations/ProcessTermination.pl'>\n";

	
	my $SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID = '${Assoc_ID}' order by LastName,FirstName;";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$ActiveStatus = $row[0];
		$AssociateID = $row[1];
		$FirstName = $row[2];
		$LastName = $row[3];
		$PreferredName = $row[4];
		$ManagersName = $row[5];
		$JobTitle = $row[6];
		$HomeDept = $row[7];
	}
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleHeader_Gold'>Termination Page for $FirstName $LastName ($Assoc_ID)</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<INPUT id='termrecord' TYPE='hidden' NAME='termrecord' VALUE='$Assoc_ID'>\n";
	print "<INPUT id='termFN' TYPE='hidden' NAME='termFN' VALUE='$FirstName'>\n";
	print "<INPUT id='termLN' TYPE='hidden' NAME='termLN' VALUE='$LastName'>\n";
	#print "<table id='TableWhiteBorder' width='27%' align='center'>\n";
	print "<table width='27%' align='center'>\n";
	print "</tr>\n";
	print "	<th width='%10' padding='15px'>\n";
	print "		<p class='Gold_P15'>Execute Termination</p>\n";
	print "	<th width='%10' padding='15px'>\n";
	print "		<p class='Gold_P15'>Cancel Termination</p>\n";
	print "	</th>\n";
	print "</tr><tr>\n";
	print "		<td width='%10' align='center'>\n";
	#print "<input id='Submit' name='Submit' value='ODDelegation' type='image' src='http://idmgmtapp01/images/buttons/Submit.jpg' width=100 height=47 align='middle' border='0' onClick='SubmitDetailedListing()>\n";
	#print "		<button class='styledButton' id='Submit' name='Submit' value='Submit' onChange='ExecuteTermination(this)'>Submit</button>\n";
	print "<button class='styledButton' id='Submit' name='Submit' type='submit' value='Submit'>Submit</button>\n";
	print "	</td>\n";
	print "	<td width='%10' align='center'>\n";
	print "<button class='styledButton' id='Submit' name='Submit' type='submit' value='Cancel'>Cancel</button>\n";
	print "	</td>	\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br><br><br>\n";
	
	print "<table width='100%'>\n";
	print "<tr>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Associate ID</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>First Name</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Last Name</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Preferred Name</p></th>\n";
	print "</tr><tr>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$AssociateID</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$FirstName</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$LastName</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$PreferredName</p></td>\n";
	print "</tr>\n";
	for(my $i = 0;$i < 4;$i++)
	{
		print "<tr>\n";
		print "<td width='25%'>&nbsp</td>\n";
		print "<td width='25%'>&nbsp</td>\n";
		print "<td width='25%'>&nbsp</td>\n";
		print "<td width='25%'>&nbsp</td>\n";
		print "</tr>\n";
	}
	#print "</table>\n";
	#print "<br><br><br><br>\n";
	#print "<table width='100%'>\n";
	print "<tr>\n";
	print "<th width='20%'><p class='GoldText_P17_Underline'>Active Statue</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Manager's Name</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Job Description</p></th>\n";
	print "<th width='25%'><p class='GoldText_P17_Underline'>Home Department</p></th>\n";
	print "</tr><tr>\n";
	print "<td width='14%'><p class='WhiteText_P15_Normal'>$ActiveStatus</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15'_Normal>$ManagersName</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$JobTitle</p></td>\n";
	print "<td width='25%'><p class='WhiteText_P15_Normal'>$HomeDept</p></td>\n";
	print "</tr>\n";
	print "</table>\n";
 
	print "<br><br><br><br>\n";
	
	print "<table width='100%'>\n";
	print "<tr><th><p class='Warning'>WARNING! Please read this message carefully before proceeding!</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br><br>\n";
	
	print "<table width='100%'>\n";
	print "<tr><th><p class='Important'>This utility spawns the Eversana Associate Termination process.</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	
	print "<table width='100%'>\n";
	print "<tr><th><p class='Important'>Unless you are certain this employee should be processed for termination, DO NOT click Submit.</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	
	print "<table width='100%'>\n";
	print "<tr><th><p class='Important'>These is no undoing of this request once it is submitted.</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	
	print "<table width='100%'>\n";
	print "<tr><th><p class='Important'>Once you have verified this associate as a candidate for termination, click Submit to proceed.</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
}
$dbh->disconnect;
print "</form>\n";
print "</body>\n";
print "</html>\n";	