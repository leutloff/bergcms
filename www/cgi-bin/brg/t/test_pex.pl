#!/usr/bin/perl -w
# here are any functions tested.

use strict;
use warnings;

use utf8;
use Test::More tests => 18;
use BERG::PEX qw(add_author add_bold add_caption add_italic 
                 replace_characters);

#TODO: {
#    local $TODO = '... not yet implemented';
#    ok( 2 + 2 == 5 );
#}

ok('& ' eq replace_characters('& '));
my $result = replace_characters('§ ');
ok('\S ' eq $result, $result);
ok(' 1234&1234 ' eq replace_characters(' 1234&1234 '));

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

