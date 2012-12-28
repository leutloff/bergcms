#!/usr/bin/perl -w

use strict;
use warnings;

use utf8;
use Test::More tests => 20;
use BERG::PEX qw(add_author add_bold add_caption add_italic 
                 get_tex_content
                 replace_characters);

#TODO: {
#    local $TODO = '... not yet implemented';
#    ok( 2 + 2 == 5 );
#}

ok('& ' eq replace_characters('& '));
my $result = replace_characters('§ ');
ok('\S ' eq $result, $result);
ok(' 1234&1234 ' eq replace_characters(' 1234&1234 '));

$result = add_italic('italic');
#ok('\textit{\normalsize'."\n".'italic}' eq $result);
ok('\textit{\normalsize'." ".'italic}' eq $result);
 
$result = add_author('add_author');
#print '+'.$result.'+';
ok('\textit{\small '.'add_author}'."\n".'\bigskip' eq $result);#, $result);

$result = add_bold('add_bold');
#print '+'.$result.'+';
ok('\textbf{add_bold}' eq $result);

$result = add_caption('add_caption');
#print '+'.$result.'+'."\n";
ok('\textbf{~\\\\'."\n".'add_caption}'."\n".'\vspace{.5\baselineskip plus 1ex minus 0.5ex}' eq $result);


# Testing column handling
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
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'4'".' Spalten wird ignoriert.'."\n".
        $enddocument eq $result);#, $result);
}
{
    # not a column number
    my %idx = ();
    $idx{$startkey.'1'} = $startarticle.'>SPALTEN#2b'.'<br>';
    $result = get_tex_content(\%idx);
    #print '+'.$result.'+'."\n";
    ok($begindocument.
        '% Nur 1, 2 oder 3 Spalten sind erlaubt. Die Angabe von '."'2b'".' Spalten wird ignoriert.'."\n".
        $enddocument eq $result);#, $result);
}
