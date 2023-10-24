#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CreateRestoreWebsiteDataPage.pl                                           #
#           Language: Perl v5.16.3                                                              #
#       Date Written: July 14th, 2023                                                           #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates the Restore Website Data page screen.                             #
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
	'Add User To Active Directory' application to the screen.
	All the logic and file creation commands for this application can be found
	in the CreateAddUserToPortalHTMLResponse PHP script. That script is located at:

	C:\Apache24\htdocs\php\BuildWebPageScripts\CreateRestoreWebsiteDataPage.php
};

my $PHP = "C:\\php\\php.exe";
my $RestoreWebsiteDataPage = "C:\\Apache24\\htdocs\\php\\BuildWebpageScripts\\DisplayRestoreWebsiteDataPage.php";

my $phpOutput = `$PHP $RestoreWebsiteDataPage`;
print "$phpOutput";
