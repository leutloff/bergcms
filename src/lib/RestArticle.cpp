/*
 * @file RestArticle.cpp
 * This class implements the REST interface for the article specific functions.
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

#include "RestArticle.h"

#include <boost/property_tree/json_parser.hpp>

using namespace std;
using namespace berg;
using namespace bergcms;

namespace cgi = boost::cgi;
namespace http = boost::cgi::http;
namespace pt = boost::property_tree;

RestArticle::RestArticle(const string &database)
{
    storage.Load(database);
}

void RestArticle::getAll(cgi::request & req, cgi::response &resp)
{
    FileStorage::TArticles const& articles = storage.GetArticles();
    if (articles.size() > 0)
    {
        pt::ptree arrayArticles;
        for (FileStorage::TArticles::const_iterator it = articles.begin(); it < articles.end(); ++it)
        {
            arrayArticles.push_back(std::make_pair("", (*it)->Get()));
        }
        pt::ptree tree;
        tree.put_child("articles", arrayArticles);
        string jsonArticle;
        ostringstream oss;
        pt::write_json(oss, tree);
        jsonArticle = oss.str();
        resp << jsonArticle;
    }
    // else empty DB
    resp.status(http::ok);
}

void RestArticle::getSingle(cgi::request & req, cgi::response &resp)
{
    // single article
    constexpr string::size_type artLen = sizeof("/articles/")/sizeof(' ') - 1;
    string const& query = req.query_string();
    auto strid = query.substr(artLen);
    int id = boost::lexical_cast<int>(strid);
    Article const& article = storage.GetArticle(id);
    string jsonArticle;
    article.GetAsJSON(jsonArticle);
    resp << jsonArticle;
    resp.status(http::ok);
}

void RestArticle::post(cgi::request & req, cgi::response &resp)
{
    Article newArticle;
    // TODO fill with provided information - the ID is ignored - better overwritten in the NewArticle method.
    storage.NewArticle(newArticle);
    string jsonArticle;
    newArticle.GetAsJSON(jsonArticle);
    resp << jsonArticle;
    resp.status(http::created);
}


void RestArticle::dispatchArticles(cgi::request & req, cgi::response &resp)
{
    string const& query = req.query_string();
    if ("GET" == req.method())
    {
        if ("/articles" == query)
        {
            getAll(req, resp);
        }
        else
        {
            getSingle(req, resp);
        }
    }
    else if ("POST" == req.method())
    {
        if ("/articles" == query) // create new article
        {
            post(req, resp);
        }
    }
    else { throw "Method not supported: " + req.method(); }
}
