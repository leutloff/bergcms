/**
 * @file Common.cpp
 *  Some static shared methods.
 * 
 * Copyright 2012, 2013, 2014 Christian Leutloff <leutloff@sundancer.oche.de>
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

#include <Common.h>
#include <boost/filesystem.hpp>
#include <boost/cgi/cgi.hpp>
#include <locale>

using namespace std;
using namespace berg;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;

void Common::FillDictionaryCommon(ctemplate::TemplateDictionary & dict)
{
    dict.SetValue("SYSTEM_TITLE", "Redaktion FeG Aachen");
    dict.SetValue("SYSTEM_TITLE_LONG", "Redaktionssystem FeG Aachen");
    dict.SetValue("SYSTEM_TITLE_SHORT", "Redaktion AC");
    dict.SetValue("SYSTEM_TITLE_SHORT_ASCII", "Redaktion AC"); // for use in <title>
    dict.SetValue("BERG_LANG", "de");
    dict.SetValue("BERG_VERSION", "Berg CMS " + GetBergVersion()); //Berg v3.0.0");
    dict.SetValue("BERG_COPYRIGHT", "2012, 2013, 2014 Christian Leutloff");
    dict.SetValue("BERG_AUTHOR", "Christian Leutloff");

    dict.SetValue("BERG_CGI_ROOT", "/cgi-bin/brg");
}

void Common::FillDictionaryHead(ctemplate::TemplateDictionary & dict)
{
    dict.SetValue("HEAD_TITLE", "Berg CMS");
    //dict.SetValue("ACTIVE_ARCHIVE", " active"); // this is the class attribute to indicate the we are in the archive section
}

string Common::GetTemplate(string const& templateBase)
{
    string templateName = templateBase;
    if (fs::exists(templateName)) { return templateName; }

    templateName = "template/" + templateBase;
    if (fs::exists(templateName)) { return templateName; }

    templateName = "../template/" + templateBase;
    if (fs::exists(templateName)) { return templateName; }

    templateName = "../../../www/cgi-bin/brg/template/" + templateBase;
    if (fs::exists(templateName)) { return templateName; }

    templateName = "../../src/exp/" + templateBase;
    if (fs::exists(templateName)) { return templateName; }

    return templateBase;
}

int Common::InvokeWithErrorHandling(boost::function<int (boost::cgi::request& req)> handler)
{
    // only the standard locale must be used on Lenny
    std::locale::global(std::locale("C"));
    try
    {
        cgi::request req(cgi::parse_none); // Loading the request data delayed.
        try
        {
            return handler(req);
        }
        catch (boost::system::system_error const& se)
        {
            return Common::SendErrorPage(req, "Systemfehler", se.what());
        }
        catch (std::exception const& e)
        {
            return Common::SendErrorPage(req, "Standardbibliothek", e.what());
        }
        catch (std::string const& e)
        {
            return Common::SendErrorPage(req, "", e);
        }
        catch (...)
        {
            return Common::SendErrorPage(req, "", "Fehler ohne Beschreibung 8-(");
        }
    }
    catch (boost::system::system_error const& se)
    {
        // This is the type of error thrown by the library.
        cerr << "[main] System error: " << se.what() << endl;
        return -1;
    }
    catch (std::exception const& e)
    {
        // Catch any other exceptions
        cerr << "[main] Standard Library Exception: " << e.what() << endl;
        return -1;
    }
    catch (std::string const& e)
    {
        cerr << "[main] Exception: " << e << endl;
        return -1;
    }
    catch (...)
    {
        cerr << "[main] Uncaught exception!" << endl;
        return -1;
    }
    return 0;
}

int Common::SendErrorPage(boost::cgi::request& req, std::string const& errorType, std::string const& errorMsg)
{
    cgi::response resp;
    resp << cgi::content_type("text/html") << cgi::charset("utf-8");

    resp << "<html>";
    resp << "<head><title>Fehler</title><head>";
    resp << "<body>\n" ;
    if (0 < errorType.length())
    {
        resp << "<p>Fehlertyp: " << errorType << "</p>\n";
    }
    resp << "<p>Fehlermeldung: " << errorMsg << "</p>\n";

    resp << "<p>Berg Version: " << GetBergVersion() << "/" << GetBergLastChangedDate() << "\n";
    resp << "</body></html>";
    return cgi::commit(req, resp);
}

int Common::SendResponse(boost::cgi::request& req, std::string const& output)
{
    cgi::response resp;
    resp << cgi::content_type("text/html") << cgi::charset("utf-8");
    resp << output;
    return cgi::commit(req, resp);
}

string Common::GetBergVersion()
{
    return "v3.1.5";
}

std::string Common::GetBergLastChangedDate()
{
    return "21.03.2014";
}

