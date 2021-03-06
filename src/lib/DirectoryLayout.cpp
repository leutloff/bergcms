/**
 * @file DirectoryLayout.cpp
 * A Singleton providing information about the directory layout.
 *
 * Copyright 2014, 2016, 2018 Christian Leutloff <leutloff@sundancer.oche.de>
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

#include "DirectoryLayout.h"
#include <boost/system/error_code.hpp>

using namespace std;
using namespace berg;
namespace bs = boost::system;
namespace fs = boost::filesystem;

void DirectoryLayout::SetProgramName(std::string const& programName)
{
    bs::error_code ec;
    pathProgramName = programName;
    if (fs::exists(programName))
    {
        const fs::path programPath = fs::path(programName).parent_path();
        if (!programPath.string().empty())
        {
            dirCgiBin = CheckPath(programPath, BERG_DEFAULT_CGIBIN);
        }
        else
        {
            dirCgiBin = CheckPath(fs::current_path(ec), BERG_DEFAULT_CGIBIN);
        }
        dirHtDocs = CheckPath(dirCgiBin / ".." / ".." / "htdocs" / "brg", dirCgiBin / ".." / ".." / "web" / "brg", BERG_DEFAULT_HTDOCS);
        dirDlb = CheckPath(dirHtDocs / ".." / "dlb", BERG_DEFAULT_DLB);
    }
    else
    {
        Init();
    }
}

void DirectoryLayout::SetWorkingDirectory(std::string const& programName, std::string const& workingDirectory)
{
    bs::error_code ec;
    pathProgramName = programName;
    if (fs::exists(workingDirectory))
    {
        dirCgiBin = CheckPath(workingDirectory, BERG_DEFAULT_CGIBIN);
        dirHtDocs = CheckPath(dirCgiBin / ".." / ".." / "htdocs" / "brg", dirCgiBin / ".." / ".." / "web" / "brg", BERG_DEFAULT_HTDOCS);
        dirDlb = CheckPath(dirHtDocs / ".." / "dlb", BERG_DEFAULT_DLB);
    }
    else
        SetProgramName(programName);
}

boost::filesystem::path DirectoryLayout::CheckPath(boost::filesystem::path const& pathToCheck, std::string const& pathToUseInErrorCase)
{
    if (!pathToCheck.empty())
    {
        boost::system::error_code ec;
        fs::path pathToReturn = boost::filesystem::canonical(pathToCheck, ec);
        if (ec.value() == 0)
        {
            return pathToReturn;
        }
    }
    return fs::path(pathToUseInErrorCase);
}

boost::filesystem::path DirectoryLayout::CheckPath(boost::filesystem::path const& pathToCheckFirst,
                                                   boost::filesystem::path const& pathToCheckSecond,
                                                   std::string const& pathToUseInErrorCase)
{
    if (!pathToCheckFirst.empty())
    {
        boost::system::error_code ec;
        fs::path pathToReturn = boost::filesystem::canonical(pathToCheckFirst, ec);
        if (ec.value() == 0)
        {
            return pathToReturn;
        }
    }
    if (!pathToCheckSecond.empty())
    {
        boost::system::error_code ec;
        fs::path pathToReturn = boost::filesystem::canonical(pathToCheckSecond, ec);
        if (ec.value() == 0)
        {
            return pathToReturn;
        }
    }
    return fs::path(pathToUseInErrorCase);
}
