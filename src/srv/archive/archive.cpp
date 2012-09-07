/**
 * @file archive.cpp
 * This is the CGI program archive.
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
#include "Archive.h"
#include "Common.h"
#include "FileStorage.h"
#include "boost/cgi/cgi.hpp"
#include <boost/filesystem.hpp>
#include <boost/foreach.hpp>
#include <ctemplate/template.h>
#include <locale>

using namespace std;
using namespace berg;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;
namespace tpl = ctemplate;

// TODO use configuration
string GetArchiveDir()
{
    string input = "../../../src/test/input/archive/";
    if (fs::exists(input))
    {
        return input;
    }
    input = "../src/test/input/archive/";
    if (fs::exists(input))
    {
        return input;
    }
    input = "archive_content/";
    if (fs::exists(input))
    {
        return input;
    }
    return "";
}


int HandleRequest(boost::cgi::request& req)
{
    req.load(cgi::parse_all); // Read and parse STDIN (ie. POST) data.

    tpl::TemplateDictionary dict("head");
    Archive::FillDictionaryHead(dict);
    Common::FillDictionaryCommon(dict);
    // TODO output header only and flush it!? - but only if input is acceptable!

    std::string output = "";
    if (0 < req.get.count("archive"))
    {
        std::string const& archiveName = req.get["archive"];
        Archive::FillDictionarySingleArchive(dict, archiveName);
        FileStorage storage;
        storage.Load(GetArchiveDir() + archiveName);

        //        resp << "<html>";
        //        resp << "<head><title>Eine bestimmte Ausgabe</title><head>";
        //        resp << "<body>";

        //        resp << "<p>" << req.get["archive"] << "</p>\n";

        //        resp << "</body></html>";

        if (0 < req.get.count("article"))
        {
            Article const& article = storage.GetArticle(req.get["article"]);
            article.FillDictionaryBody(dict);
            tpl::ExpandTemplate(Common::GetTemplate("berg_archive_single_article.tpl"), tpl::STRIP_BLANK_LINES, &dict, &output);
        }
        else
        {
            // show all articles
            storage.FillDictionaryBody(dict);
            tpl::ExpandTemplate(Common::GetTemplate("berg_archive_all_articles.tpl"), tpl::STRIP_BLANK_LINES, &dict, &output);
        }
    }
    else
    {
        Archive archive;
        if (0 < archive.Load(GetArchiveDir()))
        {
            archive.FillDictionaryBody(dict);
        }
        // TODO indicate empty archive dir
        tpl::ExpandTemplate(Common::GetTemplate("berg_archive.tpl"), tpl::STRIP_BLANK_LINES, &dict, &output);
    }
    cgi::response resp;
    resp << cgi::content_type("text/html") << cgi::charset("utf-8");
    resp << output;
    return cgi::commit(req, resp);
}

int main(int argc, char* argv[])
{
    return Common::InvokeWithErrorHandling(&HandleRequest);
}

