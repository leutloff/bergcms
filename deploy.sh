#!/bin/bash -e
#
# Deploy the surrounding files of an extracted build archive to a testing host
# or to the production host. It is possible to deploy the whole application or
# only specific parts.
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

DEPLOYHOST=remote-hostname
HTDOCSDEPLOYDIR=/home/aachen/htdocs/brg/
CGIBINDEPLOYDIR=/home/aachen/cgi-bin/brg/

FTPPUT="ncftpput"
FTPUSER=
FTPPASS=
LOGINCFG=~/.ssh/ftplogin.cred
FTPLOGFILE=deploy.log
DEPLOYTO=test

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
    echo "       deploy [-l ftplogin.cred] [-u user] [-p password] [-t test|prod] -c component"
    echo ""
    echo "Known components for deployment:"
    echo " all     all known components"
    echo " html    static HTML files"
    echo " css     CSS files"
    echo " js      Javascript files - libraries and specific"
    echo " htdocs  static HTML, CSS and Javascript files"
    echo " libs    boost and ctemplate libraries" 
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
        l)  LOGINCFG==$OPTARG
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
            if [ "all" == $OPTARG -o "libs" == $OPTARG -o \
                 "html" == $OPTARG -o "css" == $OPTARG -o "js" == $OPTARG -o "htdocs" == $OPTARG  ]; then
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

if [ X"$DEPLOYTO" == X ]; then
    DEPLOYTO=test
fi

if [ X"$LOGINCFG" == X ]; then
    if [ "$DEPLOYTO" == prod ]; then
        LOGINCFG=ftplogin.cred
    else
        LOGINCFG=ftplogintest.cred
    fi
fi
 
echo "Deploy $COMPONENT to $DEPLOYTO..."


# FTP parameters
if [ -n "$FTPLOGFILE" ]; then FTPLOG="-d $FTPLOGFILE"; fi
USETMPFILE="-S .tmp"
if [ -n "$LOGINCFG" ]; then FTPLOGINPARAM="-f $LOGINCFG"; 
else
    if [ -n "$FTPUSER" ]; then 
        if [ -n "$FTPPASS" ]; then 
            FTPLOGINPARAM="-u $FTPUSER";
        else
            FTPLOGINPARAM="-u $FTPUSER -p $FTPPASS";
        fi
    fi
fi

FTPPUTPARAM="$FTPLOG $FTPLOGINPARAM $USETMPFILE"


function deploy_html {
    echo "deploy_html ..."
    $FTPPUT $FTPPUTPARAM $HTDOCSDEPLOYDIR htdocs/brg/*.html
}
function deploy_css {
    echo "deploy_css ..."
}
function deploy_js {
    echo "deploy_js ..."
}

function deploy_libs {
    echo "deploy_libs ..."
    $FTPPUT $FTPPUTPARAM $CGIBINDEPLOYDIR cgi-bin/brg/libs/*
}

# remove log file
echo
if test -w $FTPLOGFILE; then rm $FTPLOGFILE; fi
            
case "$COMPONENT" in
    html)
        deploy_html
        ;;
    css)
        deploy_css
        ;;
    js)
        deploy_js
        ;;
    htdocs)
        deploy_html
        deploy_css
        deploy_js
        ;;
    all)
        deploy_html
        deploy_css
        deploy_js
        deploy_libs
        ;;
    libs)
        deploy_libs
        ;;
    *)
        echo "Invalid component: $COMPONENT" >&2
        print_usage
        ;;
esac

            


exit 0;



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
