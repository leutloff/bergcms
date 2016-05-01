#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELENIUM_PORT=4445

if [ "X$1" == "X" ]; then 
    BUILDDIR=$SOURCEDIR/build-mk-$(hostname)
else
    BUILDDIR=$1
fi
echo "Build project, run head less unit tests and make package (in $BUILDDIR)..."

# Starting the selenium server
set +e
nc -vz -w1 localhost $SELENIUM_PORT
if [ "$?" -ne 0 ]; then
     echo "Starting the selenium server..."
     npm start 2>&1 >/dev/null &
else
    echo "Selenium server already running."
fi
set -e

mkdir -p $BUILDDIR
pushd $BUILDDIR

# remove cache from last build to ensure a fresh configuration
if [ -r CMakeCache.txt ]; then
    rm -f CMakeCache.txt
fi

cmake -DCMAKE_VERBOSE_MAKEFILE=FALSE -DCMAKE_BUILD_TYPE=Distribution -DBoost_DEBUG=FALSE $SOURCEDIR/src
#cmake -DCMAKE_VERBOSE_MAKEFILE=TRUE -DCMAKE_BUILD_TYPE=Distribution -DBoost_DEBUG=FALSE $SOURCEDIR/src
make
echo "Running the C++ unit tests..."
pushd test && ./bergunittests && popd
make package

popd
#ls -l $BUILDDIR/Berg*.zip

# echo "Install the Berg CMS to test the web application..."
#    - unzip -q travis-build/$BERG_ARCHIVE
#    - mv $(basename $BERG_ARCHIVE .zip)/cgi-bin/brg $TRAVIS_BUILD_DIR/www-root/cgi-bin/
#    - chmod go-w $TRAVIS_BUILD_DIR/www-root/cgi-bin/brg
#    - mv $(basename $BERG_ARCHIVE .zip)/htdocs/brg $TRAVIS_BUILD_DIR/www-root/htdocs/
echo "Running the Perl unit tests..."
$SOURCEDIR/www/cgi-bin/brg/t/run_tests.sh

echo "Running the end to end tests using wdio..."
npm test

echo "done."
exit 0;
