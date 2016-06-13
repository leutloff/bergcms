#!/bin/bash -e
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Running some tests for the perl scripts (starting in $SOURCEDIR)..."


pushd $SOURCEDIR

echo && echo && echo "***   run function tests ...   ***"
mkdir -p BERG
ln -fs $SOURCEDIR/../pex.pl BERG/PEX.pm
perl test_pex.pl
perl test_pex_columns.pl

echo && echo && echo "***   run tests on input database single_article.csv   ...   ***"
INPUTFILE=$SOURCEDIR/../../../../src/test/input/single_article.csv
OUTPUTFILE=$SOURCEDIR/output/single_article.tex
EXPECTEDFILE=$SOURCEDIR/expected/single_article.tex

$SOURCEDIR/../pex.pl $INPUTFILE $SOUTPUTFILE $OUTPUTFILE
echo && echo "Compare output with expected $EXPECTEDFILE ..."
cat $OUTPUTFILE | grep -v '^\% Program' | grep -v '^\% DB' | diff $EXPECTEDFILE -

echo && echo && echo "***   run tests on input database some_articles.csv   ...   ***"
INPUTFILE=$SOURCEDIR/../../../../src/test/input/some_articles.csv
OUTPUTFILE=$SOURCEDIR/output/some_articles.tex
EXPECTEDFILE=$SOURCEDIR/expected/some_articles.tex

$SOURCEDIR/../pex.pl $INPUTFILE $SOUTPUTFILE $OUTPUTFILE
echo && echo "Compare output with expected $EXPECTEDFILE ..."
cat $OUTPUTFILE | grep -v '^\% Program' | grep -v '^\% DB' | diff $EXPECTEDFILE -

popd

exit 0;
