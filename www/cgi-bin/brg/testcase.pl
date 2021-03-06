#!/usr/bin/perl
#############################################################################
# Prepare a specific test case on the server side. Put this script only on
# servers that are used for testing purposes, because it overwrites existing
# databases.
#
# (c) 2012, 2016 Christian Leutloff
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself, i.e., under the terms of the
# ``Artistic License'' or the ``GNU General Public License''.
#
# Script used on test servers only! Changes Database etc. to prepare the
# starting condition of a test case. The existence of this file
# is ensured in all test cases that are changing the content. This is
# achieved by setting the test case to the desired one as first task.
# If this script is missing the test case will fail immediately.
#
#############################################################################

use strict;
use warnings;

use CGI qw/:standard :html5/;      # Standard CGI Functions
use CGI::Carp qw(fatalsToBrowser); # Show fatal errors in the browser and not only as Internal Server Error
use Fcntl qw/:flock :seek/;        # define LOCK_EX, SEEK_SET etc.
use FindBin;                       # locate this script
FindBin::again();
use PerlIO::encoding;              # Change character encoding when desired, e.g. when writing back to disk
use utf8;                          # UTF-8 character encoding is recognize in regular expressions, too.
use File::Copy;                    # import file copy
use Cwd qw(abs_path);

#---> Global Variables
my $VERSION="v1.1.0, 14.07.2016";
my $sep = '/';
my $dbpath = "$FindBin::Bin".'/br';
my $dbname = 'feginfo.csv';
my $dbbup = 'feginfo.bug';
my $tcdir = "$FindBin::Bin".'/testcases-db';# shared with the C++ unit tests - installed together with testcases.pl

#----> function prototypes --------------------------------
sub setup_tc1_empty_db();
sub setup_tc2_some_articles();
sub setup_tc3_api();
sub print_success_page($$);

#----> function prototypes of the shared functions --------
sub replace_umlauts($);
sub replace_html_umlauts($);
sub print_error_page($);
sub print_html_version();


# Standard Input and Standard Output is UTF-8:
binmode(STDIN, ":encoding(utf8)");
binmode(STDOUT, ":encoding(utf8)");

if (!defined param('TC')) { print_error_page("Please provide the param 'TC' to select the Test Case for set-up."); }
my $tc = param('TC');
if ($tc !~ /[0-9a-z]+/) { print_error_page("Only numbers and small letters are allowed for Testcases, but provided is '$tc'."); }

if (('1' eq $tc) || ('emptydb' eq $tc)) { setup_tc1_empty_db; }
elsif (('2' eq $tc) || ('somearticles' eq $tc)) { setup_tc2_some_articles; }
elsif (('3' eq $tc) || ('api' eq $tc)) { setup_tc3_api; }
else { print_error_page("The Test Case 'tc' is unknown."); }


#----------------------------------------------------------------------------
# Testcase with no databases at all.
#----------------------------------------------------------------------------
sub setup_tc1_empty_db()
{
	# delete the databases
    unlink($dbpath.$sep.$dbname);
    unlink($dbpath.$sep.$dbbup);
    #copy($tcdir.$sep.'1'.$sep.$dbname, $dbpath); empty is missing db
    print_success_page(1, '&lt;none&gt;');
}
#----------------------------------------------------------------------------
# Testcase with a databases containing some articles.
#----------------------------------------------------------------------------
sub setup_tc2_some_articles()
{
    # delete the databases
    unlink($dbpath.$sep.$dbname);
    unlink($dbpath.$sep.$dbbup);
    #copy the databases from tc dir
    my $useddbname = 'some_articles.csv';
    copy($tcdir.$sep.$useddbname, $dbpath.$sep.$dbname);
    print_success_page(2, $useddbname);
}
#----------------------------------------------------------------------------
# Testcase with articles used for api test - the content must match the responses
# used in the API description apiary.apib.
#----------------------------------------------------------------------------
sub setup_tc3_api()
{
    # delete the databases
    unlink($dbpath.$sep.$dbname);
    unlink($dbpath.$sep.$dbbup);
    #copy the databases from tc dir
    my $useddbname = 'api_examples.csv';
    copy($tcdir.$sep.$useddbname, $dbpath.$sep.$dbname);
    print_success_page(3, $useddbname);
}

#----------------------------------------------------------------------------
# Prints success.
#----------------------------------------------------------------------------
sub print_success_page($$)
{
    my ($testcasenumber, $useddbname) = @_;
	my $title = 'Setting up of the Test Case '.$testcasenumber.' succeeded';
	print header('-charset' => 'utf-8');
	print  start_html('-title'     => $title,
	                  '-style'     => {'src'=>"/brg/css/bgcrud.css"},
	                  '-encoding'  => 'utf-8',
	                  '-lang'      => 'en');
    print h2($title);
    print p('Copy DB: '.$tcdir.$sep.$useddbname.' => '.$dbpath.$sep.$dbname);
    print p({'-id' => 'opresult'}, 'Result: OK.');
    print_html_version();
    print end_html();
}

#############################################################################
# The following functions are shared between the perl scripts.
# Synchronization ensured the last time on: 2012-08-12
#############################################################################

#----------------------------------------------------------------------------
# Replace german Umlauts with their HTML entity.
# replace_umlauts and replace_html_umlauts must match!
#----------------------------------------------------------------------------
sub replace_umlauts($)
{
    my ($value) = shift;
    if (!defined($value)) { return; }
    $value=~s/ü/&uuml;/g;                        $value=~s/%C3%BC/&uuml;/g;
    $value=~s/ä/&auml;/g; $value=~s/Ã¤/&auml;/g; $value=~s/%C3%A4/&auml;/g;
    $value=~s/ö/&ouml;/g;                        $value=~s/%C3%B6/&ouml;/g;
    $value=~s/Ü/&Uuml;/g;                        $value=~s/%C3%9C/&Uuml;/g;
    $value=~s/Ä/&Auml;/g;                        $value=~s/%C3%84/&Auml;/g;
    $value=~s/Ö/&Ouml;/g;                        $value=~s/%C3%96/&Ouml;/g;
    $value=~s/ß/&szlig;/g;                       $value=~s/%C3%9F/&szlig;/g;
    return $value;
}

#----------------------------------------------------------------------------
# Replace HTML entities with their german Umlauts equivalent in UTF-8.
# replace_umlauts and replace_html_umlauts must match!
#----------------------------------------------------------------------------
sub replace_html_umlauts($)
{
    my ($value) = shift;
    # HTML Kodierung wird nach UTF-8 gewandelt:
    $value=~s/&uuml;/ü/g;
    $value=~s/&auml;/ä/g;
    $value=~s/&ouml;/ö/g;
    $value=~s/&Uuml;/Ü/g;
    $value=~s/&Auml;/Ä/g;
    $value=~s/&Ouml;/Ö/g;
    $value=~s/&szlig;/ß/g;
    return $value;
}

#----------------------------------------------------------------------------
# Print a HTML page with an error message.
#----------------------------------------------------------------------------
sub print_error_page($)
{
    my ($msg) = shift;
    my $gfx = '<img src="/brg/bgico/stop.png" width="75" height="75" alt="Stopp">';
    my $back = '<a href="/cgi-bin/brg/berg.pl" title="Gemeinedezeitungs-Generator erneut laden">'
              .'<img src="/brg/bgico/berg-32.png" width="32" height="32" border="0"></a>'."\n";
    print header('-charset' => 'utf-8'),
          start_html('-title'     => 'Fehler',
                     '-bgcolor'   => 'tomato',
                     '-fontcolor' => 'yellow',
                     '-encoding'  => 'utf-8',
                     '-lang'      => 'de'
          );
    print h2({'-align'=>'center'}, "*\n");
    print table(
        {'-align'=>'center',  '-border' => 8, '-bgcolor' => 'khaki' }, "\n",
        th($gfx), th(replace_umlauts(escapeHTML($msg))), td(replace_umlauts($back))
        ),
        h2({'-align'=>'center'}, "*\n");
    print p({'-id'=>'opresult'}, 'Result: Error.');
    print_html_version();
    print end_html();
    exit 1;
}

#----------------------------------------------------------------------------
# Print the version information (script and Perl).
#----------------------------------------------------------------------------
sub print_html_version()
{
    print "\n";
    print '<p class="version">Version: '.$VERSION." (Perl $])</p>\n";
}

;
