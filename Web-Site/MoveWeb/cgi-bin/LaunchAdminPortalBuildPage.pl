#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: LaunchAdminPortalBuildPage.pl                                             #
#           Language: Perl v5.16.3                                                              #
#       Date Written: May 1, 2023                                                               #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Checks to see if the Text Code entered matches the one sent out.          #
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

my $query = CGI->new();
my $Launched = $query->param('Launched');

if($Launched eq 'Launched')
{
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "</head>\n";
	print "<frameset rows='12%,88%' name='top'  border='0' framespacing='1' frameborder=NO>\n";
	print "<frameset cols='100%' name='topsidebar' frameborder=NO border='0'>\n";
	print "<frame src='http://idmgmtapp01/webpages/IDM_Large_Logo2.htm' name='topright' scrolling=NO>\n";
	print "</frameset>\n";
	print "<frameset cols='15%,85%' name='topsidebar' frameborder=NO border='0'>\n";
	print "<frameset rows='100%' name='leftpanel' frameborder=NO border='0'>\n";
	print "<frame src='http://idmgmtapp01/webpages/topsidebar.html' name='leftpanel' scrolling=NO border='0'>\n";
	print "</frameset>\n";
	print "<frameset rows='17%,83%' name='mainpage' frameborder=NO border='0'>\n";
	print "<frame src='http://idmgmtapp01/webpages/AdminPortalWelcomeBanner.htm' name='topmainpanel' align=center scrolling=NO border='0'>\n";
	print "<frame src='http://idmgmtapp01/webpages/WelcomeToAdminPortal.htm' name='mainpanel' align=center scrolling=YES border='0'>\n";
	print "</frameset>\n";
	print "</frameset>\n";
	print "</frameset>\n";
	print "<body>\n";
	print "</body>\n";
	print "</html>\n";
}
else
{
	print "Content-type: text/html\n\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "	<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
	print "	<script LANGUAGE=JAVASCRIPT src='http://idmgmtapp01/js/FormSubmitting_functions.js'></script>\n";
	print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/AJAX_functions.js></script>\n";
	print "</HEAD>\n";
	print "<BODY bgcolor='#0F0141'>\n";
	print "<TABLE width='100%'>\n";
	print "	<TR>\n";
	print "		<TD width='100%' align='center'>\n";
	print "<img width=900 height=900 src='http://idmgmtapp01/images/IllegalAccess.jpg'>\n";
	print "		</TD>\n";
	print "	</TR>\n";
	print "</TABLE>\n";
	print "</BODY>\n";
	print "</HTML>\n";	
}	