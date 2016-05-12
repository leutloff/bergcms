/**
 * @file ProcessStep.h
 * Contains a single step of a process with commands and results.
 *
 * Copyright 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#if !defined(BERGCMS_PROCESSSTEP_H)
#define BERGCMS_PROCESSSTEP_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include <boost/filesystem.hpp>

#include <string>


namespace bergcms
{

class ProcessStep
{

    /// Shell script command similar to executed command. Used for documentation purposes, only.
    std::string command;
    /// The absolute path to the executable.
    boost::filesystem::path programPath;

    std::string result;
    std::string resultCode;
    std::string resultLog;

public:
    ProcessStep();

    /// Checks that the executable is available and has execute bits set.
    /// Additionally the used paths and input files may be checked.
    bool CheckPrerequisites();
    /// Perform the desired operation.
    bool Execute();

};

}

#endif // BERGCMS_PROCESSSTEP_H
