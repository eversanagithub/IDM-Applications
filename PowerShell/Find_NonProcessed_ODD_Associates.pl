#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: Find_NonProcessed_ODD_Associates.pl                                       #
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
my $EMail;
my $UPN;
my $UserName;
my $ManagerUPN;
my $FirstName;
my $LastName;
my @UM = ();
my @Name = ();
my @Name2 = ();

NukeTerminatedAssociatesTable();
CreateTerminatedAssociatesTable();
LoadTerminatedAssociatesTable();

sub NukeTerminatedAssociatesTable
{
    $dbh = DBI->connect($dsn);
    $SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebTempTerminatedListing' AND TABLE_SCHEMA = 'dbo') DROP TABLE WebTempTerminatedListing;";
    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $dbh->disconnect;
}

sub CreateTerminatedAssociatesTable
{
    $dbh = DBI->connect($dsn);
    $SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebTempTerminatedListing' AND TABLE_SCHEMA = 'dbo') create table WebTempTerminatedListing(UserName varchar(60),UPN varchar(80),ManagerUPN varchar(80));";
    $sth = $dbh->prepare($SQLString);
    $sth->execute();
    $dbh->disconnect;
}

sub LoadTerminatedAssociatesTable
{
	$OldUPN = "";
	$dbh = DBI->connect($dsn);
	$dbh2 = DBI->connect($dsn);
	$dbh3 = DBI->connect($dsn);
	$SQLString = "select distinct coalesce(f.userprincipalname, f2.userprincipalname) + ';' + coalesce(fm.userprincipalname, fm2.userprincipalname) as usermanager from Request_VW r left join ADHoc_SubRequest ahsr on (ahsr.RequestGUID = r.RequestGUID and ahsr.FieldName = 'Username') left join SubRequest sr on (sr.RequestGUID = r.RequestGUID and sr.FieldName = 'Username') left join IdentityMap i on (i.Username = ahsr.FieldValue and i.TargetID = r.TargetID) left join IdentityMap i2 on (i.Username = sr.FieldValue and i.TargetID = r.TargetID) left join Feed_AD_Universal f on (f.sAMAccountName = ahsr.FieldValue) left join Feed_AD_Universal f2 on (f2.sAMAccountName = sr.FieldValue) left join Feed_AD_Universal fm on (f.extensionAttribute10 = fm.EmployeeNumber) left join Feed_AD_Universal fm2 on (f2.extensionAttribute10 = fm2.EmployeeNumber) where r.ProcessedDate > convert(varchar, getdate()-30,112) and r.targetid = 'ad_universal' and status = 'completed' and r.action = 'DIS' and i.Username is null and i2.username is null order by usermanager;";
	$sth = $dbh->prepare($SQLString);
	$sth->execute();
	while (@row = $sth->fetchrow_array())
	{
		$UPN_Manager = $row[0];
		if($UPN_Manager ne $null)
		{
			@UM = split(/;/,$UPN_Manager);
			$UPN = $UM[0];
			$ManagerUPN = $UM[1];
			@Name2 = split(/\@/,$UPN);
			$UPNName = $Name2[0];
			@Name = split(/\./,$UPNName);
			$FirstName = $Name[0];
			$LastName = $Name[1];
			$UserName = $FirstName . '.' . $LastName;
			if($UPN ne $OldUPN)
			{
				$Counter = 0;
				$SQLString = "select Owner from WebDelegatesAlreadyProcessed where Owner = '$UPN';";
				$sth2 = $dbh2->prepare($SQLString);
				$sth2->execute();
				while (@row2 = $sth2->fetchrow_array())
				{
					$Owner = $row2[0];
					$Counter++;
				}
				if($Counter == 0)
				{ 
					$SQLString = "insert into WebTempTerminatedListing(UserName,UPN,ManagerUPN) values ('$UserName','$UPN','$ManagerUPN');";
					$sth3 = $dbh3->prepare($SQLString);
					$sth3->execute();
				}
				$OldUPN = $UPN;
			}
		}
	}
	$dbh3->disconnect;
	$dbh2->disconnect;
	$dbh->disconnect;
}
