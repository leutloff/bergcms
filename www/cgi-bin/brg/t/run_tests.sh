#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Running some tests for the perl scripts (started in $SOURCEDIR)..."


pushd $SOURCEDIR

#perl -I$SOURCEDIR/.. pex.pl
mkdir -p BERG
cp $SOURCEDIR/../pex.pl BERG/PEX.pm
perl test_pex.pl

popd

exit 0;
