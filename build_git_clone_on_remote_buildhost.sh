#!/bin/bash -e
# Executes the git clone command in the Build VM using ssh.

SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH=ssh
BUILDHOST=remote-hostname
WORKDIR=~/work
GITCLONE="git clone -b master https://github.com/leutloff/berg.git berg"

# Override any variables above by placing them into a file named remotehosts.cfg.
# This is especially useful for the BUILDHOST. Just copy the lines from above to the file
# and change them as needed.
if [ -r $SOURCEDIR/remotehosts.cfg ]; then
    echo "Using $SOURCEDIR/remotehosts.cfg for local adaptations."
    . $SOURCEDIR/remotehosts.cfg
else
    echo "$SOURCEDIR/remotehosts.cfg for local adaptations is not available and therefore not used."
fi

echo "Build on $BUILDHOST with git command $GITCLONE..."

# Build
#ssh debian-squeeze /home/leutloff/work/berg/make_zip.sh
$SSH $BUILDHOST "mkdir -p $WORKDIR && cd $WORKDIR && $GITCLONE && ls -l $WORKDIR/berg"

echo "done."
echo "Check that the boost libraries are installed for development."
echo "Use boost version 1.49 if unsure."
echo "Steps to build boost version 1.49 packed for Debian Wheezy on a"
echo "Debian Squeeze system is described in this script."

exit 0;


Building boost 1.49.0 from Debian Wheezy on Debian Squeeze (nearly 3.8 GB disk space required for the build!):

# apt-get install build-essential debhelper zlib1g-dev libbz2-dev libicu-dev mpi-default-dev bison flex docbook-to-man help2man xsltproc doxygen python python-all-dev python3 python3-all-dev

$ cd boost-build
$ wget http://ftp.de.debian.org/debian/pool/main/b/boost1.49/boost1.49_1.49.0-3.2.dsc http://ftp.de.debian.org/debian/pool/main/b/boost1.49/boost1.49_1.49.0.orig.tar.bz2 http://ftp.de.debian.org/debian/pool/main/b/boost1.49/boost1.49_1.49.0-3.2.debian.tar.gz
$ dpkg-source -x boost1.49_1.49.0-3.2.dsc
$ cd boost1.49-1.49.0/
$ dpkg-buildpackage -rfakeroot -b
$ cd ..
# dpkg -i libboost1.49-dev_1.49.0-3.2_amd64.deb libboost-system1.49.0_1.49.0-3.2_amd64.deb libboost-system1.49-dev_1.49.0-3.2_amd64.deb libboost-chrono1.49.0_1.49.0-3.2_amd64.deb libboost-chrono1.49-dev_1.49.0-3.2_amd64.deb libboost-date-time1.49.0_1.49.0-3.2_amd64.deb libboost-date-time1.49-dev_1.49.0-3.2_amd64.deb libboost-filesystem1.49.0_1.49.0-3.2_amd64.deb libboost-filesystem1.49-dev_1.49.0-3.2_amd64.deb libboost-iostreams1.49.0_1.49.0-3.2_amd64.deb libboost-iostreams1.49-dev_1.49.0-3.2_amd64.deb libboost-program-options1.49.0_1.49.0-3.2_amd64.deb libboost-program-options1.49-dev_1.49.0-3.2_amd64.deb libboost-regex1.49.0_1.49.0-3.2_amd64.deb libboost-regex1.49-dev_1.49.0-3.2_amd64.deb libboost-serialization1.49.0_1.49.0-3.2_amd64.deb libboost-serialization1.49-dev_1.49.0-3.2_amd64.deb libboost-signals1.49.0_1.49.0-3.2_amd64.deb libboost-signals1.49-dev_1.49.0-3.2_amd64.deb libboost-test1.49.0_1.49.0-3.2_amd64.deb libboost-test1.49-dev_1.49.0-3.2_amd64.deb libboost-locale1.49.0_1.49.0-3.2_amd64.deb libboost-locale1.49-dev_1.49.0-3.2_amd64.deb libboost-thread1.49.0_1.49.0-3.2_amd64.deb libboost-thread1.49-dev_1.49.0-3.2_amd64.deb 
