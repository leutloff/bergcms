#!/bin/bash -e
#
# Updates the git repository and executes the build script in the Build VM using ssh.
# For the initial setup execute the script build_git_clone_on_remote_buildhost.sh.
#
# Copyright 2013 Christian Leutloff <leutloff@sundancer.oche.de>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH=ssh
SCP=scp
BUILDHOST=remote-hostname
WORKDIR=~/work

# Override any variables above by placing them into a file named remotehosts.cfg.
# This is especially useful for the BUILDHOST. Just copy the lines from above to the file
# and change them as needed.
if [ -r $SOURCEDIR/remotehosts.cfg ]; then
    echo "Using $SOURCEDIR/remotehosts.cfg for local adaptations."
    . $SOURCEDIR/remotehosts.cfg
else
    echo "$SOURCEDIR/remotehosts.cfg for local adaptations is not available and therefore not used."
fi

# Source directory
BERGDIR=$WORKDIR/bergcms
# Absolute path on Build Host to store the makefile, the object files and the ZIP file.
BUILDDIRONBUILDHOST=$WORKDIR/berg-build-mk-$BUILDHOST

echo "Build on $BUILDHOST in directoriues for src $BERGDIR and for results $BUILDDIRONBUILDHOST..."

# Build
#ssh debian-squeeze /home/leutloff/work/bergcms/make_zip.sh
$SSH $BUILDHOST "cd $BERGDIR && git pull && git submodule update --init --recursive && ./make_zip.sh $BUILDDIRONBUILDHOST"

mkdir -p $SOURCEDIR/archive
actualArchive=$(ssh $BUILDHOST "ls -t $BUILDDIRONBUILDHOST/Berg*.zip | head -1")
$SCP $BUILDHOST:$actualArchive $SOURCEDIR/archive/
pushd $SOURCEDIR/archive
ls -l $(basename $actualArchive)
unzip $(basename $actualArchive)
popd

echo "Execute the following commands to deploy the build sources to the test instance:"
echo "cd $SOURCEDIR/archive/$(basename $actualArchive .zip) && ./deploy.sh -t test -c all && ./deploy.sh -t test -c testcases"

echo "done."

exit 0;
