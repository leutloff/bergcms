/*
 * @file TestShared.h
 * This header provides the functions used for testing purposes only.
 *
 * Copyright 2013 Christian Leutloff <leutloff@sundancer.oche.de>
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
#ifndef TEST_SHARED_H_
#define TEST_SHARED_H_

#include <boost/filesystem.hpp>
#include <string>

namespace berg
{
    namespace testonly
    {
        /**
         * @brief determines the directory used for input files for the test cases.
         * @return the directory with the input files
         */
        inline std::string GetInputDir()
        {
            std::string input = "../../src/test/input/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            input = "../src/test/input/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            return "";
        }

        /**
         * @brief determines the directory with archive files used for the test cases.
         * @return the directory with the archive files
         */
        inline std::string GetArchiveDir()
        {
            std::string input = "../../src/test/input/archive/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            input = "../src/test/input/archive/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            return "";
        }

        /**
         * @brief determines the directory used to write files within the test cases.
         * @return the directory to write files
         */
        inline std::string GetOutputDir()
        {
            std::string input = "../../src/test/output/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            input = "../src/test/output/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            return "";
        }

        /**
         * @brief determines the directory containing files used to validate the outcome of some steps.
         * @return the directory with expected output files
         */
        inline std::string GetExpectedDir()
        {
            std::string input = "../../src/test/expected/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            input = "../src/test/expected/";
            if (boost::filesystem::exists(input))
            {
                return input;
            }
            return "";
        }

    }
}

#endif /* TEST_SHARED_H_ */


