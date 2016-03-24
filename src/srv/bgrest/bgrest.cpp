/**
 * @file maker.cpp
 * Provides the RESTful api to the article database.
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

#include "Common.h"
#include "DirectoryLayout.h"
#include "FileStorage.h"
#include <boost/algorithm/string/predicate.hpp>
#include <boost/cgi/cgi.hpp>
#include <boost/cgi/http/status_code.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/foreach.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <fstream>
#include <iostream>
#include <locale>
#include <sstream>
#include <cstdlib>

using namespace std;
using namespace berg;

namespace alg = boost::algorithm;
namespace bs = boost::system;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;
namespace http = boost::cgi::http;
namespace pt = boost::property_tree;

int HandleRequest(boost::cgi::request& req)
{
    int errors = 0;

    req.load(cgi::parse_all); // Read and parse STDIN data - GET only plus ENV.
    cgi::response resp;
    bs::error_code ec;
    resp << cgi::content_type("application/json") << cgi::charset("utf-8");

    string database = "br/feginfo.csv";
    try
    {
        {
            // Environment variable overrides the default settings to determine the DB location.
            // This is used for the test cases to select different databases.
            const char* env_p = std::getenv("BERGCMSDB");
            if ((NULL != env_p) && fs::exists(env_p))
            {
                database = env_p;
                // TODO log: Database changed to '%s'.
            }
        }

        // Dispatch the requested service
        // CGI
        string const& query = req.query_string();
        if (0 == query.length()) { throw "Empty query"; } // TODO return Default
        if (alg::starts_with(query, "/articles"))
        {
            FileStorage storage;
            storage.Load(database);
            if ("GET" == req.method())
            {
                if ("/articles" == query)
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
                else
                {
                    // single article
                    constexpr string::size_type artLen = sizeof("/articles/")/sizeof(' ') - 1;
                    auto strid = query.substr(artLen);
                    int id = boost::lexical_cast<int>(strid);
                    Article const& article = storage.GetArticle(id);
                    string jsonArticle;
                    article.GetAsJSON(jsonArticle);
                    resp << jsonArticle;
                    resp.status(http::ok);
                }
            }
            else if ("POST" == req.method())
            {
                if ("/articles" == query) // create new article
                {
                    Article newArticle;
                    // TODO fill with provided information - the ID is ignored - better overwritten in the NewArticle method.
                    storage.NewArticle(newArticle);
                    string jsonArticle;
                    newArticle.GetAsJSON(jsonArticle);
                    resp << jsonArticle;
                    resp.status(http::created);
                }
            }
            else { throw "Method not supported: " + req.method(); }
        }
    }
    catch(std::exception const& ex)
    {
        ++errors;
        resp << "Error: " << ex.what() << "";
        resp.status(http::internal_server_error);
    }
    catch(std::string const& ex)
    {
        ++errors;
        resp << "Internal Error: " << ex << "";
        resp.status(http::internal_server_error);
    }
    catch(...)
    {
        ++errors;
        resp << "Error: Exception.";
        resp.status(http::internal_server_error);
    }

    return cgi::commit(req, resp, errors);
}


int main(int argc, char* argv[])
{
    if (0 < argc) { DirectoryLayout::MutableInstance().SetProgramName(argv[0]); }
    return Common::InvokeWithErrorHandling(&HandleRequest);
}

