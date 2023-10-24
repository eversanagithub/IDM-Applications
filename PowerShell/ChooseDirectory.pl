#!c:\Strawberry\perl\bin\perl.exe

use Term::ANSIColor;
use DBI;
use Tk;
use Tk::DirTree;
use Cwd;

my $SQL_User = "root";
my $SQL_Password = "A12bc34d";
my %attr = (PrintError=>0, RaiseError=>1);
my $SQLServer = "10.241.36.13";
my $SQLTable = "StaleAzureDeviceOptions";
my $dsn = "DBI:mysql:EmployeeTransitions;host=$SQLServer";
my $dbh;
my $sth;
my @row = ();

print color('green'),"\n\nSelect the directory where the daily Azure Remove Stale Devices Excel spreadsheets will be stored.\n\n", color('reset');

my $BS = '\\';
my $top = new MainWindow;
$top->withdraw;
my $t = $top->Toplevel;
$t->title("Choose directory:");
my $ok = 0;
my $f = $t->Frame->pack(-fill => "x", -side => "bottom");
my $curr_dir = 'C:';
my $d;
$d = $t->Scrolled('DirTree',
                  -scrollbars => 'osoe',
                  -width => 35,
                  -height => 20,
                  -selectmode => 'browse',
                  -exportselection =>1,
                  -browsecmd => sub { $curr_dir = shift },
                  -command => sub { $ok = 1; },
                 )->pack(-fill => "both", -expand => 1);

$d->chdir($curr_dir);
$f->Button(-text => 'Ok',
           -command => sub { $ok = 1 })->pack(-side => 'left');
$f->Button(-text => 'Cancel',
           -command => sub { $ok = 1 })->pack(-side => 'left');
$f->waitVariable(\$ok);

if ($ok == 1) 
{ 
	$curr_dir = $curr_dir . $BS;
	$dbh = DBI->connect($dsn,$SQL_User,$SQL_Password, \%attr);
	$sth = $dbh->prepare("update $SQLTable set ExcelSpreadsheetFileLocation = '$curr_dir';");
	$sth->execute();
	$dbh->disconnect;
}