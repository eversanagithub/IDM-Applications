#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: IndividualDailyTableRecreation.pl                                         #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 23, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates individual daily recreation scripts                               #
#                     of the IDM Web Site database tables.                                      #
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
my $Table;
my $TableFile;
my $Date;

my @TableName = ();
my @ThisDate = ();
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
$BaseFilename = "C:/Apache24/cgi-bin/DatabaseBackups/";
$Today = DateTime->now;
@ThisDate = split('T',$Today);
$Date = $ThisDate[0];
$Date =~ s/-//g;

$dbh = DBI->connect($dsn);
$SQLString = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'Web%' order by TABLE_NAME;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
while (@row = $sth->fetchrow_array())
{
	$Table = $row[0];
	chomp($Table);
	$TableFile = $BaseFilename . $Table . $Date;
	if (-e $TableFile) { unlink($TableFile); }
	open(TableFile,">$TableFile") or die "$!";
	print TableFile '#!c:\Strawberry\perl\bin\perl.exe';
	print TableFile "\n\n";
	print TableFile "# File Name: $TableFile\n\n";
	print TableFile "# Load external modules\n";
	print TableFile "use DBI;\n";
	print TableFile "use CGI;\n";
	print TableFile "use Time::HiRes qw(sleep);\n";
	print TableFile "use POSIX qw/strftime/;\n";
	print TableFile "use Term::ANSIColor;\n";
	print TableFile "use DateTime;\n";
	print TableFile "use File::Spec;\n";
	print TableFile "use File::Copy;\n";
	print TableFile "use File::Path qw(make_path remove_tree);\n";
	print TableFile "use Switch;\n\n";
	print TableFile 'my $dsn = "dbi:ODBC:DSN=DBWebConnection";';
	print TableFile "\n";
	print TableFile 'my $dsn = "dbi:ODBC:DSN=DBWebConnection";';
	print TableFile "\n";
	print TableFile 'my $dbh;';
	print TableFile "\n";
	print TableFile 'my $sth;';
	print TableFile "\n";
	print TableFile 'my $SQLString = "";';
	print TableFile "\n\n";
	print TableFile "#######################\n";
	print TableFile "#   Control Center    #\n";
	print TableFile "#######################\n";
	print TableFile "   DeleteTable(); #\n";
	print TableFile "   CreateTable(); #\n";
	print TableFile "#######################\n\n";
	close TableFile;
}

# Create the Drop Table statements.
$dbh = DBI->connect($dsn);
$SQLString = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'Web%' order by TABLE_NAME;";
$sth = $dbh->prepare($SQLString);
$sth->execute();
$ThisTable = 'WebAdminPortalApplicationURLTable' . $Date;
while (@row = $sth->fetchrow_array())
{
	$Table = $row[0];
	chomp($Table);
	$TableFile = $BaseFilename . $Table . $Date;
	open(TableFile,">>$TableFile") or die "$!";
	print TableFile "# Drop Table\n\n";
	print TableFile "sub DeleteTable\n";
	print TableFile "{\n";
	print TableFile '    $dbh = DBI->connect($dsn);';
	print TableFile "\n\n";
	print TableFile '    $SQLString = "IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ';
	print TableFile "'";
	print TableFile "$Table";
	print TableFile "'";
	print TableFile " AND TABLE_SCHEMA = 'dbo') DROP TABLE ";
	print TableFile "$Table";
	print TableFile ';";';
	print TableFile "\n";
	print TableFile '    $sth = $dbh->prepare($SQLString);';
	print TableFile "\n";
	print TableFile '    $sth->execute();';  
	print TableFile "\n\n";
	print TableFile '    $dbh->disconnect;';
	print TableFile "\n";
	print TableFile "}\n\n";
	close TableFile;
}
$dbh->disconnect;

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
	$TableFile = $BaseFilename . $Table . $Date;
	open(TableFile,">>$TableFile") or die "$!";
	print TableFile "# Create Table\n\n";
	print TableFile "sub CreateTable\n";
	print TableFile "{\n";
	print TableFile '    $dbh = DBI->connect($dsn);';
	print TableFile "\n\n";
	print TableFile '    $SQLString = "IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ';
	print TableFile "'";
	print TableFile "$Table";
	print TableFile "'";
	print TableFile " AND TABLE_SCHEMA = 'dbo') create table $Table(";
	
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
					print TableFile "$Column $DataType($Length),"; 
				}
				case "int"
				{
					print TableFile "$Column $DataType,";
				}
				case "datetime"
				{
					print TableFile "$Column $DataType,";
				}
				case "bit"
				{
					print TableFile "$Column $DataType,";
				}
			}
		} 
		else 
		{ 
			switch($DataType)
			{
				case "varchar"
				{
					print TableFile "$Column $DataType($Length)"; 
				}
				case "int"
				{
					print TableFile "$Column $DataType";
				}
				case "datetime"
				{
					print TableFile "$Column $DataType";
				}
				case "bit"
				{
					print TableFile "$Column $DataType";
				}
			}
		}
	}
	print TableFile ');";';
	print TableFile "\n\n";
	print TableFile '    $sth = $dbh->prepare($SQLString);';
	print TableFile "\n";
	print TableFile '    $sth->execute();';  
	print TableFile "\n\n";
	
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
	
	# Find the number of columns in the table.
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
		print TableFile "$RecordEntry";	
		print TableFile ');";';
		print TableFile "\n\n";
		print TableFile '    $sth = $dbh->prepare($SQLString);';
		print TableFile "\n";
		print TableFile '    $sth->execute();';
		print TableFile "\n";
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
		print TableFile "\n";
		print TableFile '    $dbh->disconnect;'; 
		print TableFile "\n";
	}
	print TableFile "}\n\n";
	close TableFile;
}	
$dbh2->disconnect;
$dbh->disconnect;

