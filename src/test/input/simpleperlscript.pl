#!/usr/bin/perl
use strict;
use warnings;

use Cwd;
my $cwd = getcwd();
print $cwd."\n";

# return 0 - that is the expected return code from this simple script
# hmm - really another value is wished, but does not work 8-(
exit(0);
