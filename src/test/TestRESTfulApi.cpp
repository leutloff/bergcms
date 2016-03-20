/**
 * @file TestRESTfulApi.cpp
 * Testing the RESTful API provided by bgrest.
 *
 * Copyright 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#include <boost/process/process.hpp>
//#include <boost/process/initializers/environment.hpp>

#include <boost/test/unit_test.hpp>

using namespace std;

namespace bio = boost::iostreams;
namespace fs = boost::filesystem;
namespace bp = boost::process;
namespace bt = berg::testonly;

BOOST_AUTO_TEST_SUITE(bgrest)

static const fs::path exeBgRest = fs::path(bt::GetSrvBuildDir() / "bgrest" / "bgrest");

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


/**
 * This unit test processes a database with one single article with prio set to -1.
 * Set run environment:
 * QUERY_STRING /articles/1
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/single_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_single)
{
    // ../srv/bgrest/bgrest
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "single_article.csv");
    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "single_article.json");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "single_article.json");

    //cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
#if defined(WIN32)
    bio::file_descriptor_sink bgrestOut(jsonFile);
#else
    bio::file_descriptor_sink bgrestOut(jsonFile.c_str());
#endif
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles/1")
                , bp::std_out_to(bgrestOut)
                , bp::std_err_to(bgrestOut)
                );
    int ret = c11.join(); // wait for completion
    //cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   jsonFileExpected   ***" << endl;
//    bt::PrintFileToStream(jsonFileExpected, cout);
//    cout << endl;
//    cout << "***   jsonFile   ***" << endl;
//    bt::PrintFileToStream(jsonFile, cout);

    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
}

/**
 * This unit test processes a database with some articles.
 * Set run environment:
 * QUERY_STRING /articles/1
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/two_articles.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_two_id1)
{
    // ../srv/bgrest/bgrest
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "two_articles.csv");
    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "two_articles_id1.json");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "two_articles_id1.json");

    //cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
#if defined(WIN32)
    bio::file_descriptor_sink bgrestOut(jsonFile);
#else
    bio::file_descriptor_sink bgrestOut(jsonFile.c_str());
#endif
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles/1")
                , bp::std_out_to(bgrestOut)
                , bp::std_err_to(bgrestOut)
                );
    int ret = c11.join(); // wait for completion
    //cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   jsonFileExpected   ***" << endl;
//    bt::PrintFileToStream(jsonFileExpected, cout);
//    cout << endl;
//    cout << "***   jsonFile (generated file)   ***" << endl;
//    bt::PrintFileToStream(jsonFile, cout);

// a fix seems to be provided in https://stackoverflow.com/questions/10260688/boostproperty-treejson-parser-and-two-byte-wide-characters
//#if (BOOST_VERSION < 105800)
//    // see https://svn.boost.org/trac/boost/ticket/5033
//#   warning "There are UTF-16 characters in the generated output. Fixme."
//#else
    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
//#endif
}

/**
 * This unit test processes a database with some articles.
 * Set run environment:
 * QUERY_STRING /articles/42
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/two_articles.csv
 * To test that the expected JSON is valid, too:
 * cat expected/two_articles_id42.json | tail -n +3  | jsonlint-php
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_two_id42)
{
    // ../srv/bgrest/bgrest
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "two_articles.csv");
    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "two_articles_id42.json");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "two_articles_id42.json");

    // cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
#if defined(WIN32)
    bio::file_descriptor_sink bgrestOut(jsonFile);
#else
    bio::file_descriptor_sink bgrestOut(jsonFile.c_str());
#endif
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles/42")
                , bp::std_out_to(bgrestOut)
                , bp::std_err_to(bgrestOut)
                );
    int ret = c11.join(); // wait for completion
    //cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   jsonFileExpected   ***" << endl;
//    bt::PrintFileToStream(jsonFileExpected, cout);
//    cout << endl;
    cout << "***   jsonFile (generated file)   ***" << endl;
    bt::PrintFileToStream(jsonFile, cout);

//#if (BOOST_VERSION < 105800)
//    // see https://svn.boost.org/trac/boost/ticket/5033
//#   warning "There are UTF-16 characters in the generated output. Fixme."
//#else
    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
//#endif
}

/**
 * This unit test processes a database with some articles.
 * Set run environment:
 * QUERY_STRING /articles
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/two_articles.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_two)
{
    // ../srv/bgrest/bgrest
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "two_articles.csv");
    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "two_articles.json");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "two_articles.json");

    cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
#if defined(WIN32)
    bio::file_descriptor_sink bgrestOut(jsonFile);
#else
    bio::file_descriptor_sink bgrestOut(jsonFile.c_str());
#endif
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles")
                , bp::std_out_to(bgrestOut)
                , bp::std_err_to(bgrestOut)
                );
    int ret = c11.join(); // wait for completion
    //cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
    BOOST_CHECK_EQUAL(0, ret);
    cout << "***   jsonFileExpected   ***" << endl;
    bt::PrintFileToStream(jsonFileExpected, cout);
    cout << endl;
    cout << "***   jsonFile (generated file)   ***" << endl;
    bt::PrintFileToStream(jsonFile, cout);

    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
}

///**
// * This unit test processes a database with some articles.
// * Set run environment:
// * QUERY_STRING /articles
// * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/some_articles.csv
// */
//BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_some)
//{
//    // ../srv/bgrest/bgrest
//    const fs::path exeBgRest         = fs::path(bt::GetSrvBuildDir() / "bgrest" / "bgrest");
//    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "some_articles.csv");
//    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "some_articles.json");
//    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "some_articles.json");

//    cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
//#if defined(WIN32)
//    bio::file_descriptor_sink bgrestOut(jsonFile);
//#else
//    bio::file_descriptor_sink bgrestOut(jsonFile.c_str());
//#endif
//    bp::monitor c11 = bp::make_child(
//                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
//                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles")
//                , bp::std_out_to(bgrestOut)
//                , bp::std_err_to(bgrestOut)
//                );
//    int ret = c11.join(); // wait for completion
//    //cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
//    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   jsonFileExpected   ***" << endl;
//    bt::PrintFileToStream(jsonFileExpected, cout);
//    cout << endl;
//    cout << "***   jsonFile   ***" << endl;
//    bt::PrintFileToStream(jsonFile, cout);

//    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
//}

BOOST_AUTO_TEST_SUITE_END()
