/**
 * @file TestDirectoryLayout.cpp
 * Testing the DirectoryLayout class.
 *
 * Copyright 2014 Christian Leutloff <leutloff@sundancer.oche.de>
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

#include "DirectoryLayout.h"
// include Boost.Test
#include <boost/test/unit_test.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <fstream>

using namespace std;
using namespace berg;
namespace fs = boost::filesystem;

BOOST_AUTO_TEST_SUITE(DirectoryLayout)

// This test is executed only when the dir /home/aachen/cgi-bin/brg exists.
BOOST_AUTO_TEST_CASE(test_default_directory_layout)
{
    if (fs::exists("/home/aachen/cgi-bin/brg"))
    {
        cout << "Running directory layout tests for /home/aachen/cgi-bin/brg ..." << endl;
        BOOST_CHECK_EQUAL("/home/aachen/cgi-bin/brg", berg::DirectoryLayout::Instance().GetCgiBinDir());
    }
    else { cout << "NOT running directory layout tests for /home/aachen/cgi-bin/brg ..." << endl;}
    if (fs::exists("/home/aachen/htdocs/brg"))
    {
        BOOST_CHECK_EQUAL("/home/aachen/htdocs/brg", berg::DirectoryLayout::Instance().GetHtdocsDir());
    }
    if (fs::exists("/home/aachen/htdocs/dlb"))
    {
        fs::path dir;
        berg::DirectoryLayout::Instance().GetHtdocsDownloadDir(dir);
        BOOST_CHECK(boost::algorithm::ends_with(dir.string(), "/htdocs/dlb"));
    }
}

// This test is executed only when the dir /home/travis/build/leutloff/berg/www-root/cgi-bin/brg exists (this is expected on CI).
BOOST_AUTO_TEST_CASE(test_travis_directory_layout)
{
    if (fs::exists("/home/travis/build/leutloff/berg/www-root/cgi-bin/brg"))
    {
        cout << "Running directory layout tests for /home/travis/build/leutloff/berg/www-root/cgi-bin/brg ..." << endl;
        berg::DirectoryLayout::MutableInstance().SetProgramName("/home/travis/build/leutloff/berg/www-root/cgi-bin/brg/maker");
        BOOST_CHECK_EQUAL("/home/travis/build/leutloff/berg/www-root/cgi-bin/brg", berg::DirectoryLayout::Instance().GetCgiBinDir());
        BOOST_CHECK_EQUAL("/home/travis/build/leutloff/berg/www-root/htdocs/brg", berg::DirectoryLayout::Instance().GetHtdocsDir());
        fs::path dir;
        berg::DirectoryLayout::Instance().GetHtdocsDownloadDir(dir);
        BOOST_CHECK_EQUAL("/home/travis/build/leutloff/berg/www-root/htdocs/dlb", dir);
    }
    if (fs::exists("~/work/berg/www/cgi-bin/brg"))
    {
        cout << "Running directory layout tests for ~/work/berg/www/cgi-bin/brg ..." << endl;
        berg::DirectoryLayout::MutableInstance().SetProgramName("~/work/berg/www/cgi-bin/brg/maker");
        BOOST_CHECK_EQUAL("~/work/berg/www/cgi-bin/brg", berg::DirectoryLayout::Instance().GetCgiBinDir());
        BOOST_CHECK_EQUAL("~/work/berg/www/htdocs/brg", berg::DirectoryLayout::Instance().GetHtdocsDir());
        fs::path dir;
        berg::DirectoryLayout::Instance().GetHtdocsDownloadDir(dir);
        BOOST_CHECK_EQUAL("~/work/berg/www/htdocs/dlb", dir);
    }
}

// Testing the DirectoryLayout after setting up the standard directories in /tmp/berg-unittest.
BOOST_AUTO_TEST_CASE(test_a_tmp_directory_layout)
{
    // create directory layout in the system
    fs::create_directories("/tmp/berg-unittest/cgi-bin/brg");
    fs::create_directories("/tmp/berg-unittest/htdocs/brg");
    fs::create_directories("/tmp/berg-unittest/htdocs/dlb");
    {
        ofstream ofs("/tmp/berg-unittest/cgi-bin/brg/maker");
        ofs << "Used for DirectoryLayout tests, only." << endl;
        ofs.close();
    }

    berg::DirectoryLayout::MutableInstance().SetProgramName("/tmp/berg-unittest/cgi-bin/brg/maker");
    BOOST_CHECK_EQUAL("/tmp/berg-unittest/cgi-bin/brg", berg::DirectoryLayout::Instance().GetCgiBinDir());
    BOOST_CHECK_EQUAL("/tmp/berg-unittest/htdocs/brg", berg::DirectoryLayout::Instance().GetHtdocsDir());
    fs::path dir;
    berg::DirectoryLayout::Instance().GetHtdocsDownloadDir(dir);
    BOOST_CHECK_EQUAL("/tmp/berg-unittest/htdocs/dlb", dir);
    BOOST_CHECK_EQUAL("/tmp/berg-unittest/htdocs/dlb", berg::DirectoryLayout::Instance().GetHtdocsDownloadDir());
}

// Ensuring a graceful fallback for a not existing directory structure.
BOOST_AUTO_TEST_CASE(test_gracefully_fail_of_directory_layout)
{
    berg::DirectoryLayout::MutableInstance().SetProgramName("/not/existing/dir/exe");
    BOOST_CHECK_EQUAL("/home/aachen/cgi-bin/brg", berg::DirectoryLayout::Instance().GetCgiBinDir());
    BOOST_CHECK_EQUAL("/home/aachen/htdocs/brg", berg::DirectoryLayout::Instance().GetHtdocsDir());
    fs::path dir;
    berg::DirectoryLayout::Instance().GetHtdocsDownloadDir(dir);
    BOOST_CHECK_EQUAL("/home/aachen/htdocs/dlb", dir);
    BOOST_CHECK_EQUAL("/home/aachen/htdocs/dlb", berg::DirectoryLayout::Instance().GetHtdocsDownloadDir());
}


BOOST_AUTO_TEST_SUITE_END()
