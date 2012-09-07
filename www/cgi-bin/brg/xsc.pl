#!/usr/bin/perl -w
#############################################################################
# Executes the commands in the xsc script. Superceeded by maker, but
# can still be used as a backup solution.
#
# (c) 2007 Heiko Decker
# (c) 2012 Christian Leutloff
#
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
#############################################################################
 
use strict;
use warnings;

use CGI qw/:standard/;
use Fcntl qw/:flock/;    # LOCK_EX etc. definieren

my $VERSION="v1.04, 12.08.2012";

#----> function prototypes of the shared functions --------
sub replace_umlauts($);
sub replace_html_umlauts($);
sub print_error_page($);
sub print_version();

#$Redir='/cgi-bin/xview.pl?AW=berg&VPI=!e&VFI=*bcdei';
# Empfangene Paramter an den Redirect weitergeben, so dass quasi die gleiche Seite wieder erscheint.
my $Redir='/cgi-bin/brg/berg.pl?';
if (defined param('AW')) { $Redir.='AW='.param('AW').'&'; }
if (defined param('VFI')) { $Redir.='VFI='.param('VFI').'&'; }
if (defined param('VPI')) { $Redir.='VPI='.param('VPI').'&'; }

# Pfaddefinitionen, die im Shellscript ersetzt werden
my $BERGLOGDIR='log';
my $BERGDBDIR='br';
my $BERGOUTDIR='out';
my $BERGDLBDIR='../../htdocs/dlb';

#system("ls -la>log.txt");
bef_seq();

print redirect($Redir);                          # Abschluß


sub bef_seq #Script als EinzeilerSeq  aufrufen! 4.7.2007
    {
    my $datei="xsc.sh";
    open (my $INPX, "<", "$datei");
    flock($INPX, LOCK_SH) || print_error_page("Fehler: Konnte die Datei $datei nicht zum Lesen sperren (".$!.")!");
    while(<$INPX>)
        {
        chomp;
        next if /^#/;
        s/\$BERGLOGDIR/$BERGLOGDIR/g;
        s/\$BERGDBDIR/$BERGDBDIR/g;
        s/\$BERGOUTDIR/$BERGOUTDIR/g;
        s/\$BERGDLBDIR/$BERGDLBDIR/g;
        #system("echo $_ >>log.txt");
        system("$_");
        }
    flock($INPX, LOCK_UN) || print_error_page("Fehler: Konnte zum Lesen gesperrte Datei $datei nicht freigeben (".$!.")!");
    close($INPX);
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
