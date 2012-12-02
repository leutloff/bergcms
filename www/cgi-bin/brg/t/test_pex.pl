#!/usr/bin/perl -w

use strict;
use warnings;

use utf8;
use Test::More tests => 5;
use BERG::PEX qw(add_italic add_author
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
ok('\textit{\small '.'add_author}'."\n".'\bigskip' eq $result, $result);



