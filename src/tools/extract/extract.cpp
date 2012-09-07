/**
 * @file extract.cpp
 * Extracts the active articles from a database.
 * Used when setting up an archive.
 * 
 * Copyright 2012 Christian Leutloff <leutloff@sundancer.oche.de>
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
#include <FileStorage.h>

#include <boost/filesystem.hpp>
//#define BOOST_NO_STD_WSTRING
//#include <boost/lexical_cast.hpp>
#include <boost/program_options.hpp>

#include <iostream>

using namespace std;
using namespace berg;
namespace fs = boost::filesystem;
namespace po = boost::program_options;

int main(int argc, char *argv[])
{
    try
    {
        po::options_description desc("v0.1,\nSupported options");
        desc.add_options()( //
                "help,h", "produce help message")( //
                "version,v", "version information")( //
                "input,i", po::value<string>(), "specify input file")( //
                "output,o", po::value<string>(), "specify output file");

        po::positional_options_description p;
        p.add("input", -1);

        po::variables_map vm;
        po::store(po::command_line_parser(argc, argv) //
                          .options(desc).positional(p).run(),
                  vm);
        po::notify(vm);

        if (vm.count("help"))
        {
            cout << desc << "\n";
            return 1;
        }
        if (vm.count("version"))
        {
            cout << desc << "\n";
            return 1;
        }

        bool error = false;
        if (vm.count("input"))
        {
            cout << "Input file was set to " << vm["input"].as<string>() << "." << endl;
        }
        else
        {
            error = true;
            cout << "Input file was not set, but this is required." << endl;
        }
        if (vm.count("output"))
        {
            cout << "Output file was set to " << vm["output"].as<string>() << "." << endl;
        }
        else
        {
            cout << "Output file was not set." << endl;
        }
        if (error)
        {
            cout << "Abort program. Use --help to get a list of the available options." << endl;
            return 1;
        }

        FileStorage storage;
        storage.SetFilter(boost::shared_ptr<FilterIsActive>(new FilterIsActive()));
        storage.Load(vm["input"].as<string>());
        storage.Save(vm["output"].as<string>());
        cout << "Saved the active articles from " << vm["input"].as<string>();
        cout << " into " << vm["output"].as<string>() << ".\n";
    }
    catch (exception& e)
    {
        cerr << "error: " << e.what() << endl;
        return 1;
    }
    catch (std::string const& e)
    {
        cerr << "error: " << e << endl;
        cout << "Current directory: " << fs::initial_path() << endl;
        return 1;
    }
    catch (...)
    {
        cerr << "Exception of unknown type!" << endl;
    }

    return 0;
}

