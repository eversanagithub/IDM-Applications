#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: SendClientWebsiteInvite.pl                                                #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 29, 2023                                                              #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Adds new users to database tables and invite email to user.               #
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
use DateTime::Format::Strptime;

my $now = DateTime->now;
print "now = [$now]\n";

#my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
my $datestring = strftime "%Y-%m-%d %H:%M:%S", localtime;

print "datestring = [$datestring]\n";
exit;

my $format = DateTime::Format::Strptime->new(
	pattern   => '%Y-%m-%d %H:%M:%s',
	time_zone => 'local',
	on_error  => 'croak',
);

$ReportDate = $format->parse_datetime($now);
print "ReportDate = [$ReportDate]\n";

