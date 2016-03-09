#!/bin/bash -e
#
# Deploy the surrounding files of an extracted build archive to a testing host
# or to the production host. It is possible to deploy the whole application or
# only specific parts. This script uses scp and ssh.
#
# Copyright 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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

# HTDOCSDEPLOYDIR=/home/aachen/htdocs/brg
# CGIBINDEPLOYDIR=/home/aachen/cgi-bin/brg
# Required by production system FTP daemon:
#HTDOCSDEPLOYDIR=/htdocs/brg
HTDOCSDEPLOYDIR=/var/www/clients/client1/web1/web/brg
#CGIBINDEPLOYDIR=/cgi-bin/brg
CGIBINDEPLOYDIR=/var/www/clients/client1/web1/cgi-bin/brg

SCP="scp"
SSH="ssh"
FTPLOGFILE=deploy_ssh.log
#DEPLOYTO=test
DEPLOYTO=bergcms1@bergcms.local

# Override any variables above by placing them into a file named remotehosts.cfg.
# This is especially useful for the BUILDHOST. Just copy the lines from above to the file
# and change them as needed.
if [ -r $SOURCEDIR/remotehosts.cfg ]; then
    echo "Using $SOURCEDIR/remotehosts.cfg for local adaptations."
    . $SOURCEDIR/remotehosts.cfg
elif [ -r $SOURCEDIR/../remotehosts.cfg ]; then
    echo "Using $SOURCEDIR/../remotehosts.cfg for local adaptations."
    . $SOURCEDIR/../remotehosts.cfg
else
    echo "$SOURCEDIR/remotehosts.cfg for local adaptations is not available and therefore not used."
fi

function print_version {
    echo "Berg CMS Deployment Script using SSH, v0.2, 2016-03-05"
}

function print_usage {
    print_version   
    echo ""
    echo "Usage:"
    echo "       $0 [-h][-v]"
    echo "       $0 [-t test|prod] -c component"
    echo ""
    echo "Known components for deployment:"
    echo " all         all known components except the testcases"
    echo "   html      static HTML files"
    echo "   css       CSS files"
    echo "   js        Javascript files - libraries and specific"
    echo "  htdocs     static HTML, CSS and Javascript files (=html+css+js)"
    echo "   perllibs  Perl libraries (Diff.pm/Merge.pm) "
    echo "   dynlibs   boost and ctemplate libraries"
    echo "  libs       all the libraries (C/C++ and Perl) (=perllibs+dynlibs)"
    echo "   perl      Perl based parts of the web application"
    echo "   templates templates used by the web application"
    echo "   srv       C++ based parts of the web application"
    echo "  servers    the executable parts of the web application (=perl+templates+srv)"
    echo "  latex      the text processing related files (LaTeX)"
    echo ""
    echo " testcases additional files used for test cases only!"
    echo "           Use on test deployments only, because the initial database"
    echo "           is deployed and thus removing any existing content."
    echo "           This component can only be installed the test type."
    echo ""
    echo "Options:"
    echo "   -h prints this help text and exits"
    echo "   -v prints the version and exits"
    echo ""
    echo "   -t deploy to the test server or the production server"
    echo ""
    exit 1;
}


while getopts ":c:hu:p:t:v" opt; do
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
            if [ "all" == $OPTARG -o "testcases" == $OPTARG -o "latex" == $OPTARG -o \
                 "html" == $OPTARG -o "css" == $OPTARG -o "js" == $OPTARG -o "htdocs" == $OPTARG -o \
                 "perllibs" == $OPTARG -o "dynlibs" == $OPTARG -o "libs" == $OPTARG -o \
                 "perl" == $OPTARG -o "templates" == $OPTARG -o "srv" == $OPTARG -o "servers" == $OPTARG ]; then
                COMPONENT=$OPTARG
            else
                echo "Invalid component name: $OPTARG" >&2
                print_usage
            fi
            ;;
        h)
            print_usage
            ;;
        v)
            print_version
            exit 1;
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
        LOGINCFG=~/.ssh/ftplogin.cred
    else
        LOGINCFG=~/.ssh/ftplogintest.cred
    fi
fi
 
echo " *** Deploying component $COMPONENT to $DEPLOYTO..."


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

# -m Attempt to make the remote destination directory before copying.
FTPPUTPARAM="$FTPLOG $FTPLOGINPARAM $USETMPFILE -m"

# setting the source dirs
HTDOCSBRG=htdocs/brg
if [ ! -d $HTDOCSBRG ]; then
    # we are not in the archive but in the source directory!?
    if [ -d www/htdocs/brg ]; then HTDOCSBRG=www/htdocs/brg; fi
fi
CGIBINBRG=cgi-bin/brg
if [ ! -d $CGIBINBRG ]; then
    # we are not in the archive but in the source directory!?
    if [ -d www/cgi-bin/brg ]; then CGIBINBRG=www/cgi-bin/brg; fi
fi


function deploy_html {
    echo " * Deploying the static HTML pages and icons ..."
    $SSH $DEPLOYTO "mkdir -p $HTDOCSDEPLOYDIR/bgico/16x16 $HTDOCSDEPLOYDIR/bgico/22x22 $HTDOCSDEPLOYDIR/bgico/32x32 $HTDOCSDEPLOYDIR/../dlb"
    $SCP $HTDOCSBRG/*.html $DEPLOYTO:$HTDOCSDEPLOYDIR
    $SCP $HTDOCSBRG/bgico/*.png $DEPLOYTO:$HTDOCSDEPLOYDIR/bgico
    $SCP $HTDOCSBRG/bgico/16x16/*.png $DEPLOYTO:$HTDOCSDEPLOYDIR/bgico/16x16
    $SCP $HTDOCSBRG/bgico/22x22/*.png $DEPLOYTO:$HTDOCSDEPLOYDIR/bgico/22x22
    $SCP $HTDOCSBRG/bgico/32x32/*.png $DEPLOYTO:$HTDOCSDEPLOYDIR/bgico/32x32
    # Download Area (Download-Bereich) still outside of the brg directory
    $SCP $HTDOCSBRG/../dlb/README.txt $DEPLOYTO:$HTDOCSDEPLOYDIR/../dlb
}
function deploy_css {
    echo " * Deploying the CSS files incl. YAML ..."
    $SSH $DEPLOYTO "mkdir -p $HTDOCSDEPLOYDIR/css $HTDOCSDEPLOYDIR/css/yaml/core/js $HTDOCSDEPLOYDIR/css/yaml/forms $HTDOCSDEPLOYDIR/css/yaml/navigation $HTDOCSDEPLOYDIR/css/yaml/print $HTDOCSDEPLOYDIR/css/yaml/screen"
    $SCP $HTDOCSBRG/css/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css

    # Ommitted $HTDOCSBRG/css/yaml/*.css, because there are no files.
    $SCP $HTDOCSBRG/css/yaml/core/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/core 
    $SCP $HTDOCSBRG/css/yaml/core/js/*.js $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/core/js
    $SCP $HTDOCSBRG/css/yaml/forms/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/forms
    $SCP $HTDOCSBRG/css/yaml/navigation/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/navigation
    $SCP $HTDOCSBRG/css/yaml/print/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/print
    $SCP $HTDOCSBRG/css/yaml/screen/*.css $DEPLOYTO:$HTDOCSDEPLOYDIR/css/yaml/screen
}
function deploy_js {
    echo " * Deploying the Javascript files ..."
    $SSH $DEPLOYTO "mkdir -p $HTDOCSDEPLOYDIR/js"
   
    $SCP $HTDOCSBRG/js/*.js $DEPLOYTO:$HTDOCSDEPLOYDIR/js
}
function deploy_perl_libs {
    echo " * Deploying the Perl library files ..."
    $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/perl5/Algorithm"
    $SCP $CGIBINBRG/perl5/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/perl5
    $SCP $CGIBINBRG/perl5/Algorithm/*.pm $DEPLOYTO:$CGIBINDEPLOYDIR/perl5/Algorithm
}
function deploy_perl {
    echo " * Deploying the Perl files  ..."
    $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/gi_backup $CGIBINDEPLOYDIR/log $CGIBINDEPLOYDIR/out $CGIBINDEPLOYDIR/tidx"
    # Files with executable bit (chmod 0755 rwxr-xr-x)
    for srv in berg.pl bgcrud.pl bgul.pl pex.pl xsc.pl; do
        #echo "$SCP $FTPLOG -f $LOGINCFG $USETMPFILE -X \"chmod 0755 $DEPLOYDIR/$srv\" $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv"
        # ncftpput [options] remote-host remote-directory local-files.
        # ncftpput -f login.cfg [options] remote-directory local-files...
        #$SCP $DEPLOYTO:-X "chmod 0755 $CGIBINDEPLOYDIR/$srv" $CGIBINDEPLOYDIR $CGIBINBRG/$srv
        $SCP $CGIBINBRG/$srv $DEPLOYTO:$CGIBINDEPLOYDIR
    done
    # Copy the other files (chmod 0644 rw-r--r--)
    $SCP $CGIBINBRG/xsc.sh $DEPLOYTO:$CGIBINDEPLOYDIR
    # Create some directories required for proper operation
    $SCP $CGIBINBRG/gi_backup/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/gi_backup
    $SCP $CGIBINBRG/log/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/log
    $SCP $CGIBINBRG/out/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/out
    $SCP $CGIBINBRG/tidx/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/tidx
}
function deploy_dyn_libs {
    echo " * Deploying dynamic libraries (Boost and ctemplate) ..."
    $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/lib"
    for libwithpath in `ls cgi-bin/brg/lib/libboost_{chrono,date_time,filesystem,iostreams,program_options,regex,signals,system,thread,unit_test_framework}.so.* cgi-bin/brg/lib/libctemplate.so.*`; do
        lib=${libwithpath##*/}
        #$SCP $DEPLOYTO:-X "chmod 0755 $CGIBINDEPLOYDIR/lib/$lib" $CGIBINDEPLOYDIR/lib $libwithpath
        $SCP $libwithpath $DEPLOYTO:$CGIBINDEPLOYDIR/lib
    done
}
function deploy_latex {
    echo " * Deploying the LaTeX related files ..."
    $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/br/bilder $CGIBINDEPLOYDIR/br/data"
    $SCP $CGIBINBRG/br/sectsty.sty $CGIBINBRG/br/wrapfig.sty $CGIBINBRG/br/ucs.sty $CGIBINBRG/br/ucsencs.def $CGIBINBRG/br/utf8x.def $DEPLOYTO:$CGIBINDEPLOYDIR/br 
    $SCP $CGIBINBRG/br/bilder/berg.jpg $DEPLOYTO:$CGIBINDEPLOYDIR/br/bilder
    $SCP $CGIBINBRG/br/data/*.def $CGIBINBRG/br/data/*.dat $DEPLOYTO:$CGIBINDEPLOYDIR/br/data
    if [ -f latex/class_berg/generated/berg.cls ]; then
        $SCP latex/class_berg/generated/berg.cls $DEPLOYTO:$CGIBINDEPLOYDIR/br
    else
        $SCP $CGIBINBRG/br/berg.cls $DEPLOYTO:$CGIBINDEPLOYDIR/br
    fi
}
function deploy_templates {
    echo " * Deploying the templates for C++ based parts of the web application ..."
    $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/template $CGIBINDEPLOYDIR/archive_content"
    $SCP $CGIBINBRG/template/*.tpl $DEPLOYTO:$CGIBINDEPLOYDIR/template
    $SCP $CGIBINBRG/archive_content/README.txt $DEPLOYTO:$CGIBINDEPLOYDIR/archive_content
}
function deploy_srv {
    echo " * Deploying the C++ based parts of the web application ..."
    for srv in berg maker archive; do
        #$SCP $DEPLOYTO:-X "chmod 0755 $CGIBINDEPLOYDIR/$srv" $CGIBINDEPLOYDIR $CGIBINBRG/$srv
        $SCP $CGIBINBRG/$srv $DEPLOYTO:$CGIBINDEPLOYDIR
    done
}
function deploy_testcases {
    if [ "$DEPLOYTO" != test ]; then
        echo ""
        echo " * The component testcases is only supported for the type test."
        echo "   Ignoring this component, because type is '$DEPLOYTO'."
        echo ""
    else
        echo " * Deploying the testcases, initial database, favicon ..."
        $SSH $DEPLOYTO "mkdir -p $CGIBINDEPLOYDIR/br"
        for srv in testcase.pl; do
            #$SCP $DEPLOYTO:-X "chmod 0755 $CGIBINDEPLOYDIR/$srv" $CGIBINDEPLOYDIR $CGIBINBRG/$srv
            $SCP $CGIBINBRG/$srv $DEPLOYTO:$CGIBINDEPLOYDIR
        done
        # Initial database
        $SCP $CGIBINBRG/br/feginfo.csv $DEPLOYTO:$CGIBINDEPLOYDIR/br
        # favicon
        if [ -f www/htdocs/favicon.ico ]; then
            $SCP www/htdocs/favicon.ico $DEPLOYTO:htdocs
        else
            $SCP htdocs/brg/favicon.ico $DEPLOYTO:htdocs
        fi
    fi
}


# remove log file
echo
if test -w $FTPLOGFILE; then rm $FTPLOGFILE; fi
            
case "$COMPONENT" in
    all)
        deploy_css
        deploy_js
        deploy_perl_libs
        deploy_perl
        deploy_dyn_libs
        deploy_srv
        deploy_latex
        deploy_html
        ;;
    htdocs)
        deploy_html
        deploy_css
        deploy_js
        ;;
    libs)
        deploy_perl_libs
        deploy_dyn_libs
        ;;
    servers)
        deploy_templates
        deploy_perl
        deploy_srv
        ;;
    html)
        deploy_html
        ;;
    css)
        deploy_css
        ;;
    js)
        deploy_js
        ;;
    perllibs)
        deploy_perl_libs
        ;;
    dynlibs)
        deploy_dyn_libs
        ;;
    perl)
        deploy_perl
        ;;
    templates)
        deploy_templates
        ;;
    srv)
        deploy_srv
        ;;
    latex)
        deploy_latex
        ;;
    testcases)
        deploy_testcases
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
    echo "$SCP $FTPLOG -f $LOGINCFG $USETMPFILE -X \"chmod 0755 $DEPLOYDIR/$srv\" $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv"
    # ncftpput [options] remote-host remote-directory local-files.
    # ncftpput -f login.cfg [options] remote-directory local-files...
    $SCP $FTPLOG -f $LOGINCFG $USETMPFILE -X "chmod 0755 $DEPLOYDIR/$srv" $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv
done

# copy cfg and other files - chmod 0644 rw-r--r--
for srv in berg.cfg berg.opt xsc; do
    echo "$SCP $FTPLOG -f $LOGINCFG $USETMPFILE $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv"
    $SCP $FTPLOG -f $LOGINCFG $USETMPFILE $DEPLOYDIR $SOURCEDIR/tmp/$BERG_DIR/cgi-bin/brg/$srv
done

echo "done."

exit 0;
