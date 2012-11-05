#!/bin/bash
# Processing berg.dtx to generate the Class and the Documentation as PDF.

pushd generated

set -e
# remove old files for a fresh start
rm -f berg.cls berg.drv berg.aux berg.toc berg.glo berg.gls berg.idx berg.ilg berg.ind berg.log berg.pdf

# copy the files for processing from the directory above
cp -p ../berg.dtx ../berg.ins .

# generates berg.cls and berg.drv
latex berg.ins

# generates the berg.pdf
pdflatex berg.drv
makeindex berg.idx
makeindex -s gglo.ist -o berg.gls berg.glo
pdflatex berg.drv

# removed copied files, again
rm berg.dtx berg.ins

echo "\n ***   Processing the samples ...   ***\n"

#process samples
rm -f singlepage.*
pdflatex ../examples/singlepage.tex



popd
