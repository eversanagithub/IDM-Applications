#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: CreateRegisterHTML.pl                                                     #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 26, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Creates the Register for Admin Portal screen.                             #
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
	"AddUserToPortal" application to the screen.
	All the logic and file creation commands for the One-Drive delegation application
	are found in the CreateRegisterUserDropDown PHP script. That script is located at:

	C:\Apache24\htdocs\php\CreateRegisterUserDropDown.php
};

my $PHP = "C:\\php\\php.exe";
my $CreateRegisterHTMLMenu = "C:\\Apache24\\htdocs\\php\\DisplayCreateRegisterHTML.php";

my $phpOutput = `$PHP $CreateRegisterHTMLMenu`;
print "$phpOutput";
