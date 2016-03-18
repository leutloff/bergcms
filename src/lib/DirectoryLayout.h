/**
 * @file DirectoryLayout.h
 * A Singleton providing information about the directory layout.
 *
 * Copyright 2014, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#if !defined(BERG_DIRECTORYLAYOUT_H)
#define BERG_DIRECTORYLAYOUT_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include "BoostFlags.h"
#include <boost/serialization/singleton.hpp>
#include <boost/filesystem.hpp>
#include <string>

namespace berg
{

/**
 * A Singleton providing information about the directory layout.
 */
class DirectoryLayout
{
private:
#define BERG_DEFAULT_CGIBIN "/home/aachen/cgi-bin/brg"
#define BERG_DEFAULT_HTDOCS "/home/aachen/htdocs/brg"
#define BERG_DEFAULT_DLB    "/home/aachen/htdocs/dlb"

    boost::filesystem::path dirCgiBin, dirHtDocs, dirDlb;
    boost::filesystem::path pathProgramName;

protected:
    DirectoryLayout() : dirCgiBin(BERG_DEFAULT_CGIBIN), dirHtDocs(BERG_DEFAULT_HTDOCS), dirDlb(BERG_DEFAULT_DLB)
    { }

public:
    /// Get singleton instance.
    static DirectoryLayout const& Instance() { return boost::serialization::singleton<DirectoryLayout>::get_const_instance(); }
    static DirectoryLayout & MutableInstance() { return boost::serialization::singleton<DirectoryLayout>::get_mutable_instance(); }

    /**
     * @brief SetProgramName call from main with argv[0].
     * All executables are expected in cgi-bin/brg. Therefore all other
     * directories are referenced relative to this directory.
     * If argv[0] does not contain a directory the current working directory is used instead.
     * @param programName
     */
    void SetProgramName(std::string const& programName);
    boost::filesystem::path const& GetProgramName() const { return pathProgramName; }

    boost::filesystem::path const& GetCgiBinDir() const { return dirCgiBin; }
    boost::filesystem::path const& GetHtdocsDir() const { return dirHtDocs; }
    boost::filesystem::path const& GetHtdocsDownloadDir() const { return dirDlb; }


    void GetHtdocsDownloadDir(boost::filesystem::path & downloadDir) const
    { downloadDir = dirDlb; }

private:
    /**
     * @brief Checks the Path using fs::canonical(). When the directory does not exists,
     * the pathToUseInErrorCase is returned.
     */
    static boost::filesystem::path CheckPath(boost::filesystem::path const& pathToCheck, std::string const& pathToUseInErrorCase);
    /**
     * @brief Same as CheckPath with two parameters but the
     * second parameter is tried in addition to the first one.
     */
    static boost::filesystem::path CheckPath(boost::filesystem::path const& pathToCheckFirst,
                                             boost::filesystem::path const& pathToCheckSecond,
                                             std::string const& pathToUseInErrorCase);

    void Init()
    {
        dirCgiBin = BERG_DEFAULT_CGIBIN;
        dirHtDocs = BERG_DEFAULT_HTDOCS;
        dirDlb = BERG_DEFAULT_DLB;
    }

#undef DEFAULT_CGIBIN
#undef DEFAULT_HTDOCS
#undef DEFAULT_DLB
};


}


#endif // BERG_DIRECTORYLAYOUT_H
