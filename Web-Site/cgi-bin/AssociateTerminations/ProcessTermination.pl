#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ProcessTermination.pl                                                     #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Display the AzureEmpInfo table.                                           #
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

# Declare local variables
my $SQLSelected_AssocID;
my $SQLSelected_First_Name;
my $SQLSelected_Last_Name;

# Pull in the HTTP POST valiables
my $query = CGI->new();
my $POST_AssocID = $query->param('termrecord');
my $POST_LN = $query->param('termLN');
my $POST_Submit = $query->param('Submit');
my $firstName;
my $lastName;

# Define database variables
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $UltiproADRpt = "Ultipro_ADRpt";
my $RawADS = "RawADs_VW";
my $dbh;
my $sth;
my $row;
my $username;
my $password;
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my $RawADSelectString = "Domain,sAMAccountName,Enabled,sn,GivenName,DisplayName,whenCreated,whenChanged";
my @row = ();
my %attr = (PrintError=>0, RaiseError=>1);  # turn off error reporting via warn() and turn on error reporting via die()
my $WhoAmI;

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

# Find out who is doing the termination
$SQLString = "SELECT WhoAmI FROM WebWhoAmI;";
$dbh = DBI->connect($dsn,$username,$password, \%attr);
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$WhoAmI = $row[0];
}
$dbh->disconnect;

#####################################################################
#                                                                   # 
#		Decide which button the users clicked: Terminate or Cancel  #
#                                                                   # 
#####################################################################

if($POST_Submit eq 'Submit') { $Action = "Terminate"; }else{ $Action = "Cancel"; }

switch ($Action)
{
	case "Terminate"
	{
		LogTheEvent();
		ProcessTermination();
	}
	case "Cancel"
	{
		ProcessCancel();
	}
	default
	{
		ProcessError();
	}
}

sub LogTheEvent
{
  $dbh = DBI->connect($dsn,$username,$password, \%attr);
  $SQLString = "select top 1 GivenName,sn from RawADs_VW where EmployeeNumber = '$POST_AssocID';";
  $sth = $dbh->prepare($SQLString);
  $sth->execute();
  while (@row = $sth->fetchrow_array())
  {
    $firstName = $row[0];
    $lastName = $row[1];
		$firstName =~ s/'/''/g;
		$lastName =~ s/'/''/g; 
  }
  $dbh->disconnect;

	# Log the event
	my $CurrentTimeStamp = DateTime->now;
	$SQLString = "insert into WebIDMWebsiteLoggedEvents(ExecutedBy,application,time_of_execution,description) values('$WhoAmI','Associate Termination','$CurrentTimeStamp','Gathering necessary information for the termination of $firstName $lastName ($POST_AssocID).');";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	$dbh->disconnect;	
}

sub ProcessTermination
{
	# Create the title header to cover up the input parameters page.
	my $TermTitlePage = "c:/Apache24/htdocs/webpages/TermTitlePage.html";
	if (-e $TermTitlePage) { unlink($TermTitlePage); }	
	open(TermTitlePage,">$TermTitlePage") or die "$!";
	print TermTitlePage "<HTML>\n";
	print TermTitlePage "<HEAD>\n";
	print TermTitlePage "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print TermTitlePage "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	print TermTitlePage "</HEAD>\n";
	print TermTitlePage "<BODY bgcolor='#0F0141'>\n";
	print TermTitlePage "<table width='100%'>\n";
	print TermTitlePage "<tr>\n";
	print TermTitlePage "<th><p class='Gold_P60'>Termination Process For $POST_FN $POST_LN Has Begun</p></th>\n";
	print TermTitlePage "</tr>\n";
	print TermTitlePage "</table>\n";
	print TermTitlePage "<table width='100%'>\n";
	print TermTitlePage "<tr>\n";
	print TermTitlePage "<th><p class='White_P18'>Enabled status will change automatically as the accounts are de-activated. You may also close out this application and the termination process will still continue.</p></th>\n";
	print TermTitlePage "</tr>\n";
	print TermTitlePage "</table>\n";
	print TermTitlePage "<br>\n";
	print TermTitlePage "<table border='0' width=100%>\n";
	print TermTitlePage "<tr>\n";
	print TermTitlePage "<canvas id='myCanvas' width='1600' height='0' style='border:2px solid #DFAB17;'>\n";
	print TermTitlePage "</tr>\n";
	print TermTitlePage "</table>\n";
	print TermTitlePage "</BODY></HTML>\n";
	close TermTitlePage;	
	
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
	print "</head>\n";
	print "<BODY onLoad=";
	print '"';
	print "ExecuteTermination($POST_AssocID);DisplayTerminatedAccountsRefresh($POST_AssocID);ResetTimer($WhoAmI)";
	print '" ';
	print "bgcolor='#0F0141'>\n";
	print "<FORM id='DetailedListings' METHOD='POST' ACTION='/cgi-bin/AssociateTerminations/ProcessTermination.pl'>\n";
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleHeader_Gold'>The following accounts are in the process of being inactivated for $POST_FN $POST_FN ($POST_AssocID)</p></th></tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<table width='100%'>\n";
	print "<tr>\n";
	print "<th width='8%'><p class='WhiteText_P15_Underline'>Domain</p></th>\n";
	print "<th width='8%'><p class='WhiteText_P15_Underline'>SAM Account</p></th>\n";
	print "<th width='8%'><p class='WhiteText_P15_Underline'>Enabled</p></th>\n";
	print "<th width='10%'><p class='WhiteText_P15_Underline'>Last Name</p></th>\n";
	print "<th width='10%'><p class='WhiteText_P15_Underline'>FirstName</p></th>\n";
	print "<th width='18%'><p class='WhiteText_P15_Underline'>Title</p></th>\n";
	print "<th width='19%'><p class='WhiteText_P15_Underline'>Created On</p></th>\n";
	print "<th width='19%'><p class='WhiteText_P15_Underline'>Last Updated</p></th></tr><tr>\n";
	print "</table>\n";
	print "<table id='detailLine' width='100%'>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";	
}

sub ProcessCancel
{
	# We are here because the user clicked on the Cancel button when asked if they wanted to terminate the employee.
	
	# Now we basically re-paint the screen with the same employee listing that were there before a name was selected.
	# Set local scope of SQL variables
	my $Assoc_ID;

	# Grab the search parameters from SQL.
	$SQLString = "SELECT srchAssocID FROM WebSearchFields where EmpID = (select WhoAmI from WebWhoAmI);";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$Assoc_ID = $row[0];
	}
	$dbh->disconnect;
	chomp($Assoc_ID);

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
	my $choice = 0;
	if($Assoc_ID ne "") { $choice = 1; } else { $choice = 0; }
 
	switch ($choice)
	{
		case 0	 { $SQLString = "SELECT $SelectString FROM $UltiproADRpt where PositionStatus = 'Active' and AssociateID = '123456789' order by LastName,FirstName;"; }
		case 1  
		{
			if(length($Assoc_ID) gt 2)
			{
				$SQLString = "SELECT $SelectString FROM $UltiproADRpt where PositionStatus = 'Active' and AssociateID like '${Assoc_ID}%' order by LastName,FirstName;";
			}
			else
			{
				$SQLString = "SELECT $SelectString FROM $UltiproADRpt where PositionStatus = 'Active' and AssociateID = '123456789' order by LastName,FirstName;";
			}
		}
	}

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
