#!/usr/bin/perl -w
# Testing column handling

use strict;
use warnings;

use utf8;
use Test::More tests => 17;
use BERG::PEX qw(get_tex_content);

my $result = '';



my $begindocument = '% AI: ai1'."\n".
        '\message{[AI: ai1] title}'."\n".
        '\section{kap}'."\n".
        '\subsection{title}'."\n";
my $enddocument = '\end{document}%'."\n";
my $beginarticle1 = '% AI: ai1'."\n".
        '\message{[AI: ai1] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle2 = '% AI: ai2'."\n".
        '\message{[AI: ai2] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle3 = '% AI: ai3'."\n".
        '\message{[AI: ai3] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle4 = '% AI: ai4'."\n".
        '\message{[AI: ai4] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle5 = '% AI: ai5'."\n".
        '\message{[AI: ai5] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle6 = '% AI: ai6'."\n".
        '\message{[AI: ai6] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle7 = '% AI: ai7'."\n".
        '\message{[AI: ai7] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle8 = '% AI: ai8'."\n".
        '\message{[AI: ai8] title}'."\n".
        '\subsection{title}'."\n";
my $beginarticle9 = '% AI: ai9'."\n".
        '\message{[AI: ai9] title}'."\n".
        '\subsection{title}'."\n";
my $startkey = "chapter\x09number\x09title\x09ai";# Key=chapter+number+title+articleindex
my $startarticle_a  = "kap\x09tnr\x09title\x09A\x09";
my $startarticle    = $startarticle_a;
my $startarticle_a1 = "kap\x09tnr\x09title\x09A1\x09";
my $startarticle_a2 = "kap\x09tnr\x09title\x09A2\x09";
my $startarticle_f  = "kap\x09tnr\x09title\x09F\x09";
my $startarticle_f1 = "kap\x09tnr\x09title\x09F1\x09";
my $startarticle_f2 = "kap\x09tnr\x09title\x09F2\x09";

{
    #print 'no column set - empty document';
    my %idx = ();
    $result = get_tex_content(\%idx);
    #print 'result: ', $result;
    ok(''.$enddocument eq $result);
}
{
    #print 'single column set - 1';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print 'result: ', $result;
    ok($beginarticle1.''.$enddocument eq $result);#, $result);
}
{
    #print 'single column set - 2';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2'.'<br>';
    $result = get_tex_content(\%idx);
    #print 'result: ', $result;
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'two column set (2, 1)'; 
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle_f.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print 'result: ', $result;
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        $beginarticle2.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set (2,1,2)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle_a1.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle_a1.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1..
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $beginarticle2.
        $beginarticle3.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set (2,1,2,1)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_f.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle_f.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle_f.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'4'} = $startarticle_f.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        $beginarticle2.
        '\end{multicols}%'."\n".
        $beginarticle3.
        '\begin{multicols}{2}%'."\n".
        $beginarticle4.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a.'>SPALTEN#2 '.'<br>'.'>SPALTEN#1'.'<br>'.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set (2,1,2,1) - with comments (%)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a.'>SPALTEN#2 % two cols'.'<br>';
    $idx{$startkey.'2'} = $startarticle_a.'>SPALTEN#1%now back to single'.'<br>';
    $idx{$startkey.'3'} = $startarticle_a.'>SPALTEN#2   % two again   '.'<br>';
    $idx{$startkey.'4'} = $startarticle_a.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}% two cols'."\n".
        $beginarticle2.
        '\end{multicols}%now back to single'."\n".
        $beginarticle3.
        '\begin{multicols}{2}% two again   '."\n".
        $beginarticle4.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article - with comments (%)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2 '.'<br>'.'>SPALTEN#1%single col - 100%'.'<br>'.'>SPALTEN#2% two cols - 50 %'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%single col - 100\%'."\n".
        '\begin{multicols}{2}% two cols - 50 \%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'alternating column set (2,1,2,1) - with comments (#)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2 # two cols'.'<br>';
    $idx{$startkey.'2'} = $startarticle_a2.'>SPALTEN#1#now back to single'.'<br>';
    $idx{$startkey.'3'} = $startarticle_a1.'>SPALTEN#2   # two again   '.'<br>';
    $idx{$startkey.'4'} = $startarticle_a2.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}% two cols'."\n".
        $beginarticle2.
        '\end{multicols}%now back to single'."\n".
        $beginarticle3.
        '\begin{multicols}{2}% two again   '."\n".
        $beginarticle4.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article - with comments (% and #)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2 # now with both - 100 % true'.'<br>'.'>SPALTEN#1%single col - 100%'.'<br>'.'>SPALTEN#2% two cols - #2  '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}% now with both - 100 \% true'."\n".
        '\end{multicols}%single col - 100\%'."\n".
        '\begin{multicols}{2}% two cols - #2  '."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'ignoring same column no (2,2,1,1,2,2)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle_a1.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle_a2.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'3'} = $startarticle_a2.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'4'} = $startarticle_a1.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'5'} = $startarticle_a1.'>SPALTEN#2 '.'<br>'.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'6'} = $startarticle_a2.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        $beginarticle2.
        $beginarticle3.
        '\end{multicols}%'."\n".
        $beginarticle4.
        $beginarticle5.
        '\begin{multicols}{2}%'."\n".
        $beginarticle6.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print '13 - ignoring same column no (1,1,2,2,1,1)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'5'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'6'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        $beginarticle2.
        $beginarticle3.
        '\begin{multicols}{2}%'."\n".
        $beginarticle4.
        $beginarticle5.
        '\end{multicols}%'."\n".
        $beginarticle6.
        $enddocument eq $result);#, $result);
}

{
    #print 'ignoring same column no (2,2,2,1,1,1,2,2,2)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#2'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'5'} = $startarticle.'>SPALTEN#2'.'<br>'.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'6'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '\begin{multicols}{2}%'."\n".
        $beginarticle2.
        $beginarticle3.
        '\end{multicols}%'."\n".
        $beginarticle4.
        $beginarticle5.
        '\begin{multicols}{2}%'."\n".
        $beginarticle6.
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'ignoring same column no (1,1,1,3,3,3,1,1,1)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#3'.'<br>';
    $idx{$startkey.'5'} = $startarticle.'>SPALTEN#3'.'<br>';
    $idx{$startkey.'6'} = $startarticle.'>SPALTEN#3'.'<br>';
    $idx{$startkey.'7'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'8'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'9'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        $beginarticle2.
        $beginarticle3.
        $beginarticle4.
        '\begin{multicols}{3}%'."\n".
        $beginarticle5.
        $beginarticle6.
        $beginarticle7.
        '\end{multicols}%'."\n".
        $beginarticle8.
        $beginarticle9.
        $enddocument eq $result);#, $result);
}

{
    # column number other than 1,2,3
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#4'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'4'".' Spalten wird ignoriert (print_columns).'."\n".
        $enddocument eq $result);#, $result);
}
{
    # not a column number
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2b'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($beginarticle1.
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'2b'".' Spalten wird ignoriert (print_columns).'."\n".
        $enddocument eq $result);#, $result);
}
