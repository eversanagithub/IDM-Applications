#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: LoadItilUsersTable.pl                                                     #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 29, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Find missed One-Drive Delegation operations.                              #
#                                                                                               #
#################################################################################################

# Load external modules
use DBI;
use CGI;
use Time::HiRes qw(sleep);
use POSIX qw/strftime/;
use Term::ANSIColor;
use Switch;

####################################################################################
###########   S T A R T   V A R I A B L E   D E C L A I R A T I O N    #############
####################################################################################

# SQL Connectivity Variables
my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $dbh;
my $sth;
my $row;
my @row = ();
my $dbh2;
my $sth2;
my $row2;
my @row2 = ();
my $SelectString = "PositionStatus,AssociateID,FirstName,LastName,PreferredName,ReportsToName,JobTitleDescription,HomeDepartmentDescription";
my $itilUser;

NukeItilUsersTable();
CreateItilUsersTable();
LoadItilUsersTable();

sub NukeItilUsersTable
{
    $dbh = DBI->connect($dsn);
    $SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'itilusers' AND TABLE_SCHEMA = 'dbo') DROP TABLE itilusers;";
    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $dbh->disconnect;
}

sub CreateItilUsersTable
{
    $dbh = DBI->connect($dsn);
    $SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'itilusers' AND TABLE_SCHEMA = 'dbo') create table itilusers(itiluser varchar(80));";
    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $dbh->disconnect;
}

sub LoadItilUsersTable
{
	$dbh = DBI->connect($dsn);
	$dbh2 = DBI->connect($dsn);
	$SQLString = "select p.Email from UltiPro_ADRpt u left join profile p on u.AssociateID = p.EMPLID where PositionStatus = 'Active'  and p.Email is not null order by p.Email;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$itilUser = $row[0];
		chomp($itilUser);
		$SQLString = "insert into itilusers(itiluser) values ('$itilUser');";
		$sth2 = $dbh2->prepare($SQLString);
		$sth2->execute();
	}
	$dbh2->disconnect;
	$dbh->disconnect;
}
