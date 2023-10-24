#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: FindTopJobCodes.pl                                                        #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 23, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates a daily recreation script of the IDM Web Site database tables.    #
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

my $dsn = "dbi:ODBC:DSN=DBWebConnection";
my $dbh;
my $sth;
my $dbh2;
my $sth2;
my @row = {};
my @row2 = ();

my $SQLString = "";
my $JobCode;
my $JobCode2;
my $Number;
my $CountryCode;
my $Title;
my $IsActive;
my $JobFamilyCode;
my $LongDescription;
my $JobEEOCategory;
my $jobGroup;
my $FLSATypeCode;
my $LP = '(';
my $RP = ')';
my $SP = ' ';
my $HY = '-';

print "\n\n";
printf("%-60s %-8s %-3s\n","       Position Name - Family Code - Job EEO Category       ","Job Code","Amt");
printf("%-60s %-8s %-3s\n","------------------------------------------------------------","--------","---");

$dbh = DBI->connect($dsn);
#$SQLString = "select h.njobtitlecode, count(h.njobtitlecode) as number, j.longDescription,j.jobFamilyCode from hr_trx h inner join HR_JobCodes j on h.NJobTitleCode = j.jobCode where h.reason in ('hir','ter') and h.in_tbl_date > '20230101' and j.isActive = 'true' group by h.njobtitlecode,j.longDescription,j.jobFamilyCode order by count(njobtitlecode) desc;";
$SQLString = "select h.njobtitlecode, count(h.njobtitlecode) as number, j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory from hr_trx h inner join HR_JobCodes j on h.NJobTitleCode = j.jobCode where h.reason in ('hir','ter') and h.in_tbl_date > '20230101' and j.isActive = 'true' group by h.njobtitlecode,j.longDescription,j.jobFamilyCode,j.countryCode,j.jobEEOCategory order by j.longDescription asc;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$JobCode = $row[0];
	$Number = $row[1];
	$LongDescription = $row[2];
	$FamilyCode = $row[3];
	$CountryCode = $row[4];
	$JobEEOCategory = $row[5];
	$PositionName = $LongDescription . $SP . $HY . $SP . $FamilyCode . $SP . $HY . $SP . $JobEEOCategory;
	if($Number > 10) { printf("%-60s %-8s %3s\n",$PositionName,$JobCode,$Number); }
}
		
		
