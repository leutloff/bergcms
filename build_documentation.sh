#!/bin/bash -e

echo "***   Update .cls file   ***"

pushd latex/class_berg
./update_cls_pdf.sh
popd
mkdir -p www/htdocs/brg/doc
cp latex/class_berg/generated/berg.cls www/cgi-bin/brg/br/
cp latex/class_berg/generated/berg.pdf www/htdocs/brg/doc/

echo "***   Generate User Documentation   ***"

pushd doc/redakteur
pdflatex redakteurin.tex
pdflatex redakteurin.tex
popd
cp doc/redakteur/redakteurin.pdf www/htdocs/brg/doc/

echo "done."
