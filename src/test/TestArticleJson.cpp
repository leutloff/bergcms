/**
 * @file TestArticleJson.cpp
 * Testing JSON related aspects of the Article class.
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

#include <Article.h>

// include Boost.Test
#include <boost/test/unit_test.hpp>

using namespace std;
using namespace berg;

BOOST_AUTO_TEST_SUITE(article_json)

BOOST_AUTO_TEST_CASE(empty_article)
{
    {
        Article article;
        const string completeEmptyArticle = "{\n    \"id\": 4294967295,\n    \"priority\": -1,\n    \"type\": \"\",\n"
                                    "    \"chapter\": \"\",\n    \"title\": \"\",\n"
                                    "    \"header\": \"\",\n    \"body\": \"\",\n    \"footer\": \"\",\n"
                                    "    \"lastChanged\": \"\"\n}\n";
        string json;
        article.GetAsJSON(json);
        BOOST_CHECK_EQUAL(completeEmptyArticle, json);

        const string minimalAcceptableArticle = "{\n    \"id\": 25\n}\n";
        article.SetFromJSON(minimalAcceptableArticle);
        article.GetAsJSON(json);
        const string nearlyDefaultArticle = "{\n    \"id\": 25,\n    \"priority\": 100,\n    \"type\": \"A\",\n"
                                    "    \"chapter\": \"\",\n    \"title\": \"\",\n"
                                    "    \"header\": \"\",\n    \"body\": \"\",\n    \"footer\": \"\",\n"
                                    "    \"lastChanged\": \"\"\n}\n";
        BOOST_CHECK_EQUAL(nearlyDefaultArticle, json);
    }
}

BOOST_AUTO_TEST_CASE(single_article)
{
    {
        Article article;
        string jsonStored = "{\n    \"id\": 1,\n    \"priority\": 400,\n    \"type\": \"F\",\n"
                            "    \"chapter\": \"the chapter\",\n    \"title\": \"the title\",\n"
                            "    \"header\": \"the header\",\n    \"body\": \"the main body\",\n    \"footer\": \"the footer\",\n"
                            "    \"lastChanged\": \"last changed time stamp\"\n}\n";
        article.SetFromJSON(jsonStored);
        string jsonReturned;
        article.GetAsJSON(jsonReturned);
        BOOST_CHECK_EQUAL(jsonStored, jsonReturned);
    }
}



BOOST_AUTO_TEST_SUITE_END()
