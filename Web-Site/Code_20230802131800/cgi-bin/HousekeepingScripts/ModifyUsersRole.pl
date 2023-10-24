#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ModifyUsersRole.pl                                                        #
#           Language: Perl v5.16.3                                                              #
#       Date Written: June 14th, 2023                                                           #
#         Written by: Dave Jaynes                                                               #
#            Purpose: This script is used specifically to delete a user and is                  #
#                     called from the CreateModifyUserAttributesPage.php script.                #
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
my $AssocID = $query->param('deleteuser');
my $EmployeeNum = $query->param('EmployeeNum');
my $deleteuser = $query->param('deleteuser');
my $ODDAccessLevel = $query->param('ODDAccessLevel');
my $ADACAccessLevel = $query->param('ADACAccessLevel');
my $TERMAccessLevel = $query->param('TERMAccessLevel');

# Begin testing area
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/UserModStyles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	print "</head>\n";
	print "<BODY bgcolor='#0F0141'>\n";
	print "<FORM id='DeleteRegisteredUser' METHOD='POST' ACTION='/cgi-bin/HousekeepingScripts/DeleteRegisteredUser.pl'>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleWhite'>AssocID = [$AssocID]</p></th></tr>\n";
	print "<tr><th><p class='TitleWhite'>EmployeeNum = [$EmployeeNum]</p></th></tr>\n";
	print "<tr><th><p class='TitleWhite'>deleteuser = [$deleteuser]</p></th></tr>\n";
	print "<tr><th><p class='TitleWhite'>ODDAccessLevel = [$ODDAccessLevel]</p></th></tr>\n";
	print "<tr><th><p class='TitleWhite'>ADACAccessLevel = [$ADACAccessLevel]</p></th></tr>\n";
	print "<tr><th><p class='TitleWhite'>TERMAccessLevel = [$TERMAccessLevel]</p></th></tr>\n";
	print "</table>\n";
	print "</body>\n";
	print "</html>\n";
	exit;

# End testing area
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $WebNewUsers = "WebNewUsers";
my $dbh;
my $sth;
my $row;
my $username;
my $password;

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

my $SQLString;
my $Name;
my $AccessLevel;
my $Registered;
my $Authorized;
my $AdminAccess;
my $LastLogin;

# Now kick off DisplayAssociateListings subroutine.
DeletePassedUser();
DisplayAssociateListings();

sub DeletePassedUser
{
	$SQLString = "delete FROM $WebNewUsers where EmpID = '$AssocID';";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
}

sub DisplayAssociateListings
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<link rel='stylesheet' href='http://idmgmtapp01/css/UserModStyles.css'>\n";
	print "<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/functions.js'></script>\n";
	print "</head>\n";
	print "<BODY bgcolor='#0F0141'>\n";
	print "<FORM id='DeleteRegisteredUser' METHOD='POST' ACTION='/cgi-bin/HousekeepingScripts/DeleteRegisteredUser.pl'>\n";
	print "<table width='100%'>\n";
	print "<tr><th><p class='TitleWhite'>Settings below are saved instantly when you change them</p></th></tr>\n";
	print "</table>\n";
	print "<br>\n";
	print "<table width='100%' border='0'>\n";
	print "<tr>\n";
	print "<td width='15%'><p class='Heading'>Associate ID</p></td>\n";
	print "<td width='15%'><p class='Heading'>Name</p></td>\n";
	print "<td width='10%'><p class='Heading'>Access Level</p></td>\n";
	print "<td width='10%'><p class='Heading'>Registered</p></td>\n";
	print "<td width='10%'><p class='Heading'>Authorized</p></td>\n";
	print "<td width='10%'><p class='Heading'>Admin Access</p></td>\n";
	print "<td width='10%'><p class='Heading'>Delete User</p></td>\n";
	print "<td width='20%'><p class='Heading'>Last Login</p></td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "<table width='100%' border='0'>\n";
	$SQLString = "SELECT * FROM $WebNewUsers;";
	$dbh = DBI->connect($dsn,$username,$password, \%attr);
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	my $Counter = 0;
	while (@row = $sth->fetchrow_array())
	{
		$Counter++;
		$EmpID = $row[0];
		$Name = $row[1];
		$EMail = $row[2];
		$AccessLevel = $row[3];
		$Registered = $row[4];
		$Authorized = $row[5];
		$AdminAccess = $row[6];
		$LastLogin = $row[7];
		
		print "<tr>\n";
		
		# Associate ID Area
		print "<td width='15%'>\n";
		print "<input id='EmpID${Counter}' name='EmpID${Counter}' type='text' value='$EmpID' size='6'>\n";
		print "</td>\n";
		
		# Name Area
		print "<td width='15%'><p class='Detail'>$Name</p></td>\n";
		
		# Access Level Area
		print "<td width='10%' align='center'>\n";
		print "<select name='AccessLevel${Counter}' id='AccessLevel${Counter}' onChange='UpdateUserSettings()'>\n";
		if($AccessLevel eq 1) 
		{ 
			print "<option value='1' selected>1</option>\n"; 
		} 
		else 
		{ 
			print "<option value='1'>1</option>\n"; 
		}
		if($AccessLevel eq 2) 
		{ 
			print "<option value='2' selected>2</option>\n"; 
		} 
		else 
		{ 
			print "<option value='2'>2</option>\n"; 
		}
		if($AccessLevel eq 3) 
		{ 
			print "<option value='3' selected>3</option>\n"; 
		} 
		else 
		{ 
			print "<option value='3'>3</option>\n"; 
		}
		print "</select>\n";
		print "</td>\n";
		
		# Registered Area
		print "<td width='10%'><p class='Detail'>$Registered</p></td>\n";
		
		# Authorized Area
		print "<td width='10%' align='center'>\n";
		print "<select name='Authorized${Counter}' id='Authorized${Counter}' onChange='UpdateUserSettings()'>\n";
		if($Authorized eq "Yes") 
		{ 
			print "<option value='Yes' selected>Yes</option>\n"; 
		} 
		else 
		{ 
			print "<option value='Yes'>Yes</option>\n"; 
		}
		if($Authorized eq "No") 
		{ 
			print "<option value='No' selected>No</option>\n"; 
		} 
		else 
		{ 
			print "<option value='No'>No</option>\n"; 
		}
		print "</select>\n";
		print "</td>\n";
		
		# Admin Access Area
		print "<td width='10%' align='center'>\n";
		print "<select name='AdminAccess${Counter}' id='AdminAccess${Counter}' onChange='UpdateUserSettings()'>\n";
		if($AdminAccess eq "Yes") 
		{ 
			print "<option value='Yes' selected>Yes</option>\n"; 
		} 
		else 
		{ 
			print "<option value='Yes'>Yes</option>\n"; 
		}
		if($AdminAccess eq "No") 
		{ 
			print "<option value='No' selected>No</option>\n"; 
		} 
		else 
		{ 
			print "<option value='No'>No</option>\n"; 
		}
		print "</select>\n";
		print "</td>\n";
		
		# Delete User
		print "<td width='10%' align='center'>\n";
		#print "<input type='image' name='submit' src='http://idmgmtapp01/images/buttons/deleteuser.jpg' border='0' alt='Submit' style='width: 50px;' />\n";
		print "<input type='checkbox' name='deleteuser' id='deleteuser' value='$EmpID' onChange='PostDeleteUser()'>\n";
		
		# Last Login Area
		print "<td width='20%'><p class='Detail'>$LastLogin</p></td>\n";
		print "</tr>\n";
	}
	print "</table>\n";
	print "</form>\n";
	print "</body>\n";
	print "</html>\n";
	$dbh->disconnect;
}
