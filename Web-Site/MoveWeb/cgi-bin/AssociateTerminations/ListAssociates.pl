#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ListAssociates.pl                                                         #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Displays the associates in the TerminateAssocites search listing.         #
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
my $Assoc_ID = $query->param('assocID');
my $First_Name = $query->param('firstName');
my $Last_Name = $query->param('lastName');

# This line is for testing purposes only. Please commit out or remove when testing is completed.
# $Assoc_ID = "103257";

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

my $SQLString;
my $choice = 0;

# Now kick off DisplayAssociateListings subroutine.
DisplayAssociateListings();

sub DisplayAssociateListings
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	print "</head>\n";
	print "<BODY bgcolor='#0F0141'>\n";
	print "<FORM id='ViewDetails' METHOD='POST' ACTION='/cgi-bin/AssociateTerminations/DetailedListing.pl'>\n";
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleHeader_Gold'>Click the Radio button next to the associate you wish to terminate to review their detailed profile</p></th></tr>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<th width='4%'><p class='WhiteText_P15_Underline'>Select</p></th>\n";
	print "<th width='8%'><p class='WhiteText_P15_Underline'>Associate ID</p></th>\n";
	print "<th width='12%'><p class='WhiteText_P15_Underline'>First Name</p></th>\n";
	print "<th width='12%'><p class='WhiteText_P15_Underline'>Last Name</p></th>\n";
	print "<th width='12%'><p class='WhiteText_P15_Underline'>Preferred Name</p></th>\n";
	print "<th width='12%'><p class='WhiteText_P15_Underline'>Active Statue</p></th>\n";
	print "<th width='12%'><p class='WhiteText_P15_Underline'>Manager</p></th>\n";
	print "<th width='14%'><p class='WhiteText_P15_Underline'>Job Title</p></th>\n";
	print "<th width='14%'><p class='WhiteText_P15_Underline'>Home Department</p></th></tr>\n";
 
	# Now let's determine which SQL query to choose based on what parameters were passed via the CGI POST method.
	# We will use the power of 2, accumulating the $choice each time one of the three passed parameters is not empty.
	if($Assoc_ID ne "") { $choice++; }
	if($First_Name ne "") { $choice += 2; }
	if($Last_Name ne "") { $choice += 4; }
 
	# Now, based on the vaule of $choice, we will construct the appropriate SQL command.
 
	
	switch ($choice)
	{
		case 0	 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID = '123456789' order by LastName,FirstName;"; }
		case 1  
		{
			if(length($Assoc_ID) gt 2)
			{
				$SQLString = "SELECT $SelectString FROM $UltiproADRpt where PositionStatus = 'Active' and AssociateID like '${Assoc_ID}%' order by LastName,FirstName;";
			}
			else
			{
				$SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID = '123456789' order by LastName,FirstName;";
			}
		}
		case 2 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where FirstName like '${First_Name}%' order by LastName,FirstName;"; }
		case 3 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID like '${Assoc_ID}%' and FirstName like '${First_Name}%' order by LastName,FirstName;"; }
		case 4 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where LastName like '${Last_Name}%' order by LastName,FirstName;"; }
		case 5 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID like '${Assoc_ID}%' and LastName like '${Last_Name}%' order by LastName,FirstName;"; }
		case 6 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where FirstName like '${First_Name}%' and LastName like '${Last_Name}%' order by LastName,FirstName;"; }
		case 7 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where AssociateID like '${Assoc_ID}%' and FirstName like '${First_Name}%' and LastName like '${Last_Name}%' order by LastName,FirstName;"; }
	}
	#$dbh = DBI->connect('dbi:ODBC:DSN=IDMUAT;MARS_Connection=Yes;');
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	
	$sth = $dbh->prepare($SQLString);

	# Loop through row array again, this time to display the data.
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		my $thisActiveStatus = $row[0];
		my $thisAssoc_ID = $row[1];
		my $thisFirstName = $row[2];
		my $thisLastName = $row[3];
		my $thisPreferredName = $row[4];
		my $thisManagersName = $row[5];
		my $thisJobTitle = $row[6];
		my $thisHomeDept = $row[7];

		chomp($thisActiveStatus,$thisAssoc_ID,$thisFirstName,$thisLastName,$thisPreferredName,$thisManagersName,$thisJobTitle,$thisHomeDept);

	print " <tr>\n";
	print "  <td width='4%' align='center'>\n";
	print "   <input type='radio' id='associd' name='associd' value='";
	print "$thisAssoc_ID";
	print "' onChange='DisplayDetails()'>\n";
	print "  </td>\n";
	print "  <td width='8%'>\n";
	print "   <p class='WhiteText_P15'>$thisAssoc_ID</p>\n";
	print "  </td>\n";
	print "  <td width='12%'>\n";
	print "   <p class='WhiteText_P15'>$thisFirstName</p>\n";
	print "  </td>\n";
	print "  <td width='12%'>\n";
	print "   <p class='WhiteText_P15'>$thisLastName</p>\n";
	print "  </td>\n";
	print "  <td width='12%'>\n";
	print "   <p class='WhiteText_P15'>$thisPreferredName</p>\n";
	print "  </td>\n";
	print "  <td width='12%'>\n";
	print "   <p class='WhiteText_P15'>$thisActiveStatus</p>\n";
	print "  </td>\n";
	print "  <td width='12%'>\n";
	print "   <p class='WhiteText_P15'>$thisManagersName</p>\n";
	print "  </td>\n";
	print "  <td width='14%'>\n";
	print "   <p class='WhiteText_P15'>$thisJobTitle</p>\n";
	print "  </td>\n";
	print "  <td width='14%'>\n";
	print "   <p class='WhiteText_P15'>$thisHomeDept</p>\n";
	print "  </td>\n";
	print " </tr>\n";
	}
	$dbh->disconnect;
	print "</table>\n";
	print "</form>\n";
	print "</body>\n";
	print "</html>\n";
}
