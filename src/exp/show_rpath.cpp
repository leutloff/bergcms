
#include <errno.h>
#include <dirent.h>
#include <dlfcn.h>
#include <link.h>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <algorithm>
using namespace std;

const std::string GetRPath();
const std::string GetExePath();
const std::string GetCwd();

void ListFiles(std::string const& headline, std::string const& dir, bool doLoad = false);
void LoadLib(std::string const& headline, std::string const& libName);
void CallMaker();

int main()
{
    cout << "Content-Type: text/html" << endl << endl;
    cout << "Shows the RPATH and some related information." << endl << endl;

    cout << "RPATH: " << GetRPath() << endl;
    cout << "Exe:   " << GetExePath() << endl;
    cout << "Cwd:   " << GetRPath() << endl;
    cout  << endl;

    ListFiles("lib", "lib");
    ListFiles("./lib", "./lib");
    ListFiles("../lib", "../lib");
    ListFiles("cwd", GetCwd());
    ListFiles("rpath", GetRPath());

    ListFiles("lib", "lib", true);
    ListFiles("rpath", GetRPath(), true);

    cout << "   ***   Calling Maker    ***" << endl;
    CallMaker();
    return 0;
}

const std::string GetRPath()
{
    const ElfW(Dyn) *rpath = NULL;
    const char *strtab = NULL;

    for (const ElfW(Dyn) *dyn = _DYNAMIC; dyn->d_tag != DT_NULL; ++dyn)
    {
        if (dyn->d_tag == DT_RPATH)
        {
            rpath = dyn;
        }
        else if (dyn->d_tag == DT_STRTAB)
        {
            strtab = (const char *)dyn->d_un.d_val;
        }
    }

    if (strtab != NULL && rpath != NULL)
    {
        return strtab + rpath->d_un.d_val;
    }
    return "";
}

const std::string GetExePath()
{
    char exeBuffer[1024];
    char exePath[1024];
    snprintf(exeBuffer, sizeof(exeBuffer), "/proc/%d/exe", getpid());
    int bytes = min(readlink(exeBuffer, exePath, sizeof(exePath)), (ssize_t)(sizeof(exePath) - 1));
    if(bytes >= 0) { exePath[bytes] = '\0';}
    return exePath;
}

const std::string GetCwd()
{
    char path[1024];
    getcwd(path, sizeof(path));
    return path;
}

void ListFiles(std::string const& headline, std::string const& dirName, bool doLoad)
{
    cout << endl << "   ***   " << headline << "   ***   " << endl;
    DIR *dir = opendir(dirName.c_str());
    if (dir != NULL)
    {
        cout << "* Files in directory '" << dirName << "'." << ": " << endl;
        struct dirent *ent;
        while((ent = readdir (dir)) != NULL)
        {
            if(strcmp(ent->d_name, ".") && strcmp(ent->d_name, ".."))
            {
                cout << "   " << ent->d_name << endl;
                if (doLoad) { LoadLib(ent->d_name, ent->d_name); }
            }
        }
        closedir (dir);
    }
    else
    {
        cout  << endl << "Could not open directory '" << dirName << "'." << endl;
    }
}

void LoadLib(std::string const& headline, std::string const& libName)
{
    cout << " - Loading '" << headline << "'." << ": ";
    dlopen(libName.c_str(), RTLD_NOW);
    char *err = dlerror();
    if (NULL != err)
    {
        cout << "ERROR: " << err << endl;
    }
    else
    {
        cout << "ok." << endl;
    }
}

void CallMaker()
{
   int ret = execl("./maker", "./maker");
   cout << "ret: " << ret << endl;
   cout << "errno: " << errno << " - errmsg: " << strerror(errno) << endl;
}
