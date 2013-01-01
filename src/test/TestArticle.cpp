/**
 * @file TestArticle.cpp
 * Testing aspects of the Article class.
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

#include <Article.h>

#include <boost/filesystem.hpp>
// include Boost.Test
#include <boost/test/unit_test.hpp>

using namespace std;
using namespace berg;


BOOST_AUTO_TEST_CASE(test_count_lines)
{
    const string line1 = "123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789";
    {
        string article;
        BOOST_CHECK_EQUAL(1, Article::CountDisplayedLines(article));
    }
    {
        string article = "a";
        BOOST_CHECK_EQUAL(1, Article::CountDisplayedLines(article));
    }
    {
        string article = "a\n";
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = "\n";
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = "\na";
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = "a\nb";
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = "a\nb\n";
        BOOST_CHECK_EQUAL(3, Article::CountDisplayedLines(article));
    }
    {
        string article = "\n\n";
        BOOST_CHECK_EQUAL(3, Article::CountDisplayedLines(article));
    }
    {
        string article = "\na\nb\n";
        BOOST_CHECK_EQUAL(4, Article::CountDisplayedLines(article));
    }
    {
        string article = "\n\n\n";
        BOOST_CHECK_EQUAL(4, Article::CountDisplayedLines(article));
    }
    {
        string article = "a\nb\nc";
        BOOST_CHECK_EQUAL(3, Article::CountDisplayedLines(article));
    }
    {
        string article = "a\nb\nc\n";
        BOOST_CHECK_EQUAL(4, Article::CountDisplayedLines(article));
    }

    {
        string article = line1;
        BOOST_CHECK_EQUAL(1, Article::CountDisplayedLines(article));
    }
    {
        string article = line1 + "\n";
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = line1 + "\n" + line1;
        BOOST_CHECK_EQUAL(2, Article::CountDisplayedLines(article));
    }
    {
        string article = line1 + "\n" + line1 + "\n";
        BOOST_CHECK_EQUAL(3, Article::CountDisplayedLines(article));
    }

    {
        string article;
        for (size_t i = 0; 100 > i; ++i)
        {
            article += "a\n";
        }
        BOOST_CHECK_EQUAL(101, Article::CountDisplayedLines(article));
        BOOST_CHECK_EQUAL(102, Article::CountDisplayedLines("\n" + article));
        BOOST_CHECK_EQUAL(102, Article::CountDisplayedLines(article + "\n"));
        BOOST_CHECK_EQUAL(103, Article::CountDisplayedLines("\n\n" + article));
        BOOST_CHECK_EQUAL(103, Article::CountDisplayedLines("\n" + article + "\n"));
    }
    {
        string article;
        for (size_t i = 0; 100 > i; ++i)
        {
            article += line1 + "\n";
        }
        BOOST_CHECK_EQUAL(101, Article::CountDisplayedLines(article));
        BOOST_CHECK_EQUAL(102, Article::CountDisplayedLines("\n" + article));
        BOOST_CHECK_EQUAL(102, Article::CountDisplayedLines(article + "\n"));
        BOOST_CHECK_EQUAL(103, Article::CountDisplayedLines("\n\n" + article));
        BOOST_CHECK_EQUAL(103, Article::CountDisplayedLines("\n" + article + "\n"));
    }
    {
        string article;
        for (size_t i = 0; 100 > i; ++i)
        {
            article += line1 + "\n" + "a\n";;
        }
        BOOST_CHECK_EQUAL(201, Article::CountDisplayedLines(article));
        BOOST_CHECK_EQUAL(202, Article::CountDisplayedLines("\n" + article));
        BOOST_CHECK_EQUAL(202, Article::CountDisplayedLines(article + "\n"));
        BOOST_CHECK_EQUAL(203, Article::CountDisplayedLines("\n\n" + article));
        BOOST_CHECK_EQUAL(203, Article::CountDisplayedLines("\n" + article + "\n"));
    }
}

