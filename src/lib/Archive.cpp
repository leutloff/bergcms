/*
 * @file Archive.cpp
 * This class implements the archive specific functions.
 * 
 * Copyright 2012, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#include "Helper.h"

#include <boost/algorithm/string.hpp>
#include <boost/foreach.hpp>

#include <algorithm>
#include <iostream>
#include <sstream>

using namespace std;
using namespace berg;
namespace fs = boost::filesystem;
#if defined(USE_CTEMPLATE)
namespace tpl = ctemplate;
#endif

static const std::string STANDARD_FILEXTENSION = ".csv";

size_t Archive::Load(boost::filesystem::path const& archivePath, boost::regex const& matchingRegex)
{
    archiveFiles.clear();
    if (!fs::exists(archivePath))
    {
        throw("Der Pfad mit den Archiven " + archivePath.generic_string() + " existiert nicht!");
    }
    if (!fs::is_directory(archivePath))
    {
        throw("Der Pfad mit den Archiven " + archivePath.generic_string() + " ist kein Verzeichnis!");
    }
    fs::directory_iterator begin(archivePath), end;
    BOOST_FOREACH(fs::path const& entry, std::make_pair(begin, end))
    {
        const string name = GetArchiveNameFromPath(entry);
        if (regex_match(name, matchingRegex))
        {
            archiveFiles.push_back(name);
        }
    }
    sort(archiveFiles.begin(), archiveFiles.end());
    //    BOOST_FOREACH(string str, archiveFiles)
    //    {
    //        cout << " - " << str;
    //    }
    //    cout << endl;
    return archiveFiles.size();
}

// #if defined(USE_CTEMPLATE)

// void Archive::FillDictionarySingleArchive(ctemplate::TemplateDictionary & dict, std::string const& archiveName)
// {
//     string nr = 2 < archiveName.length() ? archiveName.substr(2) : archiveName;
//     string issue("");
//     Helper::GetIssueFromNumber(issue, nr);
//     dict.SetValue("ARCHIVE_NAME", archiveName);
//     dict.SetValue("ARCHIVE_NUMBER", nr);
//     dict.SetValue("ARCHIVE_ISSUE", issue);
//     dict.SetValue("ARCHIVE_REFERENCE", "?archive=" + archiveName);
// }

// /**
//  * Adds the Body related content to the dictionary.
//  */
// void Archive::FillDictionaryBody(ctemplate::TemplateDictionary & dict) const
// {   
//     string issue("");
//     BOOST_FOREACH(string str, archiveFiles)
//     {
//         string nr = 2 < str.length() ? str.substr(2) : str;
//         Helper::GetIssueFromNumber(issue, nr);
//         tpl::TemplateDictionary* list = dict.AddSectionDictionary("ARCHIVE_LIST");
//         list->SetValue("ARCHIVE_NAME", str);
//         list->SetValue("ARCHIVE_NUMBER", nr);
//         list->SetValue("ARCHIVE_ISSUE", issue);
//         list->SetValue("ARCHIVE_REFERENCE", "?archive=" + str);
//     }
// }

// #endif

std::string Archive::GetArchiveNameFromPath(std::string & filenameWithPath)
{
    boost::trim(filenameWithPath);
    const fs::path filenamePath(filenameWithPath);
    return GetArchiveNameFromPath(filenamePath);
}

std::string Archive::GetArchiveNameFromPath(fs::path const& filenameWithPath)
{
    const string name = filenameWithPath.filename().string();
    const size_t pos = name.rfind(STANDARD_FILEXTENSION);
    if (string::npos != pos)
    {
        return name.substr(0, pos);
    }
    return name;
}
