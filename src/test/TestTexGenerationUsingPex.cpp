/**
 * @file TestTexGenerationUsingPex.cpp
 * Testing the generation of the TeX files using the Perl based PeX script.
 *
 * Copyright 2013, 2018 Christian Leutloff <leutloff@sundancer.oche.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#if defined(HAS_VISUAL_LEAK_DETECTOR)
#include <vld.h>
#endif

#include "TestShared.h"

#include <boost/filesystem.hpp>
#include <boost/iostreams/tee.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/process.hpp>

#include <boost/test/unit_test.hpp>

using namespace std;

namespace bio = boost::iostreams;
namespace fs = boost::filesystem;
namespace bp = boost::process;
namespace bt = berg::testonly;

const fs::path exePerl           = fs::path("/usr/bin/perl");

BOOST_AUTO_TEST_SUITE(pex)

/**
 * @brief VerifyGeneratedFileContent loads the two given files and compares them.
 * @param expectedFile this is the file used as a reference
 * @param actualFile this is the file to validate
 */
void VerifyGeneratedFileContent(boost::filesystem::path const& expectedFile, boost::filesystem::path const& actualFile)
{
    std::vector<std::string> expected;
    BOOST_CHECK_EQUAL(true, bt::LoadFile(expectedFile, expected));
    std::vector<std::string> actual;
    BOOST_CHECK_EQUAL(true, bt::LoadFile(actualFile, actual));
    bt::RemoveIgnoreLine(expected, actual);

    BOOST_CHECK_EQUAL(expected.size(), actual.size());
    BOOST_CHECK_EQUAL_COLLECTIONS(expected.begin(), expected.end(), actual.begin(), actual.end());
}

BOOST_AUTO_TEST_CASE(test_calling_perl_version)
{
    const fs::path perlVersionfile = fs::path(fs::path(bt::GetOutputDir()) / "perlversion.log");

    // perl -v
    bp::child c11(
                exePerl
                , "-v"
                , bp::std_out > perlVersionfile
                , bp::std_err > perlVersionfile
                );
    c11.wait();
    int ret = c11.exit_code(); // wait for perl completion
    //cout << "Perl return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
    bt::PrintFileToStream(perlVersionfile, cout);
}


BOOST_AUTO_TEST_CASE(test_calling_simple_perl_script)
{
    const fs::path simplePerlScript       = fs::path(fs::path(bt::GetInputDir()) / "simpleperlscript.pl");
    const fs::path simplePerlScriptOutput = fs::path(fs::path(bt::GetOutputDir()) / "simpleperlscript.log");

    //bt::PrintFileToStream(simplePerlScript.c_str(), cout);

    // perl input/simpleperlscript.pl
    bp::child c11(
                exePerl
                , simplePerlScript
                , bp::std_out > simplePerlScriptOutput
                , bp::std_err > simplePerlScriptOutput
                , bp::start_dir = bt::GetTestDir()
                );
    c11.wait();
    int ret = c11.exit_code(); // wait for perl completion
    //cout << "Perl return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
    //bt::PrintFileToStream(simplePerlScriptOutput, cout);
}

// this processes a database with a single article that should be ignored, because prio is -1.
BOOST_AUTO_TEST_CASE(test_calling_pex)
{
    // www/cgi-bin/brg/pex.pl
    const fs::path pexScript         = fs::path(bt::GetCgiBinDir()   / "pex.pl");
    const fs::path perlScriptOutput  = fs::path(bt::GetOutputDir()   / "callingpex.log");
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "single_article.csv");
    const fs::path texFile           = fs::path(bt::GetOutputDir()   / "callingpex.tex");
    const fs::path texFileExpected   = fs::path(bt::GetExpectedDir() / "callingpex.tex");

    // perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
    //cout << exePerl.c_str() << " " << pexScript.c_str() << " " << inputDatabaseFile.c_str() << " " << texFile.c_str() << endl;
    bp::child c11(
                exePerl
                , pexScript
                , inputDatabaseFile
                , texFile
                , bp::std_out > perlScriptOutput
                , bp::std_err > perlScriptOutput
                , bp::start_dir = bt::GetOutputDir()
                );
    c11.wait();
    int ret = c11.exit_code(); // wait for perl completion
    //cout << "test_calling_pex - Perl return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   Perl Log   ***" << endl;
//    bt::PrintFileToStream(perlScriptOutput, cout);
//    cout << "***   TeX File   ***" << endl;
//    bt::PrintFileToStream(texFile, cout);

    VerifyGeneratedFileContent(texFileExpected, texFile);
}

BOOST_AUTO_TEST_CASE(test_calling_pex_some_articles)
{
    // www/cgi-bin/brg/pex.pl
    const fs::path pexScript         = fs::path(bt::GetCgiBinDir()   / "pex.pl");
    const fs::path perlScriptOutput  = fs::path(bt::GetOutputDir()   / "callingpexsomearticles.log");
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "some_articles.csv");
    const fs::path texFile           = fs::path(bt::GetOutputDir()   / "callingpexsomearticles.tex");
    const fs::path texFileExpected   = fs::path(bt::GetExpectedDir() / "callingpexsomearticles.tex");

    // perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
    //cout << "pwd: " << fs::current_path() << endl;
    //cout << "bt::GetCgiBinDir(): " << bt::GetCgiBinDir() << endl;
    //cout << exePerl.c_str() << " " << pexScript.c_str() << " " << inputDatabaseFile.c_str() << " " << texFile.c_str() << endl;
    bp::child c11(
                exePerl
                , pexScript
                , inputDatabaseFile
                , texFile
                , "userelativepaths"
                , bp::std_out > perlScriptOutput
                , bp::std_err > perlScriptOutput
                , bp::start_dir = bt::GetCgiBinDir()
                );
    c11.wait();
    int ret = c11.exit_code(); // wait for perl completion
    //cout << "test_calling_pex_some_articles - Perl return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
    //cout << "***   Perl Log   ***" << endl;
    //bt::PrintFileToStream(perlScriptOutput, cout);
//    cout << "***   TeX File   ***" << endl;
//    bt::PrintFileToStream(texFile, cout);

    VerifyGeneratedFileContent(texFileExpected, texFile);
}

BOOST_AUTO_TEST_SUITE_END()
