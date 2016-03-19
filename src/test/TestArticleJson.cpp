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
        const string completeEmptyArticle = "{\r\n    \"id\": 4294967295,\r\n    \"priority\": -1,\r\n    \"type\": \"\",\r\n"
                                    "    \"chapter\": \"\",\r\n    \"title\": \"\",\r\n"
                                    "    \"header\": \"\",\r\n    \"body\": \"\",\r\n    \"footer\": \"\",\r\n"
                                    "    \"lastChanged\": \"\"\r\n}";
        string json;
        article.GetAsJSON(json);
        BOOST_CHECK_EQUAL(completeEmptyArticle, json);

        const string minimalAcceptableArticle = "{\r\n    \"id\": 25\r\n}\r\n";
        article.SetFromJSON(minimalAcceptableArticle);
        article.GetAsJSON(json);
        const string nearlyDefaultArticle = "{\r\n    \"id\": 25,\r\n    \"priority\": 100,\r\n    \"type\": \"A\",\r\n"
                                    "    \"chapter\": \"\",\r\n    \"title\": \"\",\r\n"
                                    "    \"header\": \"\",\r\n    \"body\": \"\",\r\n    \"footer\": \"\",\r\n"
                                    "    \"lastChanged\": \"\"\r\n}";
        BOOST_CHECK_EQUAL(nearlyDefaultArticle, json);
    }
}

BOOST_AUTO_TEST_CASE(single_article)
{
    {
        Article article;
        string jsonStored = "{\r\n    \"id\": 1,\r\n    \"priority\": 400,\r\n    \"type\": \"F\",\r\n"
                            "    \"chapter\": \"the chapter\",\r\n    \"title\": \"the title\",\r\n"
                            "    \"header\": \"the header\",\r\n    \"body\": \"the main body\",\r\n    \"footer\": \"the footer\",\r\n"
                            "    \"lastChanged\": \"last changed time stamp\"\r\n}";
        article.SetFromJSON(jsonStored);
        string jsonReturned;
        article.GetAsJSON(jsonReturned);
        BOOST_CHECK_EQUAL(jsonStored, jsonReturned);
    }
}



BOOST_AUTO_TEST_SUITE_END()
