#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME=$(hostname)
BUILDDIR=$SOURCEDIR/build-mk-$HOSTNAME


# Folder where the files are copied to.
# Do not use for production because it overrides and deletes files without
# any warning. This is useful to get a consistent behaviour for testing.
#TARGETDIR=/home/bergcms
TARGETDIR=/var/www

# Used to invoke the webbrowser with the given URL, e.g.
# firefox "http://bergcms.local/cgi-bin/brg/maker"
MYBROWSER=firefox
LOCALWWWHOST=http://bergcms.local
LOCALCGIDIR=/cgi-bin/brg

# Override any variables above by placing them into a file named install_locally.cfg.
# This is especially useful for the TARGETDIR and the LOCAL*.
if [ -r $SOURCEDIR/install_locally.cfg ]; then
    . $SOURCEDIR/install_locally.cfg
fi

echo "Build (from $SOURCEDIR on $HOSTNAME) and install the project (in $TARGETDIR)..."

# /home/bergcms$ ~/work/bergcms/make_zip.sh &&  unzip -o ~/work/bergcms/build-mk/Berg-3.0.0-Linux.zip && (cd htdocs/cgi-bin/brg ; ./archive)
(cd $SOURCEDIR && ./make_zip.sh)

pushd $TARGETDIR
# unpacks the latest archive
BERG_ARCHIVE=$(ls -t $BUILDDIR/Berg*-$HOSTNAME.zip | head -n 1)
BERG_VERSION=$(echo $BERG_ARCHIVE | cut -d- -f2 -)
BERG_DIR=$(basename $BERG_ARCHIVE .zip)
unzip -o $BERG_ARCHIVE

# add symlinks
ln -sf $BERG_DIR berg
ln -sf $BERG_DIR/cgi-bin .
ln -sf $BERG_DIR/htdocs .
(cd htdocs; ln -sf ../cgi-bin .)
# add symblink to favicon when not existing
(cd htdocs; if [ ! -e favicon.ico ] ; then ln -s brg/favicon.ico . ; fi)

#fix permissions to avoid:  directory is writable by others: (/home/bergcms/Berg-3.0.0-Linux/cgi-bin/brg)
# mentioned in /var/log/apache2/suexec.log
chmod go-w Berg-*/cgi-bin/brg

# extract the archive files from the saved files
mkdir -p cgi-bin/brg/archive_content
#(cd cgi-bin/brg/archive_content && $SOURCEDIR/extract_archive_files.sh)

# make some directories required for temporary files and processing results
mkdir -p cgi-bin/brg/tidx
mkdir -p cgi-bin/brg/gi_backup
mkdir -p cgi-bin/brg/log
mkdir -p cgi-bin/brg/out
# Allow writing to upload and images directories
mkdir -p cgi-bin/brg/br/bilder
mkdir -p cgi-bin/brg/ul
chmod ugo+rwx cgi-bin/brg/br/bilder cgi-bin/brg/ul

# Download area
mkdir -p htdocs/dlb
#TODO: switch to a single dir (htdocs/brg): mkdir -p htdocs/brg/dlb

# prepare for apache
mkdir -p logs
mkdir -p awstats

# switch to main cgi dir
cd htdocs/cgi-bin/brg

# executes the archive
#echo -e "\n * Executing archive...\n"
#./archive archive=gi232

echo -e "\n * Executing maker...\n"
# requires additionally pdflatex and makedindex, e.g. install by
# apt-get install texlive-latex-base texlive-lang-german texlive-latex-extra
./maker

popd

# launch firefox when the DISPLAY variable is set.
if [ "X$DISPLAY" != "X" ]; then
    echo "Launch $MYBROWSER with some pages for further testing within the browser."

    # open new tab with the archive
    #firefox "http://bergcms.burg.local/cgi-bin/brg/archive"
    #$MYBROWSER "$LOCALWWWHOST$LOCALCGIDIR/archive"

    # open new tab with the start page of berg
    #firefox "http://bergcms.burg.local/cgi-bin/brg/berg"
    $MYBROWSER "$LOCALWWWHOST$LOCALCGIDIR/berg.pl"

    # call generator
    #firefox "http://bergcms.burg.local/cgi-bin/brg/maker"
    $MYBROWSER "$LOCALWWWHOST$LOCALCGIDIR/maker"
fi

echo "done."

exit 0;
