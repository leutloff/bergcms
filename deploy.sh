#!/bin/bash -e
#
# Deploy the sourrounding files of an extracted build archive to a testing host
# and to the production host. It is possible to deploy the whole application or
# only specific parts.
#
# Copyright 20132013 Christian Leutloff <leutloff@sundancer.oche.de>
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

DEPLOYHOST=remote-hostname
DEPLOYDIR=/cgi-bin/brg

FTPPUT="ncftpput"
LOGINCFG=~/.ssh/ftplogin.cred
FTPLOGFILE=deploy.log

# Override any variables above by placing them into a file named remotehosts.cfg.
# This is especially useful for the BUILDHOST. Just copy the lines from above to the file
# and change them as needed.
if [ -r $SOURCEDIR/remotehosts.cfg ]; then
    echo "Using $SOURCEDIR/remotehosts.cfg for local adaptations."
    . $SOURCEDIR/remotehosts.cfg
else
    echo "$SOURCEDIR/remotehosts.cfg for local adaptations is not available and therefore not used."
fi

function print_usage {
    echo "Usage:"
    echo "       deploy [-u user] [-p password] [-t test|prod] -c component"
    exit 1;
}


while getopts ":hu:p:t:c:" opt; do
    case $opt in
        u)
            FTPUSER=$OPTARG
            ;;

        p)
            FTPPASS=$OPTARG
            ;;
        t)
            if [ "test" == $OPTARG -o "prod" == $OPTARG ]; then
                DEPLOYTO=$OPTARG
            else
                echo "Invalid deployment type: $OPTARG" >&2
                print_usage
            fi
            ;;
        c)
            if [ "all" == $OPTARG -o "libs" == $OPTARG ]; then
                COMPONENT=$OPTARG
            else
                echo "Invalid component name: $OPTARG" >&2
                print_usage
            fi
            ;;
        -h)
            print_usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            ;;
  esac
done
if [ -z $COMPONENT ]; then
    echo "Missing component."
    print_usage
fi

echo "Deploy $COMPONENT on $DEPLOYHOST in $DEPLOYDIR..."

exit 0;

FTPLOG="-d $FTPLOGFILE"
USETMPFILE="-S .tmp"

# remove log file
echo
if test -w $FTPLOGFILE; then rm $FTPLOGFILE; fi

# copy executables
#
for srv in berg maker pex.pl berg.pl bgcrud.pl bgul.pl xsc.pl; do
    echo "$FTPPUT $FTPLOG -f $LOGINCFG $USETMPFILE -X \"chmod 0755 $DEPLOYDIR/$srv\" $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv"
    # ncftpput [options] remote-host remote-directory local-files.
    # ncftpput -f login.cfg [options] remote-directory local-files...
    $FTPPUT $FTPLOG -f $LOGINCFG $USETMPFILE -X "chmod 0755 $DEPLOYDIR/$srv" $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv
done

# copy cfg and other files - chmod 0644 rw-r--r--
for srv in berg.cfg berg.opt xsc; do
    echo "$FTPPUT $FTPLOG -f $LOGINCFG $USETMPFILE $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv"
    $FTPPUT $FTPLOG -f $LOGINCFG $USETMPFILE $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv
done

echo "done."

exit 0;
