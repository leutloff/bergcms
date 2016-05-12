#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELENIUM_PORT=4444

if [ "X$1" == "X" ]; then 
    BUILDDIR=$SOURCEDIR/build-mk-$(hostname)
else
    BUILDDIR=$1
fi
echo "Build project, run head less unit tests and make package (in $BUILDDIR)..."

# Folder where the files are copied to.
# Do not use for production because it overrides and deletes files without
# any warning. This is useful to get a consistent behaviour for testing.
#TARGETDIR=/home/bergcms
TARGETDIR=/var/www

# Override any variables above by placing them into a file named install_locally.cfg.
# This is especially useful for the TARGETDIR and the LOCAL*.
if [ -r $SOURCEDIR/install_locally.cfg ]; then
    . $SOURCEDIR/install_locally.cfg
fi

# Starting the selenium server
set +e
nc -z -w1 localhost $SELENIUM_PORT
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

echo "Running the Perl unit tests..."
$SOURCEDIR/www/cgi-bin/brg/t/run_tests.sh


# echo "Install the Berg CMS to test the web application..."
#    - unzip -q travis-build/$BERG_ARCHIVE
#    - mv $(basename $BERG_ARCHIVE .zip)/cgi-bin/brg $TRAVIS_BUILD_DIR/www-root/cgi-bin/
#    - chmod go-w $TRAVIS_BUILD_DIR/www-root/cgi-bin/brg
#    - mv $(basename $BERG_ARCHIVE .zip)/htdocs/brg $TRAVIS_BUILD_DIR/www-root/htdocs/
pushd $TARGETDIR
# unpacks the latest archive
BERG_ARCHIVE=$(ls -t $BUILDDIR/Berg*-$HOSTNAME.zip | head -n 1)
BERG_VERSION=$(echo $BERG_ARCHIVE | cut -d- -f2 -)
BERG_DIR=$(basename $BERG_ARCHIVE .zip)
unzip -o $BERG_ARCHIVE
popd

echo "Running the end to end tests using wdio..."
npm test

echo "done."
exit 0;
