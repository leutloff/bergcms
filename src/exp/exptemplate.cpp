
#include <stdlib.h>
#include <string>
#include <iostream>

#if defined(_MSC_VER)
#   pragma warning(push)
#   pragma warning(disable: 4251) // 'ctemplate::Template::resolved_filename_' : class 'std::basic_string<_Elem,_Traits,_Ax>' needs to have dll-interface to be used by clients of class 'ctemplate::Template'          
#endif 
#include <ctemplate/template.h>
#if defined(_MSC_VER)
#   pragma warning(pop)
#endif


#include <boost/filesystem.hpp>

using namespace std;
namespace fs=boost::filesystem;

string GetTemplate()
{
    string templateName = "example.tpl";
    if (fs::exists(templateName)) { return templateName; }

    templateName="template/example.tpl";
    if (fs::exists(templateName)) { return templateName; }

    templateName="../template/example.tpl";
    if (fs::exists(templateName)) { return templateName; }

    templateName="../../src/exp/example.tpl";
    if (fs::exists(templateName)) { return templateName; }

    return "example.tpl";
}


int main(int argc, char** argv) {
    ctemplate::TemplateDictionary dict("example");
    dict.SetValue("NAME", "John Smith");
    int winnings = rand() % 100000;
    dict.SetIntValue("VALUE", winnings);
    dict.SetFormattedValue("TAXED_VALUE", "%.2f", winnings * 0.83);
    // For now, assume everyone lives in CA.
    // (Try running the program with a 0 here instead!)
    if (1) {
        dict.ShowSection("IN_CA");
    }
    std::string output;
    ctemplate::ExpandTemplate(GetTemplate(), ctemplate::DO_NOT_STRIP, &dict, &output);

    cout << "Content-Type: text/html" << endl << endl;
    cout << output;
    return 0;
}
