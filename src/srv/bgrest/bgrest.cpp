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
//#include <boost/iostreams/tee.hpp>
//#include <boost/iostreams/stream.hpp>
//#include <boost/process/process.hpp>
#include <fstream>
#include <iostream>
#include <locale>
#include <sstream>
#include <cstdlib>

using namespace std;
using namespace berg;
//namespace bchrono = boost::chrono;
//namespace bio = boost::iostreams;
//namespace pt = boost::posix_time;
//namespace bp = boost::process;

namespace alg = boost::algorithm;
namespace bs = boost::system;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;
namespace http = boost::cgi::http;


int HandleRequest(boost::cgi::request& req)
{
    int errors = 0;

    req.load(cgi::parse_get); // Read and parse STDIN data - GET only plus ENV.
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
            if ("/articles" == query)
            {
                string jsonArticle;
                resp << "[\r\n";
                FileStorage::TArticles const& articles = storage.GetArticles();
                bool isFirst = true;
                for (FileStorage::TArticles::const_iterator it = articles.begin(); it < articles.end(); ++it)
                {
                    if (!isFirst)
                    {
                        resp << ",\r\n";
                    }
                    else
                    {
                        isFirst = false;
                    }
                    (*it)->GetAsJSON(jsonArticle);
                    resp << jsonArticle;
                }
                resp << "\r\n";
                resp << "]\r\n";
                resp.status(http::ok);
            }
            else
            {
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

