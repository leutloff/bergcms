#!/bin/sh -e
#############################################################################
# Commands to generate the PDF for printing. 
#
# (c) 2007 Heiko Decker - FeG-Zeitung erzeugen (Script-SicherheitsKernel)
# (c) 2011, 2012 Christian Leutloff
#
# This program is free software; you can redistribute it and/or modify it 
# under the same terms as Perl itself, i.e., under the terms of the 
# ``Artistic License'' or the ``GNU General Public License''.
#
# This script is not executed by /bin/sh, but from xsc.pl. The perl scripts
# loads this file and executes it line by line.
#############################################################################
XSCVERSION="v1.06, 15.09.2012"
# Die folgenden Variablen werden durch xsc.pl ersetzt.
# Die hier verwendeten Werte dienen nur zum Testen des Skripts.
# Sie werden nicht von xsc.pl benutzt. 
BERGLOGDIR=log
BERGDBDIR=br
BERGOUTDIR=out
BERGDLBDIR=../../htdocs/dlb
#echo "BERGLOGDIR: $BERGLOGDIR"
# BERGDLBDIR=/home/aachen/htdocs/dlb
# Nun folgt die eigentliche Verarbeitung
mkdir -p $BERGLOGDIR; echo "xsc Script $XSCVERSION - " >$BERGLOGDIR/log.txt; echo "Start des Zeitungsgenerators pex (`date`) ..." >>$BERGLOGDIR/log.txt
# Die CSV-Datenbank nach feginfo.tex transformieren
perl pex.pl $BERGDBDIR/feginfo.csv $BERGOUTDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
mv $BERGLOGDIR/pe.log $BERGDLBDIR
# rm feginfo.aux - wird für das Inhaltsverzeichnis benötigt.
cp $BERGOUTDIR/feginfo.tex $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
#cp -r $BERGDBDIR/*.sty $BERGDBDIR/data $BERGDBDIR/*.jpg $BERGOUTDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
# LaTeX-Lauf der .pdf und auch .log erzeugt (pdflatex darf keine Ausgabe erzeugen!)
cd $BERGOUTDIR && TEXINPUTS=../br:../br/data:../br/bilder:../br/images:../br/icons:$TEXINPUTS pdflatex -interaction=nonstopmode -file-line-error feginfo.tex  >/dev/null
#cd $BERGDBDIR && if [ -f feginfo.idx ]; xindy feginfo.idx; fi 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
#echo "xindy calling .." >>$BERGLOGDIR/log.txt
#cd $BERGDBDIR && xindy -L german-din feginfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
echo "makeindex calling ..." >>$BERGLOGDIR/log.txt
cd $BERGOUTDIR && makeindex feginfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
cd $BERGOUTDIR && which ls 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
cd $BERGOUTDIR && which makeindex 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
mv $BERGOUTDIR/feginfo.log $BERGOUTDIR/feginfo.pdf $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
cp $BERGDBDIR/feginfo.csv $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
echo "Zeitungsgenerators beendet (`date`)." >>$BERGLOGDIR/log.txt
echo "Hier noch das Log von pex.pl:" >>$BERGLOGDIR/log.txt
cat $BERGLOGDIR/log.txt $BERGDLBDIR/pe.log >$BERGDLBDIR/log.txt
