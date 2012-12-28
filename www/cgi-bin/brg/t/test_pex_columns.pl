#!/usr/bin/perl -w
# Testing column handling

use strict;
use warnings;

use utf8;
use Test::More tests => 17;
use BERG::PEX qw(get_tex_content);

my $result = '';
my $begindocument = '';
my $enddocument = '';
my $startkey = "chapter\x09number\x09title\x09ai";# Key=chapter+number+title+articleindex
my $startarticle = "kap\x09tnr\x09titel\x09typ\x09";

{
    #print 'no column set - empty document';
    my %idx = ();
    $result = get_tex_content(\%idx);
    ok($begindocument.''.$enddocument eq $result);
}
{
    #print 'single column set - 1';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    ok($begindocument.''.$enddocument eq $result);#, $result);
}
{
    #print 'single column set - 2';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2'.'<br>';
    $result = get_tex_content(\%idx);
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'two column set (2, 1)'; 
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'alternating column set (2,1,2)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set (2,1,2,1)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>'.'>SPALTEN#1'.'<br>'.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set (2,1,2,1) - with comments (%)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 % two cols'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1%now back to single'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2   % two again   '.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}% two cols'."\n".
        '\end{multicols}%now back to single'."\n".
        '\begin{multicols}{2}% two again   '."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article - with comments (%)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>'.'>SPALTEN#1%single col - 100%'.'<br>'.'>SPALTEN#2% two cols - 50 %'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%single col - 100\%'."\n".
        '\begin{multicols}{2}% two cols - 50 \%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'alternating column set (2,1,2,1) - with comments (#)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 # two cols'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1#now back to single'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2   # two again   '.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}% two cols'."\n".
        '\end{multicols}%now back to single'."\n".
        '\begin{multicols}{2}% two again   '."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'alternating column set in single article - with comments (% and #)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 # now with both - 100 % true'.'<br>'.'>SPALTEN#1%single col - 100%'.'<br>'.'>SPALTEN#2% two cols - #2  '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}% now with both - 100 \% true'."\n".
        '\end{multicols}%single col - 100\%'."\n".
        '\begin{multicols}{2}% two cols - #2  '."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    #print 'ignoring same column no (2,2,1,1,2,2)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'5'} = $startarticle.'>SPALTEN#2 '.'<br>'.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'6'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}
{
    #print 'ignoring same column no (1,1,2,2,1,1)';
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'2'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'3'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'4'} = $startarticle.'>SPALTEN#2 '.'<br>';
    $idx{$startkey.'5'} = $startarticle.'>SPALTEN#1'.'<br>';
    $idx{$startkey.'6'} = $startarticle.'>SPALTEN#1'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
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
    ok($begindocument.
        '\begin{multicols}{2}%'."\n".
        '\end{multicols}%'."\n".
        '\begin{multicols}{2}%'."\n".
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
    ok($begindocument.
        '\begin{multicols}{3}%'."\n".
        '\end{multicols}%'."\n".
        $enddocument eq $result);#, $result);
}

{
    # column number other than 1,2,3
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#4'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'4'".' Spalten wird ignoriert (print_columns).'."\n".
        $enddocument eq $result);#, $result);
}
{
    # not a column number
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2b'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'2b'".' Spalten wird ignoriert (print_columns).'."\n".
        $enddocument eq $result);#, $result);
}
