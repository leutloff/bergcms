/**
 * @file berg.cpp
 * This is the CGI program berg - the main entry point for the whole system.
 */
#include "Common.h"
#include <ctemplate/template.h>

using namespace std;
using namespace berg;
namespace cgi = boost::cgi;
namespace tpl = ctemplate;

int HandleRequest(boost::cgi::request& req)
{
    tpl::TemplateDictionary dict("head");
    Common::FillDictionaryCommon(dict);
    Common::FillDictionaryHead(dict);

    req.load(cgi::parse_get); // Read and parse STDIN data - GET only plus ENV.
    string templateName = "berg_main.tpl";
    if (0 < req.get.count("cntnt"))
    {
        if ("hlp" == req.get["cntnt"]) { templateName = "berg_main_help.tpl"; }
        else if ("abt" == req.get["cntnt"]) { templateName = "berg_main_about.tpl"; }
    }
    string output = "";
    tpl::ExpandTemplate(Common::GetTemplate(templateName), ctemplate::STRIP_BLANK_LINES, &dict, &output);
    return Common::SendResponse(req, output);
}

int main(int argc, char* argv[])
{
    return Common::InvokeWithErrorHandling(&HandleRequest);
}
