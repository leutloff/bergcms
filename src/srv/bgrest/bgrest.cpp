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
#include <boost/cgi/cgi.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/foreach.hpp>
//#include <boost/date_time/posix_time/posix_time.hpp>
//#include <boost/iostreams/tee.hpp>
//#include <boost/iostreams/stream.hpp>
//#include <boost/process/process.hpp>
#include <fstream>
#include <iostream>
#include <locale>
#include <sstream>
#include <stdlib.h>

using namespace std;
using namespace berg;
//namespace bchrono = boost::chrono;
//namespace bio = boost::iostreams;
//namespace pt = boost::posix_time;
//namespace bp = boost::process;

namespace bs = boost::system;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;


int HandleRequest(boost::cgi::request& req)
{
    uint errors = 0;

    req.load(cgi::parse_get); // Read and parse STDIN data - GET only plus ENV.
    cgi::response resp;
    bs::error_code ec;
    resp << cgi::content_type("application/json") << cgi::charset("utf-8");

    resp << "{\r\n    \"article\": {\r\n        \"id\": 4294967295,\r\n        \"priority\": -1,\r\n        \"type\": \"\",\r\n"
//            "        \"chapter\": \"\",\n        \"title\": \"\",\n"
//            "        \"header\": \"\",\n        \"body\": \"\",\n        \"footer\": \"\",\n"
            "        \"lastChanged\": \"\"\r\n    }\r\n}\r\n";

    try
    {

    }
    catch(std::exception const& ex)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Fehler: " << ex.what() << "</p>";
    }
    catch(std::string const& ex)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Interner Fehler: " << ex << "</p>";
    }
    catch(...)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Fehler: Exception.</p>";
    }

    return cgi::commit(req, resp, errors);
}


int main(int argc, char* argv[])
{
    if (0 < argc) { DirectoryLayout::MutableInstance().SetProgramName(argv[0]); }
    return Common::InvokeWithErrorHandling(&HandleRequest);
}

