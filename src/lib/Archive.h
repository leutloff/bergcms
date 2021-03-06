/*
 * @file Archive.h
 * This class provides the archive specific functions.
 * 
 * Copyright 2012, 2014, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#ifndef ARCHIVE_H_
#define ARCHIVE_H_

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include "BoostFlags.h"

#include <string>
#include <vector>
#include <boost/filesystem.hpp>
#include <boost/regex.hpp>
#if defined(USE_CTEMPLATE)
#include <ctemplate/template_dictionary.h>
#endif

namespace berg
{

/**
 * Archive manager.
 */
class Archive
{
public:
    typedef std::vector<std::string> TArchiveFiles;
private:
    TArchiveFiles archiveFiles;
public:
    Archive(size_t reserveSize = 64) : archiveFiles()
    {
        archiveFiles.reserve(reserveSize);
    }

    /**
     * Loads the file names in the given directory.
     *
     * @param archiveDir directory to analyze.
     * @param matchingRegex only files matching the given Regex will be part of the Archive files.
     * @returns amount of found files.
     */
    size_t Load(boost::filesystem::path const& archivePath, boost::regex const& matchingRegex = boost::regex("gi\\d*"));
    size_t Load(std::string const& archiveDir, boost::regex const& matchingRegex = boost::regex("gi\\d*"))
    {
        boost::filesystem::path archivePath(archiveDir);
        return Load(archivePath, matchingRegex);
    }

    TArchiveFiles const& GetDatabaseList() const { return archiveFiles; }

    /**
      * Returns the archive name from the given filename, e.g.
      * for path/to/archive/gi003.cvs it returns gi003.
      */
    static std::string GetArchiveNameFromPath(std::string & filenameWithPath);
    static std::string GetArchiveNameFromPath(boost::filesystem::path const& filenameWithPath);

};


}

#endif /* ARCHIVE_H_ */
