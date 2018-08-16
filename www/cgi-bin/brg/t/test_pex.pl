#!/usr/bin/perl -w
# here are any functions tested.

use strict;
use warnings;

use utf8;
use Test::More tests => 43;

use lib '.';
use BERG::PEX qw(add_author add_bold add_caption add_italic 
                 replace_characters dbquote);

#TODO: {
#    local $TODO = '... not yet implemented';
#    ok( 2 + 2 == 5 );
#}

ok('& ' eq replace_characters('& '));
my $result = replace_characters('§ ');
ok('\S ' eq $result, $result);
ok(' 1234&1234 ' eq replace_characters(' 1234&1234 '));

# Testing dbquote: Replaces the quotation marks (" and ?/“) with german quotation marks \glqq and \grqq.
$result = replace_characters('"Hallo"');
ok('\\textit{\\glqq Hallo\\grqq}' eq $result, $result);
$result = replace_characters('“Hallo”');
ok('\\textit{\\glqq Hallo\\grqq}' eq $result, $result);
$result = replace_characters('"`Hallo"\'');# Remains unchanged
ok('"`Hallo"\'' eq $result, $result);
$result = replace_characters('a"Hallo"a');# Remains unchanged
ok('a"Hallo"a' eq $result, $result);
$result = replace_characters('"-Hallo"');# Remains unchanged
ok('"-Hallo"' eq $result, $result);
$result = replace_characters(' "Hallo" ');
ok(' \\textit{\\glqq Hallo\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo." ');
ok(' \\textit{\\glqq Hallo.\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo Christian." ');
ok(' \\textit{\\glqq Hallo Christian.\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo, Christian." ');
ok(' \\textit{\\glqq Hallo, Christian.\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo?" ');
ok(' \\textit{\\glqq Hallo?\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo!" ');
ok(' \\textit{\\glqq Hallo!\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo," ');
ok(' \\textit{\\glqq Hallo,\\grqq} ' eq $result, $result);
$result = replace_characters(' "Hallo". ');
ok(' \\textit{\\glqq Hallo\\grqq}. ' eq $result, $result);
$result = replace_characters(' "Hallo", ');
ok(' \\textit{\\glqq Hallo\\grqq}, ' eq $result, $result);
$result = replace_characters(' "Hallo", "Hallo", ');
ok(' \\textit{\\glqq Hallo\\grqq}, \\textit{\\glqq Hallo\\grqq}, ' eq $result);#, $result);
$result = replace_characters(' "Hallo19"? ');
ok(' \\textit{\\glqq Hallo19\\grqq}? ' eq $result, $result);
$result = replace_characters(' "Hallo20." und so "weiter"... ');
my $expected = ' \\textit{\\glqq Hallo20.\\grqq} und so \\textit{\\glqq weiter\\grqq}\\ldots\\ ';
ok($expected eq $result);#, $expected. '--' . $result);
$result = replace_characters(' "Hallo21." und so "`weiter"\'... ');
$expected = ' \\textit{\\glqq Hallo21.\\grqq} und so "`weiter"\'\\ldots\\ ';
ok($expected eq $result);#, $expected. '--' . $result);
$result = replace_characters('...');
ok('\\ldots\\ ' eq $result, $result);
$result = replace_characters('...?');
ok('\\ldots?' eq $result, $result);
$result = replace_characters('...!');
ok('\\ldots!' eq $result, $result);
$result = replace_characters('....');
ok('\\ldots.' eq $result, $result);

$result = replace_characters('26Wir planen Aktionen wie "lebendes Denkmal", "MarioKart", "Erfrischungsstand", "Kicker",');
$expected = '26Wir planen Aktionen wie \textit{\glqq lebendes Denkmal\grqq}, \textit{\glqq MarioKart\grqq}, \textit{\glqq Erfrischungsstand\grqq}, \textit{\glqq Kicker\grqq},';
ok($expected eq $result);#, $expected. '--' . $result);

$result = replace_characters('Wir planen Aktionen wie "lebendes Denkmal", "MarioKart", "Erfrischungsstand", "Kicker",
"Fahrrad putzen", "`Grillen"\' und natürlich ganz viele persönliche Gespräche sowie konkrete Einladungsaktionen. Wir haben Gottes Wirken schon im Vorbereitungsprozess erfahren und freuen uns auf die Woche Anfang Juni.');
$expected = 'Wir planen Aktionen wie \textit{\glqq lebendes Denkmal\grqq}, \textit{\glqq MarioKart\grqq}, \textit{\glqq Erfrischungsstand\grqq}, \textit{\glqq Kicker\grqq},
\textit{\glqq Fahrrad putzen\grqq}, "`Grillen"\' und natürlich ganz viele persönliche Gespräche sowie konkrete Einladungsaktionen. Wir haben Gottes Wirken schon im Vorbereitungsprozess erfahren und freuen uns auf die Woche Anfang Juni.';
ok($expected eq $result);#, $expected. '--' . $result);

$result = replace_characters('“Weil wir heute immer noch sind, wie wir gestern waren.”');
ok('\\textit{\\glqq Weil wir heute immer noch sind, wie wir gestern waren.\\grqq}' eq $result);#, $result);

# Tel: -> telephone symbole
$result = replace_characters('Tel:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters(' Tel: ');
ok(' \ding{37} ' eq $result, $result);
$result = replace_characters('tel:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters('tEl:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters('Tel.:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters(' Tel.: ');
ok(' \ding{37} ' eq $result, $result);
$result = replace_characters('tel.:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters('tEl.:');
ok('\ding{37}' eq $result, $result);
$result = replace_characters('Titel:');
ok('Titel:' eq $result, $result);
$result = replace_characters(' Titel: ');
ok(' Titel: ' eq $result, $result);

$result = add_italic('italic');
#ok('\textit{\normalsize'."\n".'italic}' eq $result);
ok('\textit{\normalsize'." ".'italic'."\n".'}' eq $result);
 
$result = add_author('add_author');
#print '+'.$result.'+';
ok('\textit{\small '.'add_author'."\n".'}'."\n".'\bigskip' eq $result);#, $result);
$result = add_author('add author - 100 % ');
#print '+'.$result.'+';
ok('\textit{\small '.'add author - 100 % '."\n".'}'."\n".'\bigskip' eq $result);#, $result);

$result = add_bold('add_bold');
#print '+'.$result.'+';
ok('\textbf{add_bold'."\n".'}' eq $result);

$result = add_caption('add_caption');
#print '+'.$result.'+'."\n";
ok('\textbf{~\\\\'."\n".'add_caption'."\n".'}'."\n".'\vspace{.5\baselineskip plus 1ex minus 0.5ex}' eq $result);

