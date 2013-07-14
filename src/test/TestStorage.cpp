/**
 * @file TestStorage.cpp
 * Testing the storage related classes.
 * 
 * Copyright 2012 Christian Leutloff <leutloff@sundancer.oche.de>
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

// vc is showing a memory leak when this file is included, see https://code.google.com/p/ctemplate/issues/detail?id=42 for the reasoning
//#include <ctemplate/template_string.h> 

#include "TestShared.h"

#include <FileStorage.h>
#include <Archive.h>

#if defined(_MSC_VER)
#pragma warning(push)
#pragma warning(disable: 4251) // 'ctemplate::Template::resolved_filename_' : class 'std::basic_string<_Elem,_Traits,_Ax>' needs to have dll-interface to be used by clients of class 'ctemplate::Template'          
#endif // defined(_MSC_VER)

// the following file is provided with the ctemplate tests
// if not found, adapt CTEMPLATETESTS_INCLUDEDIR in shared_config.make
#undef CTEMPLATE_DLL_DECL
#include <tests/template_test_util.h>

#if defined(_MSC_VER)
#pragma warning(disable: 6011)
#pragma warning(disable: 6326)
#endif // defined(_MSC_VER)
#define BOOST_TEST_DYN_LINK
// the following definition must be defined once per test project
#define BOOST_TEST_MAIN
// include Boost.Test
#include <boost/test/unit_test.hpp>
using boost::unit_test::test_suite;

#include <boost/filesystem.hpp>

#if defined(_MSC_VER)
#pragma warning(pop)
#endif

using namespace std;
using namespace berg;
namespace bt = berg::testonly;
namespace fs = boost::filesystem;
namespace tpl = ctemplate;

static const string sample = "some_articles.csv";
static const size_t ARCHIVE_FILES = 5;


// test suite berg.storage

BOOST_AUTO_TEST_CASE(test_initial_storage)
{
    BOOST_REQUIRE(true);
    try
    {
        FileStorage storage;
        storage.Load(bt::GetInputDir() + sample);
        Article const& article = storage.GetArticle(2);
        BOOST_CHECK_EQUAL("Dokumentenvorlage", article.getTitle());
    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}

//BOOST_AUTO_TEST_CASE(test_article)
//{
//    // create new Article with string
//
//    // convert storage specifc
//
//    // prepare for storage
//
//}

BOOST_AUTO_TEST_CASE(test_PrepareForFileStorage)
{
    const string start = "abcdefghijklmnopqstuvwxyzäöü@€§$°^~.,:;-_ABCEFGHIJKLMNOQRSTUVWXYZÄÖÜ";
    string unchanged = Article::PrepareForFileStorage(start);
    BOOST_CHECK_EQUAL(start, unchanged);
    unchanged = Article::UndoPrepareForFileStorage(start);
    BOOST_CHECK_EQUAL(start, unchanged);

    const string singleLF = "abcdefghijklmnopq\x0astuvwxyzäöü@€§$°^~.,:;-_ABCEFGHIJKLMNOQRSTUVWXYZÄÖÜ";
    string changed = Article::PrepareForFileStorage(singleLF);
    const string expectedChangedSingleLF =
        "abcdefghijklmnopq<br>stuvwxyzäöü@€§$°^~.,:;-_ABCEFGHIJKLMNOQRSTUVWXYZÄÖÜ";
    BOOST_CHECK_EQUAL(expectedChangedSingleLF, changed);
    changed = Article::UndoPrepareForFileStorage(changed);
    BOOST_CHECK_EQUAL(singleLF, changed);

    const string doubleLF = singleLF + singleLF;
    changed = Article::PrepareForFileStorage(doubleLF);
    BOOST_CHECK_EQUAL(expectedChangedSingleLF + expectedChangedSingleLF, changed);
    changed = Article::UndoPrepareForFileStorage(changed);
    BOOST_CHECK_EQUAL(doubleLF, changed);

    const string someLF = "\n\n" + doubleLF + doubleLF + "\n\n";
    changed = Article::PrepareForFileStorage(someLF);
    BOOST_CHECK_EQUAL(
        "<br><br>" + expectedChangedSingleLF + expectedChangedSingleLF + expectedChangedSingleLF + expectedChangedSingleLF + "<br><br>",
        changed);
    changed = Article::UndoPrepareForFileStorage(changed);
    BOOST_CHECK_EQUAL(someLF, changed);
}

BOOST_AUTO_TEST_CASE(test_multiple_loads)
{
    try
    {
        for (int i = 0; 10 > i; ++i)
        {
            FileStorage storage;
            storage.Load(bt::GetInputDir() + sample);
            Article const& article = storage.GetArticle(2);
            BOOST_CHECK_EQUAL("Dokumentenvorlage", article.getTitle());
        }
    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}


BOOST_AUTO_TEST_CASE(test_archive_load)
{
    try
    {
        Archive archive;
        int count = archive.Load(bt::GetArchiveDir());
        BOOST_CHECK_EQUAL(ARCHIVE_FILES, count);
        Archive::TArchiveFiles const& files = archive.GetDatabaseList();
        BOOST_CHECK_EQUAL(ARCHIVE_FILES, files.size());
        BOOST_CHECK_EQUAL("gi003", files[0]);
        BOOST_CHECK_EQUAL("gi1", files[1]);
        BOOST_CHECK_EQUAL("gi1001", files[2]);
        BOOST_CHECK_EQUAL("gi1002", files[3]);
        BOOST_CHECK_EQUAL("gi2", files[4]);
    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}


//class AddVector
//{
//    std::vector<std::string> archiveFiles;;
//
//public:
//    AddVector(size_t reserveSize = 50) : archiveFiles()
//    {
//        archiveFiles.reserve(reserveSize);
//    }
//    void Add()
//    {
//        archiveFiles.push_back("1"); archiveFiles.push_back("2"); archiveFiles.push_back("3");
//        BOOST_FOREACH(string str, archiveFiles)
//        {
//            cout  << " - " << str;
//        }
//        cout << endl;
//    }
//};
//
//
//BOOST_AUTO_TEST_CASE(test_vector)
//{
//    cout << "vector" << endl;
//
//    vector<string> v;
//    v.push_back("1"); v.push_back("2"); v.push_back("3");
//    BOOST_FOREACH( string str, v)
//    {
//        cout  << " - " << str;
//    }
//    cout << endl;
//
//    AddVector add;
//    add.Add();
//
//}

BOOST_AUTO_TEST_CASE(test_archive_fill_template_dictionary)
{
    try
    {
        tpl::TemplateDictionary dict("head");
        Archive::FillDictionaryHead(dict);
        ctemplate::TemplateDictionaryPeer peer(&dict);
        BOOST_CHECK_EQUAL("Archiv", peer.GetSectionValue("HEAD_TITLE"));

        Archive archive;
        int count = archive.Load(bt::GetArchiveDir());
        BOOST_CHECK_EQUAL(ARCHIVE_FILES, count);
        archive.FillDictionaryBody(dict);

        //BOOST_CHECK_EQUAL("2.0", peer.GetSectionValue("LIBVERSION"));

        vector<const ctemplate::TemplateDictionary*> archiveList;
        peer.GetSectionDictionaries("ARCHIVE_LIST", &archiveList);
        BOOST_CHECK_EQUAL(ARCHIVE_FILES, archiveList.size());
        {
            ctemplate::TemplateDictionaryPeer shape_peer(archiveList[0]);
            BOOST_CHECK_EQUAL("gi003", shape_peer.GetSectionValue("ARCHIVE_NAME"));
            BOOST_CHECK_EQUAL("?archive=gi003", shape_peer.GetSectionValue("ARCHIVE_REFERENCE"));
        }
        {
            ctemplate::TemplateDictionaryPeer shape_peer(archiveList[1]);
            BOOST_CHECK_EQUAL("gi1", shape_peer.GetSectionValue("ARCHIVE_NAME"));
            BOOST_CHECK_EQUAL("?archive=gi1", shape_peer.GetSectionValue("ARCHIVE_REFERENCE"));
        }
        {
            ctemplate::TemplateDictionaryPeer shape_peer(archiveList[2]);
            BOOST_CHECK_EQUAL("gi1001", shape_peer.GetSectionValue("ARCHIVE_NAME"));
            BOOST_CHECK_EQUAL("?archive=gi1001", shape_peer.GetSectionValue("ARCHIVE_REFERENCE"));
        }
        {
            ctemplate::TemplateDictionaryPeer shape_peer(archiveList[3]);
            BOOST_CHECK_EQUAL("gi1002", shape_peer.GetSectionValue("ARCHIVE_NAME"));
            BOOST_CHECK_EQUAL("?archive=gi1002", shape_peer.GetSectionValue("ARCHIVE_REFERENCE"));
        }
        {
            ctemplate::TemplateDictionaryPeer shape_peer(archiveList[4]);
            BOOST_CHECK_EQUAL("gi2", shape_peer.GetSectionValue("ARCHIVE_NAME"));
            BOOST_CHECK_EQUAL("?archive=gi2", shape_peer.GetSectionValue("ARCHIVE_REFERENCE"));
        }
    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}


BOOST_AUTO_TEST_CASE(test_article_list_fill_template_dictionary)
{
    try
    {
        {
            tpl::TemplateDictionary dict("head");
            FileStorage storage;
            // archive with a single article
            storage.Load(bt::GetArchiveDir() + "gi003");
            storage.FillDictionaryBody(dict);

            vector<const ctemplate::TemplateDictionary*> articleList;
            ctemplate::TemplateDictionaryPeer peer(&dict);
            peer.GetSectionDictionaries("ARTICLE_LIST", &articleList);
            BOOST_CHECK_EQUAL(1, articleList.size());
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[0]);
                BOOST_CHECK_EQUAL("title gi3", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi003&article=1", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
        }

        // archive with more articles
        {
            tpl::TemplateDictionary dict("head");
            FileStorage storage;
            // archive with a single article
            storage.Load(bt::GetArchiveDir() + "gi1001");
            storage.FillDictionaryBody(dict);

            vector<const ctemplate::TemplateDictionary*> articleList;
            ctemplate::TemplateDictionaryPeer peer(&dict);
            peer.GetSectionDictionaries("ARTICLE_LIST", &articleList);
            BOOST_CHECK_EQUAL(5, articleList.size());
            int article = 0;
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[article++]);
                BOOST_CHECK_EQUAL("title gi1001 Article 1", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi1001&article=1", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[article++]);
                BOOST_CHECK_EQUAL("title gi1001 Article 2", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi1001&article=5", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[article++]);
                BOOST_CHECK_EQUAL("title gi1001 Article 3", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi1001&article=25", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[article++]);
                BOOST_CHECK_EQUAL("title gi1001 Article 4", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi1001&article=26", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
            {
                ctemplate::TemplateDictionaryPeer shape_peer(articleList[article++]);
                BOOST_CHECK_EQUAL("title gi1001 Article 5", shape_peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("?archive=gi1001&article=27", shape_peer.GetSectionValue("ARTICLE_REFERENCE"));
            }
        }

    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}

BOOST_AUTO_TEST_CASE(test_single_article_fill_template_dictionary)
{
    try
    {
        {
            tpl::TemplateDictionary dict("head");
            FileStorage storage;
            // archive with a single article
            storage.Load(bt::GetArchiveDir() + "gi003");
            Article const& article = storage.GetArticle("1");
            article.FillDictionaryBody(dict);

            ctemplate::TemplateDictionaryPeer peer(&dict);
            BOOST_CHECK_EQUAL("1", peer.GetSectionValue("ARTICLE_ID"));
            BOOST_CHECK_EQUAL("chapter 3", peer.GetSectionValue("ARTICLE_CHAPTER"));
            BOOST_CHECK_EQUAL("3", peer.GetSectionValue("ARTICLE_PRIORITY"));
            BOOST_CHECK_EQUAL("title gi3", peer.GetSectionValue("ARTICLE_TITLE"));
            BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
            BOOST_CHECK_EQUAL(" head3", peer.GetSectionValue("ARTICLE_HEADER"));
            BOOST_CHECK_EQUAL(" body3", peer.GetSectionValue("ARTICLE_BODY"));
            BOOST_CHECK_EQUAL(" footer3", peer.GetSectionValue("ARTICLE_FOOTER"));
            BOOST_CHECK_EQUAL("20120102-212548-Do / 127.0.0.1:63880", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
        }

        {
            tpl::TemplateDictionary dict("head");
            FileStorage storage;
            // archive with a single article
            storage.Load(bt::GetArchiveDir() + "gi1001");
            {
                Article const& article = storage.GetArticle("1");
                article.FillDictionaryBody(dict);
                ctemplate::TemplateDictionaryPeer peer(&dict);
                BOOST_CHECK_EQUAL("1", peer.GetSectionValue("ARTICLE_ID"));
                BOOST_CHECK_EQUAL("chapter 1001 -1", peer.GetSectionValue("ARTICLE_CHAPTER"));
                BOOST_CHECK_EQUAL("1001", peer.GetSectionValue("ARTICLE_PRIORITY"));
                BOOST_CHECK_EQUAL("title gi1001 Article 1", peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
                BOOST_CHECK_EQUAL(" head1001 1", peer.GetSectionValue("ARTICLE_HEADER"));
                BOOST_CHECK_EQUAL(" body1001 1", peer.GetSectionValue("ARTICLE_BODY"));
                BOOST_CHECK_EQUAL(" footer1001 1", peer.GetSectionValue("ARTICLE_FOOTER"));
                BOOST_CHECK_EQUAL("20120102-212548-Do / 127.0.0.1:61001880", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
            }
            //        5	chapter 1001 -2	1002	title gi1001 Article 2	K	 head1001 2	 body1001 2	 footer1001 2	20120103-212548-Fr / 127.0.0.1:61001881
            {
                Article const& article = storage.GetArticle("5");
                article.FillDictionaryBody(dict);
                ctemplate::TemplateDictionaryPeer peer(&dict);
                BOOST_CHECK_EQUAL("5", peer.GetSectionValue("ARTICLE_ID"));
                BOOST_CHECK_EQUAL("chapter 1001 -2", peer.GetSectionValue("ARTICLE_CHAPTER"));
                BOOST_CHECK_EQUAL("1002", peer.GetSectionValue("ARTICLE_PRIORITY"));
                BOOST_CHECK_EQUAL("title gi1001 Article 2", peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
                BOOST_CHECK_EQUAL(" head1001 2", peer.GetSectionValue("ARTICLE_HEADER"));
                BOOST_CHECK_EQUAL(" body1001 2", peer.GetSectionValue("ARTICLE_BODY"));
                BOOST_CHECK_EQUAL(" footer1001 2", peer.GetSectionValue("ARTICLE_FOOTER"));
                BOOST_CHECK_EQUAL("20120103-212548-Fr / 127.0.0.1:61001881", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
            }
            //        25	chapter 1001 -3	1003	title gi1001 Article 3	K	 head1001 3	 body1001 3	 footer1001 3	20120104-212548-Sa / 127.0.0.1:61001882
            {
                Article const& article = storage.GetArticle("25");
                article.FillDictionaryBody(dict);
                ctemplate::TemplateDictionaryPeer peer(&dict);
                BOOST_CHECK_EQUAL("25", peer.GetSectionValue("ARTICLE_ID"));
                BOOST_CHECK_EQUAL("chapter 1001 -3", peer.GetSectionValue("ARTICLE_CHAPTER"));
                BOOST_CHECK_EQUAL("1003", peer.GetSectionValue("ARTICLE_PRIORITY"));
                BOOST_CHECK_EQUAL("title gi1001 Article 3", peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
                BOOST_CHECK_EQUAL(" head1001 3", peer.GetSectionValue("ARTICLE_HEADER"));
                BOOST_CHECK_EQUAL(" body1001 3", peer.GetSectionValue("ARTICLE_BODY"));
                BOOST_CHECK_EQUAL(" footer1001 3", peer.GetSectionValue("ARTICLE_FOOTER"));
                BOOST_CHECK_EQUAL("20120104-212548-Sa / 127.0.0.1:61001882", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
            }
            //        26	chapter 1001 -4	1004	title gi1001 Article 4	K	 head1001 4	 body1001 4	 footer1001 4	20120104-212548-Su / 127.0.0.1:61001883
            {
                Article const& article = storage.GetArticle("26");
                article.FillDictionaryBody(dict);
                ctemplate::TemplateDictionaryPeer peer(&dict);
                BOOST_CHECK_EQUAL("26", peer.GetSectionValue("ARTICLE_ID"));
                BOOST_CHECK_EQUAL("chapter 1001 -4", peer.GetSectionValue("ARTICLE_CHAPTER"));
                BOOST_CHECK_EQUAL("1004", peer.GetSectionValue("ARTICLE_PRIORITY"));
                BOOST_CHECK_EQUAL("title gi1001 Article 4", peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
                BOOST_CHECK_EQUAL(" head1001 4", peer.GetSectionValue("ARTICLE_HEADER"));
                BOOST_CHECK_EQUAL(" body1001 4", peer.GetSectionValue("ARTICLE_BODY"));
                BOOST_CHECK_EQUAL(" footer1001 4", peer.GetSectionValue("ARTICLE_FOOTER"));
                BOOST_CHECK_EQUAL("20120104-212548-Su / 127.0.0.1:61001883", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
            }
            //        27	chapter 1001 -5	1005	title gi1001 Article 5	K	 head1001 5	 body1001 5	 footer1001 5	20120104-212548-Mo / 127.0.0.1:61001884
            {
                Article const& article = storage.GetArticle("27");
                article.FillDictionaryBody(dict);
                ctemplate::TemplateDictionaryPeer peer(&dict);
                BOOST_CHECK_EQUAL("27", peer.GetSectionValue("ARTICLE_ID"));
                BOOST_CHECK_EQUAL("chapter 1001 -5", peer.GetSectionValue("ARTICLE_CHAPTER"));
                BOOST_CHECK_EQUAL("1005", peer.GetSectionValue("ARTICLE_PRIORITY"));
                BOOST_CHECK_EQUAL("title gi1001 Article 5", peer.GetSectionValue("ARTICLE_TITLE"));
                BOOST_CHECK_EQUAL("K", peer.GetSectionValue("ARTICLE_TYPE"));
                BOOST_CHECK_EQUAL(" head1001 5", peer.GetSectionValue("ARTICLE_HEADER"));
                BOOST_CHECK_EQUAL(" body1001 5", peer.GetSectionValue("ARTICLE_BODY"));
                BOOST_CHECK_EQUAL(" footer1001 5", peer.GetSectionValue("ARTICLE_FOOTER"));
                BOOST_CHECK_EQUAL("20120104-212548-Mo / 127.0.0.1:61001884", peer.GetSectionValue("ARTICLE_LASTCHANGED"));
            }
        }
    }
    catch (exception const& e)
    {
        ostringstream oss;
        oss << "Exception caught: " << e.what() << endl << "Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
    catch (string const& msg)
    {
        ostringstream oss;
        oss << "Exception caught: " << msg << endl << "Program terminated." << endl;
        oss << "current_path()" << fs::current_path();
        BOOST_FAIL(oss.str());
    }
    catch (...)
    {
        ostringstream oss;
        oss << "Exception caught. Program terminated." << endl;
        BOOST_FAIL(oss.str());
    }
}



// "link" to implementation of the test utils, e.g. TemplateDictionaryPeer::GetSectionValue
#include <tests/template_test_util.cc>
