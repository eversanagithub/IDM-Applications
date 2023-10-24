#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: DailyTableRecreation.pl                                                   #
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
my $CreateStatement;
my $AddStatement;
my $NumRecords;
my $NumbRecords;
my $NumColumns;
my $RecordEntry;

my $Field1;
my $Field2;
my $Field3;
my $Field4;
my $Field5;
my $Field6;
my $Field7;
my $Field8;
my $Field9;
my $Field10;
my $Field11;
my $Field12;
my $Field13;
my $Field14;
my $Field15;
my $Field16;
my $Field17;
my $Field18;
my $Field19;

# Create the daily filename
$Ext = '.pl';
$BaseFilename = "C:/Apache24/cgi-bin/DatabaseBackups/InitiateTables";
$Today = DateTime->now;
my @ThisDate = split('T',$Today);
$Date = $ThisDate[0];
$Date =~ s/-//g;
$InitiateTablesFile = $BaseFilename . $Date . $Ext;
if (-e $InitiateTablesFile) { unlink($InitiateTablesFile); }
open(InitiateTablesFile,">$InitiateTablesFile") or die "$!";
print InitiateTablesFile '#!c:\Strawberry\perl\bin\perl.exe';
print InitiateTablesFile "\n\n";
print InitiateTablesFile "#################################################################################################\n";
print InitiateTablesFile "#                                                                                               #\n";
print InitiateTablesFile "#       Program Name: CreateInitiateTables.pl                                                   #\n";
print InitiateTablesFile "#           Language: Perl v5.16.3                                                              #\n";
print InitiateTablesFile "#       Date Written: July 9, 2023                                                              #\n";
print InitiateTablesFile "#         Written by: Dave Jaynes                                                               #\n";
print InitiateTablesFile "#            Purpose: Restores all the IDM Website SQL tables to a specific point in time.      #\n";
print InitiateTablesFile "#                     This script is created by the master script below:                        #\n";
print InitiateTablesFile "#                                                                                               #\n";
print InitiateTablesFile "#                     C:\\Apache24\\cgi-bin\\DailyTableRecreation.exe                              #\n";
print InitiateTablesFile "#                                                                                               #\n";
print InitiateTablesFile "#                     The recovery date for this script is: $Date                            #\n";
print InitiateTablesFile "#                                                                                               #\n";
print InitiateTablesFile "#                     This script should only be run if you need to totally wipe out the        #\n";
print InitiateTablesFile "#                     existing IDM Website database tables and replace them with the data       #\n";
print InitiateTablesFile "#                     from the date listed above. This will be a Website data recovery effort.  #\n";
print InitiateTablesFile "#                                                                                               #\n";
print InitiateTablesFile "#################################################################################################\n\n";
print InitiateTablesFile "# Load external modules\n";
print InitiateTablesFile "use DBI;\n";
print InitiateTablesFile "use CGI;\n";
print InitiateTablesFile "use Time::HiRes qw(sleep);\n";
print InitiateTablesFile "use POSIX qw/strftime/;\n";
print InitiateTablesFile "use Term::ANSIColor;\n";
print InitiateTablesFile "use DateTime;\n";
print InitiateTablesFile "use File::Spec;\n";
print InitiateTablesFile "use File::Copy;\n";
print InitiateTablesFile "use File::Path qw(make_path remove_tree);\n";
print InitiateTablesFile "use Switch;\n\n";
print InitiateTablesFile 'my $dsn = "dbi:ODBC:DSN=DBWebConnection";';
print InitiateTablesFile "\n";
print InitiateTablesFile 'my $dsn = "dbi:ODBC:DSN=DBWebConnection";';
print InitiateTablesFile "\n";
print InitiateTablesFile 'my $dbh;';
print InitiateTablesFile "\n";
print InitiateTablesFile 'my $sth;';
print InitiateTablesFile "\n";
print InitiateTablesFile 'my $SQLString = "";';
print InitiateTablesFile "\n\n";
print InitiateTablesFile "#######################\n";
print InitiateTablesFile "#   Control Center    #\n";
print InitiateTablesFile "#######################\n";
print InitiateTablesFile "   DeleteAllTables(); #\n";
print InitiateTablesFile "   CreateAllTables(); #\n";
print InitiateTablesFile "#######################\n\n";

print InitiateTablesFile "sub DeleteAllTables\n";
print InitiateTablesFile "{\n";
print InitiateTablesFile "	DeleteWebAdminPortalApplicationURL();\n";
print InitiateTablesFile "	DeleteWebAdminPortalLoginDetails();\n";
print InitiateTablesFile "	DeleteWebBuildHousekeepingButtons();\n";
print InitiateTablesFile "	DeleteWebBuildMainSelectionButtons();\n";
print InitiateTablesFile "	DeleteWebBuildSelectionButtons();\n";
print InitiateTablesFile "	DeleteWebDelegatesAlreadyProcessed();\n";
print InitiateTablesFile "	DeleteWebEncryptedKeys();\n";
print InitiateTablesFile "	DeleteWebHousekeepingApplicationURL();\n";
print InitiateTablesFile "	DeleteWebIDMWebsiteLoggedEvents();\n";
print InitiateTablesFile "	DeleteWebLatestWebUserDTG();\n";
print InitiateTablesFile "	DeleteWebMainApplicationURL();\n";
print InitiateTablesFile "	DeleteWebNewUsers();\n";
print InitiateTablesFile "	DeleteWebProcessAccessRequest();\n";
print InitiateTablesFile "	DeleteWebRegisteredUsers();\n";
print InitiateTablesFile "	DeleteWebRequests();\n";
print InitiateTablesFile "	DeleteWebSearchFields();\n";
print InitiateTablesFile "	DeleteWebStatusOfODDProgress();\n";
print InitiateTablesFile "	DeleteWebUserRoles();\n";
print InitiateTablesFile "	DeleteWebWhoAmI();\n";
print InitiateTablesFile "}\n\n";

print InitiateTablesFile "sub CreateAllTables\n";
print InitiateTablesFile "{\n";
print InitiateTablesFile "	CreateWebAdminPortalApplicationURL();\n";
print InitiateTablesFile "	CreateWebAdminPortalLoginDetails();\n";
print InitiateTablesFile "	CreateWebBuildHousekeepingButtons();\n";
print InitiateTablesFile "	CreateWebBuildMainSelectionButtons();\n";
print InitiateTablesFile "	CreateWebBuildSelectionButtons();\n";
print InitiateTablesFile "	CreateWebDelegatesAlreadyProcessed();\n";
print InitiateTablesFile "	CreateWebEncryptedKeys();\n";
print InitiateTablesFile "	CreateWebHousekeepingApplicationURL();\n";
print InitiateTablesFile "	CreateWebIDMWebsiteLoggedEvents();\n";
print InitiateTablesFile "	CreateWebLatestWebUserDTG();\n";
print InitiateTablesFile "	CreateWebMainApplicationURL();\n";
print InitiateTablesFile "	CreateWebNewUsers();\n";
print InitiateTablesFile "	CreateWebProcessAccessRequest();\n";
print InitiateTablesFile "	CreateWebRegisteredUsers();\n";
print InitiateTablesFile "	CreateWebRequests();\n";
print InitiateTablesFile "	CreateWebSearchFields();\n";
print InitiateTablesFile "	CreateWebStatusOfODDProgress();\n";
print InitiateTablesFile "	CreateWebUserRoles();\n";
print InitiateTablesFile "	CreateWebWhoAmI();\n";
print InitiateTablesFile "}\n\n";

print InitiateTablesFile "#################################################\n";
print InitiateTablesFile "#            Begin Subroutine Section           #\n";
print InitiateTablesFile "#################################################\n\n";

print InitiateTablesFile "# Delete Tables\n\n";

# Create the Drop Table statements.
$dbh = DBI->connect($dsn);
$SQLString = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'Web%' order by TABLE_NAME;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$Table = $row[0];
	chomp($Table);
	print InitiateTablesFile "sub Delete${Table}\n";
	print InitiateTablesFile "{\n";
	print InitiateTablesFile '    $dbh = DBI->connect($dsn);';
	print InitiateTablesFile "\n\n";
	print InitiateTablesFile '    $SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ';
	print InitiateTablesFile "'";
	print InitiateTablesFile "$Table";
	print InitiateTablesFile "'";
	print InitiateTablesFile " AND TABLE_SCHEMA = 'dbo') DROP TABLE ";
	print InitiateTablesFile "$Table";
	print InitiateTablesFile ';";';
	print InitiateTablesFile "\n";
	print InitiateTablesFile '    $sth = $dbh->prepare($SQLString);';
	print InitiateTablesFile "\n";
	print InitiateTablesFile '    $sth->execute();';  
	print InitiateTablesFile "\n\n";
	print InitiateTablesFile '    $dbh->disconnect;';
	print InitiateTablesFile "\n";
	print InitiateTablesFile "}\n\n";
}
$dbh->disconnect;
print InitiateTablesFile "# Create Tables\n\n";

# Create the Create Table statements

$dbh = DBI->connect($dsn);
$dbh2 = DBI->connect($dsn);
$SQLString = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'Web%' order by TABLE_NAME;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$Table = $row[0];
	chomp($Table);
	print InitiateTablesFile "sub Create${Table}\n";
	print InitiateTablesFile "{\n";
	print InitiateTablesFile '    $dbh = DBI->connect($dsn);';
	print InitiateTablesFile "\n\n";
	print InitiateTablesFile '    $SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ';
	print InitiateTablesFile "'";
	print InitiateTablesFile "$Table";
	print InitiateTablesFile "'";
	print InitiateTablesFile " AND TABLE_SCHEMA = 'dbo') create table $Table(";
	
	$NumRecords = 0;
	$SQLString2 = "SELECT COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$Table';";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$NumRecords++;
	}
	#print InitiateTablesFile "NumRecords = [$NumRecords]\n";
	$Counter = 0;
	$SQLString2 = "SELECT COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$Table';";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$Column = $row2[0];
		$DataType = $row2[1];
		$Length = $row2[2];
		chomp($Column,$DataType,$Length);
		$Counter++;
		if($Counter < $NumRecords) 
		{ 
			switch($DataType)
			{
				case "varchar"
				{
					print InitiateTablesFile "$Column $DataType($Length),"; 
				}
				case "int"
				{
					print InitiateTablesFile "$Column $DataType,";
				}
				case "datetime"
				{
					print InitiateTablesFile "$Column $DataType,";
				}
				case "bit"
				{
					print InitiateTablesFile "$Column $DataType,";
				}
			}
		} 
		else 
		{ 
			switch($DataType)
			{
				case "varchar"
				{
					print InitiateTablesFile "$Column $DataType($Length)"; 
				}
				case "int"
				{
					print InitiateTablesFile "$Column $DataType";
				}
				case "datetime"
				{
					print InitiateTablesFile "$Column $DataType";
				}
				case "bit"
				{
					print InitiateTablesFile "$Column $DataType";
				}
			}
		}
	}
	print InitiateTablesFile ');";';
	print InitiateTablesFile "\n\n";
	print InitiateTablesFile '    $sth = $dbh->prepare($SQLString);';
	print InitiateTablesFile "\n";
	print InitiateTablesFile '    $sth->execute();';  
	print InitiateTablesFile "\n\n";
	
	# Place Insert statements here
	
	$NumColumns = 0;
	$SQLString2 = "SELECT COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$Table';";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$NumColumns++;
	}
	
	$Counter = 0;
	
	$BaseRecordEntry = '    $SQLString = "insert into ';
	$BaseRecordEntry = $BaseRecordEntry . $Table;
	$BaseRecordEntry = $BaseRecordEntry . "(";
	$SQLString2 = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$Table';";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$Column = $row2[0];
		$Counter++;
		if($Counter < $NumColumns) 
		{ 
			$BaseRecordEntry = $BaseRecordEntry . "$Column,";
		}
		else
		{
			$BaseRecordEntry = $BaseRecordEntry . "$Column";
		}
	}
	$BaseRecordEntry = $BaseRecordEntry . ") values (";
	# print InitiateTablesFile "$BaseRecordEntry\n\n";
	
	# Fiend the number of columns in the table.
	$NumColumns = 0;
	$SQLString2 = "SELECT COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'$Table';";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$NumColumns++;
	}
	
	$Counter = 0;
	$SQLString2 = "SELECT * from $Table;";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$RecordEntry = $BaseRecordEntry;
		# We are going to load up 19 field variables to cover the most field statements we would encounter.
		$Field1 = $row2[0];
		$Field2 = $row2[1];
		$Field3 = $row2[2];
		$Field4 = $row2[3];
		$Field5 = $row2[4];
		$Field6 = $row2[5];
		$Field7 = $row2[6];
		$Field8 = $row2[7];
		$Field9 = $row2[8];
		$Field10 = $row2[9];
		$Field11 = $row2[10];
		$Field12 = $row2[11];
		$Field13 = $row2[12];
		$Field14 = $row2[13];
		$Field15 = $row2[14];
		$Field16 = $row2[15];
		$Field17 = $row2[16];
		$Field18 = $row2[17];
		$Field19 = $row2[18];
		switch($NumColumns)
		{
			case 0
			{
				break;
			}
			case 1
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "'";
			}
			case 2
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "'";
			}
			case 3
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "'";
			}
			case 4
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "'";
			}
			case 5
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "'";
			}
			case 6
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "'";
			}
			case 7
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "'";
			}
			case 8
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "'";
			}
			case 9
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "'";
			}
			case 10
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "'";
			}
			case 11
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "'";
			}
			case 12
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "'";
			}
			case 13
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "'";
			}
			case 14
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "'";
			}
			case 15
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "','" . "','" . $Field15 . "'";
			}
			case 16
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "','" . "','" . $Field15 . "','" . $Field16 . "'";
			}
			case 17
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "','" . "','" . $Field15 . "','" . $Field16 . "'" . $Field17 . "'";
			}
			case 18
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "','" . "','" . $Field15 . "','" . $Field16 . "'" . $Field17 . "','" . $Field18 . "'";
			}
			case 19
			{
				$RecordEntry = $RecordEntry . "'" . $Field1 . "','" . $Field2 . "','" . $Field3 . "','" . $Field4 . "','" . $Field5 . "','" . $Field6 . "','" . $Field7 . "','" . $Field8 . "','" . $Field9 . "','" . $Field10 . "','" . $Field11 . "','" . $Field12 . "','" . $Field13 . "','" . $Field14 . "','" . "','" . $Field15 . "','" . $Field16 . "'" . $Field17 . "','" . $Field18 . "','" . $Field19 . "'";
			}
		}
		print InitiateTablesFile "$RecordEntry";	
		print InitiateTablesFile ');";';
		print InitiateTablesFile "\n\n";
		print InitiateTablesFile '    $sth = $dbh->prepare($SQLString);';
		print InitiateTablesFile "\n";
		print InitiateTablesFile '    $sth->execute();';
		print InitiateTablesFile "\n";
	}
		
	$SQLString2 = "SELECT count(*) from $Table;";
	$sth2 = $dbh2->prepare($SQLString2);
	$sth2->execute();
	while (@row2 = $sth2->fetchrow_array())
	{
		$NumbRecords = $row2[0];
	}
	if($NumbRecords > 0) 
	{ 
		print InitiateTablesFile "\n";
		print InitiateTablesFile '    $dbh->disconnect;'; 
		print InitiateTablesFile "\n";
	}
	print InitiateTablesFile "}\n\n";
}	
$dbh2->disconnect;
$dbh->disconnect;
close InitiateTablesFile;
