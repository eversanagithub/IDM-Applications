#!c:\Strawberry\perl\bin\perl.exe

#################################################################################################
#                                                                                               #
#       Program Name: ExecutePromotionProcess.pl                                                #
#       Date Written: July 17th, 2023                                                           #
#         Written by: Dave Jaynes                                                               #
#            Purpose: Display the details of the code promotion process.                        #
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

print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<link rel='stylesheet' href='http://idmgmtapp01/css/styles.css'>\n";
print "<script LANGUAGE=JAVASCRIPT src=http://idmgmtapp01/js/functions.js></script>\n";
print "</head>\n";
print "<body onLoad='KickOffPromotion();MonitorPromotionProgressRefresh()' bgcolor='#0F0141'>\n";
print "<table width='100%' align='center'>\n";
print "<tr>\n";
print "<td align='center'>\n";
print "<p class='IDMReportHeading'>IDM Website Code Promotion Utility</p></td>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width='100%'>\n";
print "<tr>\n";
print "<td>\n";
print "<p class='IDMReportDetail'>This application promotes the HTML code within the Development environment into Production.</p></td>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n";
print "<br>\n";
print "<table width='100%' align='center'>\n";
print "<tr>\n";
print "<td width='100%' id='MainHeader'></td>\n";
print "</tr>\n";
print "</table>\n";
print "<table width='100%' align='center'>\n";
print "<tr>\n";
print "<td width='15%'>&nbsp</td>\n";
print "<td width='17%' id='Header1'></td>\n";
print "<td width='17%' id='Header2'></td>\n";
print "<td width='17%' id='Header3'></td>\n";
print "<td width='21%' id='Header4'></td>\n";
print "<td width='13%'>&nbsp</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td width='15%'>&nbsp</td>\n";
print "<td width='17%' id='starttime'></td>\n";
print "<td width='17%' id='stoptime'></td>\n";
print "<td width='17%' id='Header5'></td>\n";
print "<td width='21%' id='task'></td>\n";
print "<td width='13%'>&nbsp</td>\n";
print "</tr>\n";
print "</table>\n";
print "<br><br><br><br>\n";
print "<table width='100%' align='center'>\n";
print "<tr>\n";
print "<td width='100%' id='message'>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n";
print "<br><br>\n";
print "<table width='100%' align='center'>\n";
print "<tr>\n";
print "<td width='100%' align='center'>\n";
print "<img width=800 height=300 src='http://idmgmtapp01/images/PromoteCartoon3.jpg'>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n";
print "</body>\n";
print "</html>\n";

