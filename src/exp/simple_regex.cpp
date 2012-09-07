// let the example from http://www.boost.org/doc/libs/1_48_0/libs/regex/doc/html/boost_regex/ref/regex_match.html
// run within the Lenny Apache Server
#include <stdlib.h> 
#include <boost/regex.hpp> 
#include <string> 
#include <iostream> 

using namespace boost; 
using namespace std;

regex expression("([0-9]+)(\\-| |$)(.*)"); 

// process_ftp: 
// on success returns the ftp response code, and fills 
// msg with the ftp response message. 
int process_ftp(const char* response, std::string* msg) 
{ 
    cmatch what; 
    if(regex_match(response, what, expression)) 
    { 
        // what[0] contains the whole string 
        // what[1] contains the response code 
        // what[2] contains the separator character 
        // what[3] contains the text message. 
        if(msg) 
            msg->assign(what[3].first, what[3].second); 
        return std::atoi(what[1].first); 
    } 
    // failure did not match 
    if(msg) 
        msg->erase(); 
    return -1; 
}

int main()
{
    cout << "Content-Type: text/html" << endl << endl;

    cout << "Show a successful ftp response using boost regex. " << endl;
    std::string in, out;
    in = "100 this is an ftp message text";
    int result;
    result = process_ftp(in.c_str(), &out);
    if(result != -1)
    {
        cout << "Match found:" << endl;
        cout << " - Response code: " << result << endl;
        cout << " - Message text: " << out << endl;
    }
    else
    {
        cout << "Match not found" << endl;
    }
    cout << endl;
    return 0;
}

