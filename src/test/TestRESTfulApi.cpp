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
#include "RestArticle.h"
#include <boost/algorithm/algorithm.hpp>
#include <boost/filesystem.hpp>
#include <boost/iostreams/tee.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/process/process.hpp>
//#include <boost/process/initializers/environment.hpp>

#include <boost/test/unit_test.hpp>

using namespace std;
using namespace bergcms;

namespace bio = boost::iostreams;
namespace cgi = boost::cgi;
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
 * @brief VerifyGeneratedFileContent loads the two given files and compares them.
 * @param expectedFile this is the file used as a reference
 * @param actualString actual string returned.
 */
void VerifyGeneratedFileContent(boost::filesystem::path const& expectedFile, string const& actualString)
{
    std::vector<std::string> expected;
    BOOST_CHECK_EQUAL(true, bt::LoadFile(expectedFile, expected));
    // remove first three lines - the header lines
    expected.erase(expected.begin());
    expected.erase(expected.begin());
    expected.erase(expected.begin());

    std::vector<std::string> actual;
    boost::split(actual, actualString, boost::is_any_of("\n"));

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
    bio::file_descriptor_sink bgrestOut(jsonFile);
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
    bio::file_descriptor_sink bgrestOut(jsonFile);
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
    bio::file_descriptor_sink bgrestOut(jsonFile);
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
    bio::file_descriptor_sink bgrestOut(jsonFile);
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles")
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

    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
}

/**
 * This unit test processes a database with some articles.
 * Set run environment:
 * QUERY_STRING /articles
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/some_articles.csv
 * To test that the expected JSON is valid, too:
 * cat expected/some_articles.json | tail -n +3  | jsonlint-php
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_some)
{
    // ../srv/bgrest/bgrest
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "some_articles.csv");
    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "some_articles.json");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "some_articles.json");

    cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
    bio::file_descriptor_sink bgrestOut(jsonFile);
    bp::monitor c11 = bp::make_child(
                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "GET")("QUERY_STRING", "/articles")
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

///**
// * This unit test processes a database with some articles.
// * Set run environment:
// * REQUEST_METHOD POST
// * QUERY_STRING /articles
// * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/empty_db.csv
// * To test that the expected JSON is valid, too:
// * cat input/empty_article.json | tail -n +3  | jsonlint-php
// * cat expected/empty_db.json | tail -n +3  | jsonlint-php
// */
//BOOST_AUTO_TEST_CASE(test_bgrest_create_article_empty_db)
//{
//    // ../srv/bgrest/bgrest
//    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "empty_db.csv");
//    const fs::path jsonFileInput     = fs::path(bt::GetInputDir()    / "empty_article.json");
//    const fs::path jsonFile          = fs::path(bt::GetOutputDir()   / "empty_db.json");
//    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "empty_db.json");

//    cout << exeBgRest.c_str() << " " << inputDatabaseFile.c_str() << " " << jsonFile.c_str() << " " << jsonFileExpected.c_str() << endl;
//    if (fs::exists(inputDatabaseFile)) { fs::remove(inputDatabaseFile); }
//    bio::file_descriptor_sink bgrestOut(jsonFile);
//    bp::monitor c11 = bp::make_child(
//                bp::paths(exeBgRest.c_str(), bt::GetOutputDir())
//                , bp::environment("BERGCMSDB", inputDatabaseFile.c_str())("REQUEST_METHOD", "POST")("QUERY_STRING", "/articles")("CONTENT_LENGTH", "4")
//                , bp::std_in_from_path(jsonFileInput)
//                , bp::std_out_to(bgrestOut)
//                , bp::std_err_to(bgrestOut)
//                );
//    int ret = c11.join(); // wait for completion
//    cout << "bgrest return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
//    BOOST_CHECK_EQUAL(0, ret);
//    cout << "***   jsonFileExpected   ***" << endl;
//    bt::PrintFileToStream(jsonFileExpected, cout);
//    cout << endl;
//    cout << "***   jsonFile (generated file)   ***" << endl;
//    bt::PrintFileToStream(jsonFile, cout);

//    VerifyGeneratedFileContent(jsonFileExpected, jsonFile);
//}


/**
 * This unit test processes a database with one single article with prio set to -1.
 * This is the same as test_bgrest_get_articles_single, but this time it the library called directly.
 * Set run environment:
 * QUERY_STRING /articles/1
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/input/single_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_get_articles_single_lib)
{
    const fs::path inputDatabaseFile = fs::path(bt::GetInputDir()    / "single_article.csv");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "single_article.json");

    cgi::request req;
    req.set_query_string("/articles/1");
    req.set_method("GET");
    cgi::response resp;
    RestArticle restArticle(inputDatabaseFile.c_str());
    restArticle.dispatchArticles(req, resp);

    VerifyGeneratedFileContent(jsonFileExpected, resp.str());
}


/**
 * This unit test uses an empty database and creates the first empty article.
 * This test fills the CGI data structures and processes them.
 * POST
 * QUERY_STRING /articles
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/output/empty_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_post_articles_single_lib)
{
    const fs::path outputDatabaseFile = fs::path(bt::GetOutputDir()  / "empty_article.csv");
    const fs::path jsonFileExpected  = fs::path(bt::GetExpectedDir() / "post_empty_article1.json");

    if (fs::exists(outputDatabaseFile)) { fs::remove(outputDatabaseFile); }

    cgi::request req;
    req.set_query_string("/articles");
    req.set_method("POST");
    req.post["POSTDATA"] = "{ }";

    RestArticle restArticle(outputDatabaseFile.c_str());
    cgi::response resp;
    restArticle.dispatchArticles(req, resp);

    //cout << "Response (post_articles_single_lib):" << endl << resp.str() << endl;
    VerifyGeneratedFileContent(jsonFileExpected, resp.str());
}

/**
 * This unit test uses an empty database and creates two articles.
 * This test fills the CGI data structures and processes them.
 * POST
 * QUERY_STRING /articles
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/output/empty_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_post_two_articles)
{
    const fs::path outputDatabaseFile = fs::path(bt::GetOutputDir()  / "empty_article.csv");
    const fs::path jsonFileExpected1  = fs::path(bt::GetExpectedDir() / "post_article_with_title1.json");
    const fs::path jsonFileExpected2  = fs::path(bt::GetExpectedDir() / "post_article_with_title2.json");

    if (fs::exists(outputDatabaseFile)) { fs::remove(outputDatabaseFile); }

    cgi::request req;
    req.set_query_string("/articles");
    req.set_method("POST");
    req.post["POSTDATA"] = "{ \"priority\": \"500\", \"title\": \"Title of the article\", \"chapter\": \"Introduction\" }";

    RestArticle restArticle(outputDatabaseFile.c_str());
    {
        cgi::response resp;
        restArticle.dispatchArticles(req, resp);

        //cout << "Response (post_two_articles - 1):" << endl << resp.str() << endl;
        VerifyGeneratedFileContent(jsonFileExpected1, resp.str());
    }
    req.post["POSTDATA"] = "{ \"priority\": \"501\", \"title\": \"Title of the second article\", \"chapter\": \"Introduction\" }";
    {
        cgi::response resp;
        restArticle.dispatchArticles(req, resp);

        //cout << "Response (post_two_articles - 2):" << endl << resp.str() << endl;
        VerifyGeneratedFileContent(jsonFileExpected2, resp.str());
    }
}

/**
 * This unit test uses an empty database and creates an empty article.
 * This test fills the CGI data structures and processes them.
 * POST
 * QUERY_STRING /articles
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/output/empty_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_post_empty_article)
{
    const fs::path outputDatabaseFile = fs::path(bt::GetOutputDir()   / "empty_article.csv");
    const fs::path jsonFileExpected1  = fs::path(bt::GetExpectedDir() / "post_empty_article1.json");
    const fs::path jsonFileExpected2  = fs::path(bt::GetExpectedDir() / "post_empty_article2.json");

    if (fs::exists(outputDatabaseFile)) { fs::remove(outputDatabaseFile); }

    cgi::request req;
    req.set_query_string("/articles");
    req.set_method("POST");
    req.post["POSTDATA"] = "{}";

    RestArticle restArticle(outputDatabaseFile.c_str());
    {
        cgi::response resp;
        restArticle.dispatchArticles(req, resp);

        //cout << "Response:" << endl << resp.str() << endl;
        VerifyGeneratedFileContent(jsonFileExpected1, resp.str());
    }
    req.post["POSTDATA"] = "";
    {
        cgi::response resp;
        restArticle.dispatchArticles(req, resp);

        //cout << "Response:" << endl << resp.str() << endl;
        VerifyGeneratedFileContent(jsonFileExpected2, resp.str());
    }
}

/**
 * This unit test starts with no database and creates an empty article.
 * The returned article is changed and then saved.
 * A get method is used to retrieve the article and validate the stored content.
 * This test fills the CGI data structures and processes them.
 * PUT
 * QUERY_STRING /articles/{id}
 * BERGCMSDB    /home/leutloff/work/bergcms/src/test/output/empty_article.csv
 */
BOOST_AUTO_TEST_CASE(test_bgrest_put_article_changed_title)
{
    const fs::path outputDatabaseFile = fs::path(bt::GetOutputDir()   / "empty_article.csv");
    const fs::path jsonFileExpected1  = fs::path(bt::GetExpectedDir() / "post_empty_article1.json");
    const fs::path jsonFileInput1     = fs::path(bt::GetInputDir()    / "put_article_changed_title.json");
    const fs::path jsonFileExpected2  = fs::path(bt::GetExpectedDir() / "put_article_changed_title.json");

    if (fs::exists(outputDatabaseFile)) { fs::remove(outputDatabaseFile); }

    string id;
    RestArticle restArticle(outputDatabaseFile.c_str());
    {
        // create empty article
        cgi::request req;
        req.set_query_string("/articles");
        req.set_method("POST");
        req.post["POSTDATA"] = "{}";

        cgi::response resp;
        restArticle.dispatchArticles(req, resp);

        //cout << "Response:" << endl << resp.str() << endl;
        // get id from resp
        id = "1";
        VerifyGeneratedFileContent(jsonFileExpected1, resp.str());
    }
    string postdata;
    {
        // save changed article
        cgi::request req;
        req.set_query_string("/articles/" + id);
        req.set_method("PUT"); // TODO add support for that method...
        bt::LoadFile(jsonFileInput1, postdata);
        req.post["POSTDATA"] = postdata;

//        cgi::response resp;
//        restArticle.dispatchArticles(req, resp);

//        //cout << "Response:" << endl << resp.str() << endl;
//        VerifyGeneratedFileContent(jsonFileExpected2, resp.str());
//    }
//    {
//        // read changed article
//        cgi::request req;
//        req.set_query_string("/articles/" + id);
//        req.set_method("GET");

//        cgi::response resp;
//        restArticle.dispatchArticles(req, resp);

//        VerifyGeneratedFileContent(jsonFileExpected2, resp.str());
    }
}

BOOST_AUTO_TEST_SUITE_END()
