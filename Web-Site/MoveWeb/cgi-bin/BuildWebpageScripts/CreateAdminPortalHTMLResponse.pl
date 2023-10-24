#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CreateAdminPortalHTMLResponse.pl                                          #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 20, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates the One-Drive Delegation associate selection screen.              #
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

q{
	This Perl script simply prints the already created HTML code for the 
	"AdminPortal" application to the screen.
	All the logic and file creation commands for the One-Drive delegation application
	are found in the CreateODDHTMLResponse PHP script. That script is located at:

	C:\Apache24\htdocs\OneDriveDelegation\php\CreateTERMHTMLResponse.php
};

my $PHP = "C:\\php\\php.exe";
my $CreateAdminPortalMenu = "C:\\Apache24\\htdocs\\php\\BuildWebpageScripts\\DisplayAdminPortalHTMLResponse.php";

my $phpOutput = `$PHP $CreateAdminPortalMenu`;
print "$phpOutput";
