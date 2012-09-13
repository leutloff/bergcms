#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME=$(hostname)
BUILDDIR=$SOURCEDIR/build-mk-$HOSTNAME
echo "Build project and make package (in $BUILDDIR)..."


mkdir -p $BUILDDIR
pushd $BUILDDIR

cmake -DCMAKE_VERBOSE_MAKEFILE=FALSE -DCMAKE_BUILD_TYPE=Distribution -DBoost_DEBUG=FALSE ../src
make package berg_extract

popd

ls -l $BUILDDIR/Berg*.zip

exit 0;
