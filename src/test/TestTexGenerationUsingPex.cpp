/**
 * @file TestStorage.cpp
 * Testing the generation of the TeX files using the Perl based PeX script.
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
#if defined(HAS_VISUAL_LEAK_DETECTOR)
#include <vld.h>
#endif

#include "TestShared.h"

#include <boost/filesystem.hpp>
#include <boost/iostreams/tee.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/process/process.hpp>
#include <boost/test/unit_test.hpp>

using namespace std;

namespace bio = boost::iostreams;
namespace fs = boost::filesystem;
namespace bp = boost::process;
namespace bt = berg::testonly;

const fs::path exePerl           = fs::path("/usr/bin/perl");

//// # Die CSV-Datenbank nach feginfo.tex transformieren
//log << "Lese Artikel aus der Datenbank (" << inputDatabaseFile.c_str() << "),\n";
//log << "verwende dazu PeX (" << scriptPex.c_str() << ") ...\n";

//// perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
//#if defined(WIN32)
//bio::file_descriptor_sink pe_log(pexLogfile);
//#else
//bio::file_descriptor_sink pe_log(pexLogfile.c_str());
//#endif
//bp::monitor c11 = bp::make_child(
//            bp::paths(exePerl.c_str(), BERGCGIDIR.c_str())
//            , bp::arg(scriptPex.c_str())
//            , bp::arg(inputDatabaseFile.c_str())
//            , bp::arg(texFile.c_str())
//            , bp::std_out_to(pe_log)
//            , bp::std_err_to(pe_log)
//            );
//log << "Inhalt der Protokolldatei (" << pexLogfile.c_str() << "):\n";
//int ret = c11.join(); // wait for PeX completion
//AddFileToLog(pexLogfile, log, oss);
//log << "PeX return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
//if (ret != 0) { ++errors; }

BOOST_AUTO_TEST_CASE(test_calling_perl)
{
    const fs::path pexLogfile        = fs::path(fs::path(bt::GetOutputDir()) / "perlversion.log");

    // perl -v
#if defined(WIN32)
    bio::file_descriptor_sink pe_log(pexLogfile);
#else
    bio::file_descriptor_sink pe_log(pexLogfile.c_str());
#endif
    bp::monitor c11 = bp::make_child(
                bp::paths(exePerl.c_str())
                , bp::arg("-v")
                , bp::std_out_to(pe_log)
                , bp::std_err_to(pe_log)
                );
    int ret = c11.join(); // wait for perl completion
    cout << "Perl return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
}


