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

#include <BoostFlags.h>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <iostream>
#include <string>

namespace berg
{
    namespace testonly
    {
        /**
         * @brief determines the directory used for input files for the test cases.
         * @return the directory with the input files
         */
        inline boost::filesystem::path GetInputDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../src/test/input/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../src/test/input/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/src/test/input/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }

        /**
         * @brief determines the directory with archive files used for the test cases.
         * @return the directory with the archive files
         */
        inline boost::filesystem::path GetArchiveDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../src/test/input/archive/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../src/test/input/archive/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/src/test/input/archive/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }

        /**
         * @brief determines the directory used to write files within the test cases.
         * @return the directory to write files
         */
        inline boost::filesystem::path GetOutputDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../src/test/output/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../src/test/output/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/src/test/output/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }

        /**
         * @brief determines the directory where the input, output and expected directories are located.
         * Path used to execute the perl scripts.
         * @return the main test directory
         */
        inline boost::filesystem::path GetTestDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../src/test/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../src/test/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/src/test/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }

        /**
         * @brief determines the directory containing files used to validate the outcome of some steps.
         * @return the directory with expected output files
         */
        inline boost::filesystem::path GetExpectedDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../src/test/expected/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../src/test/expected/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/src/test/expected/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }

        /**
         * @brief determines the directory containing the perl files berg.pl, pex.pl, etc.
         * @return the directory with perl files
         */
        inline boost::filesystem::path GetCgiBinDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../www/cgi-bin/brg/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../www/cgi-bin/brg/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            input = "../../berg/www/cgi-bin/brg/";
            if (fs::exists(input))
            {
                return fs::canonical(input);
            }
            return fs::path("");
        }


        /**
         * @brief Determines the directory containing build of the srv directory, e.g. srv/bgrest/bgrest.
         * @return the directory base of the srv files, srv
         */
        inline boost::filesystem::path GetSrvBuildDir()
        {
            namespace fs = boost::filesystem;
            std::string input = "../../srv/bgrest/bgrest";
            if (fs::exists(input))
            {
                return fs::canonical("../../srv/");
            }
            input = "../srv/bgrest/bgrest";
            if (fs::exists(input))
            {
                return fs::canonical("../srv/");
            }
            return fs::path("");
        }


        /**
         * @brief Read the file and print each line to the output stream
         * @param file to read
         * @param oss stream the content is written to
         */
        inline void PrintFileToStream(boost::filesystem::path const& file, std::ostream &oss)
        {
            if (boost::filesystem::exists(file))
            {
                boost::filesystem::ifstream ifs(file);
                if (ifs.is_open())
                {
                    std::string line;
                    //int cnt = 0;
                    while (ifs.good())
                    {
                        std::getline(ifs, line);
                        //++cnt;
                        oss << line << "\n";
                    }
                }
                else
                {
                    oss << "Die Datei (" << file.c_str() << ") konnte nicht geöffnet werden!\n";
                }
            }
            else
            {
                oss << "Datei (" << file.c_str() << ") nicht existiert und kann deswegen nicht ausgegeben werden!\n";
            }
        }

        /**
         * @brief Read the file and add each line to the returned vector.
         * @param file to read
         * @return vector with file content
         */
       inline bool LoadFile(boost::filesystem::path const& file, std::vector<std::string> & fileContent)
       {
           fileContent.clear();
           if (boost::filesystem::exists(file))
           {
               boost::filesystem::ifstream ifs(file);
               if (ifs.is_open())
               {
                   std::string line;
                   while (ifs.good())
                   {
                       std::getline(ifs, line);
                       fileContent.push_back(line);
                   }
                   return true;
               }
           }
           return false;
       }

       /**
        * @brief RemoveIgnoreLine scans the first vector for elements containing <ignoreline> at the beginning.
        *        Any found element is removed from both vectors.
        * @param expected
        * @param actual
        */
       inline void RemoveIgnoreLine(std::vector<std::string> & expected, std::vector<std::string> & actual)
       {
           size_t nMax = std::max(expected.size(), actual.size());
           size_t i = 0;
           while ((nMax > i) && (std::string::npos != expected[i].find("<ignoreline>")))
           {
               ++i;
           }
           if (0 < i)
           {
               expected.erase(expected.begin(), expected.begin()+i);
               actual.erase(actual.begin(), actual.begin()+i);
           }
       }

//       /**
//        * @brief Replaces the utf-16 character representation.
//        * @param lines
//        */
//       inline bool ReplaceUTF16(boost::filesystem::path const& file)
//       {
//           std::vector<std::string> fileContent;
//           if (!LoadFile(file, fileContent)) { return false; }
//           boost::filesystem::ofstream ofs(file);
//           if (!ofs.is_open())  { return false; }
//           for (auto& line: fileContent)
//           {
//               line = boost::replace_all_copy(line, "\t", "+\t+"); // \u0009 -> \t
//               ofs << line << std::endl;
//           }
//       }

    }
}

#endif /* TEST_SHARED_H_ */


