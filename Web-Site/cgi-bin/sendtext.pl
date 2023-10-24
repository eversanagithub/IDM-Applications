#!c:\Strawberry\perl\bin\perl.exe

#######################################################################################
#                                                                                     #
#         Program Name: ADAccountCreation.pl                                          #
#         Date Written: May 15th, 2023                                                #
#           Written By: Dave Jaynes                                                   #
#          Description: Spawned by the ADAccountEntry.html form, this script creates  #
#                       a new Active Directory account in the Eversana environment.   #
#                                                                                     #
#######################################################################################

# Load external modules
use DBI;
use CGI;
use DateTime;
use Date::Simple ('date', 'today');
use Date::DayOfWeek;
use DateTime::Format::Strptime qw( );
use Date::Calc qw(Add_Delta_Days);
use Time::HiRes qw(sleep);
use Time::Seconds;
use Time::Piece;
use Date::Parse;
use Time::HiRes qw(sleep);
use POSIX qw(strftime);
use Term::ANSIColor;
use Time::Seconds;
use Time::Piece;
use Date::Calc qw(Add_Delta_Days);

#$Code = system("C:\\Apache24\\cgi-bin\\Applications\\sendtext.exe");
$Code = `C:\\Apache24\\cgi-bin\\sendtext.exe`;
print "Code = [$Code]\n";
print "Code = [$Code]\n";
print "Code = [$Code]\n";
