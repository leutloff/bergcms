#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "X$1" == "X" ]; then 
    BUILDDIR=$SOURCEDIR/build-mk-$(hostname)
else
    BUILDDIR=$1
fi
echo "Build project, run head less unit tests and make package (in $BUILDDIR)..."

mkdir -p $BUILDDIR
pushd $BUILDDIR

# remove cache from last build to ensure a fresh configuration
if [ -r CMakeCache.txt ]; then
    rm -f CMakeCache.txt
fi

#cmake -DCMAKE_VERBOSE_MAKEFILE=FALSE -DCMAKE_BUILD_TYPE=Distribution -DBoost_DEBUG=FALSE $SOURCEDIR/src
cmake -DCMAKE_VERBOSE_MAKEFILE=TRUE -DCMAKE_BUILD_TYPE=Distribution -DBoost_DEBUG=FALSE $SOURCEDIR/src
make
pushd test && ./bergunittests && popd
make package berg_extract

popd

ls -l $BUILDDIR/Berg*.zip

exit 0;
