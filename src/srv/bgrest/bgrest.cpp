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
#include "RestArticle.h"
#include <boost/algorithm/string/predicate.hpp>
#include <boost/cgi/http/status_code.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/foreach.hpp>
#include <boost/lexical_cast.hpp>
#include <fstream>
#include <iostream>
#include <locale>
#include <sstream>
#include <cstdlib>

using namespace std;
using namespace berg;
using namespace bergcms;

namespace alg = boost::algorithm;
namespace bs = boost::system;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;


/**
 * @brief HandleRequest - handles the request of the REST API
 * @param req
 * @return
 * @throws
 */
int HandleRequest(boost::cgi::request& req)
{
    req.load(cgi::parse_all); // Read and parse STDIN data - GET only plus ENV.
    cgi::response resp;

    string database = "br/feginfo.csv";
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
    if (alg::starts_with(query, "/articles") || (alg::starts_with(query, "/brg/articles")))
    {
        RestArticle restArticle(database);
        restArticle.dispatchArticles(req, resp);
    }
    return cgi::commit(req, resp);
}


int main(int argc, char* argv[])
{
    if (0 < argc) { DirectoryLayout::MutableInstance().SetProgramName(argv[0]); }
    return Common::InvokeWithErrorHandling(&HandleRequest);
}

