/**
 * @file maker.cpp
 * Extracts the actual articles and generates the PDF.
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
 * 
 * Initial workflow based on xsc v1.04, 23.10.2011.
 * But improved since then, e.g. added makeindx calls.
 */

#include "Common.h"
//#include "BoostFlags.h"
#include <boost/cgi/cgi.hpp>
#include <boost/chrono.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/foreach.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/iostreams/tee.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/process/process.hpp>
#include <fstream>
#include <iostream>
#include <locale>
#include <sstream>

using namespace std;
using namespace berg;
namespace bchrono = boost::chrono;
namespace bio = boost::iostreams;
namespace bs = boost::system;
namespace cgi = boost::cgi;
namespace fs = boost::filesystem;
namespace pt = boost::posix_time;
namespace bp = boost::process;

typedef bio::tee_device<ostringstream, ofstream> TeeDevice;
typedef bio::stream<TeeDevice> TeeStream;

// prototypes
void AddFileToLog(fs::path const& logFile, TeeStream &log, ostringstream & oss);
void CopyToOutDir(fs::path const& filename, TeeStream & log);
void Add(TeeStream & log, ostringstream & oss, string const& html);
void CheckErrorCode(cgi::response & resp, std::string const& functionName, bs::error_code const& ec, uint & errors);
void CheckErrorCode(TeeStream & log, std::string const& functionName, bs::error_code const& ec, uint & errors);
void CheckErrorCode(std::string & errorString, std::string const& functionName, bs::error_code const& ec, uint & errors);

// Path definitions
const fs::path BERGCGIDIR("/home/aachen/cgi-bin/brg");
// /home/aachen/cgi-bin/brg/br
const fs::path BERGDBDIR = fs::path(BERGCGIDIR / "br");
// /home/aachen/cgi-bin/brg/log
const fs::path BERGLOGDIR = fs::path(BERGCGIDIR / "log");
const fs::path BERGOUTDIR = fs::path(BERGCGIDIR / "out"); // processing output
const fs::path BERGDLBDIR("/home/aachen/htdocs/dlb");

int HandleRequest(boost::cgi::request& req)
{
    bchrono::system_clock::time_point start = bchrono::system_clock::now();
    uint errors = 0;

    req.load(cgi::parse_get); // Read and parse STDIN data - GET only plus ENV.
    cgi::response resp;
    bs::error_code ec;
    resp << cgi::content_type("text/html") << cgi::charset("utf-8");

    resp << "<!DOCTYPE html>\n" // HTML5
         << "<html><head>\n"
         << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/brg/css/bgcrud.css\" />\n"
         << "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
         << "<title>Gemeindeinformation - Generator - FeG Aachen</title>\n";
    resp << "</head><body>";

    const fs::path makerLogfile      = fs::path(BERGLOGDIR / "log.txt");

    const fs::path pexLogfile        = fs::path(BERGLOGDIR / "pe.log");
    const fs::path texLogfile        = fs::path(BERGLOGDIR / "pdflatex.log");
    const fs::path idxLogfile        = fs::path(BERGLOGDIR / "makeindex.log");

    const fs::path inputDatabaseFile = fs::path(BERGDBDIR / "feginfo.csv");
    const fs::path texFile           = fs::path(BERGOUTDIR / "feginfo.tex");
    const fs::path idxFile           = fs::path(BERGOUTDIR / "feginfo.idx");
    const fs::path pdfFile           = fs::path(BERGOUTDIR / "feginfo.pdf");

    const fs::path exePerl           = fs::path("/usr/bin/perl");
    const fs::path exePdfLatex       = fs::path("/usr/bin/pdflatex");
    const fs::path exeMakeindex      = fs::path("/usr/bin/makeindex");
    const fs::path scriptPex         = fs::path(BERGCGIDIR / "pex.pl");

    resp << "\n<p><pre class=\"pex-dev\">\n";
    //  mkdir -p $BERGLOGDIR;
    if (!fs::exists(BERGLOGDIR))
    {
        resp << "Log Verzeichnis " << BERGLOGDIR << " anlegen";
        fs::create_directory(BERGLOGDIR, ec);
        CheckErrorCode(resp, "", ec, errors);
    }
    else
    {
        resp << "Log Verzeichnis " << BERGLOGDIR << " existiert.\n";
    }
    resp << "</pre></p>\n";

    // Log to file and to the HTML page.
    ostringstream oss;
    fs::ofstream ofs(makerLogfile);
    TeeDevice teeDevice(oss, ofs);
    TeeStream log(teeDevice);

    {
        //echo "xsc Script $XSCVERSION - " >$BERGLOGDIR/log.txt; echo "Start des Zeitungsgenerators pex (`date`) ..." >>$BERGLOGDIR/log.txt
        Add(log, oss, "<h1>");
        log << "Generator (maker " << Common::GetBergVersion() << " " << Common::GetBergLastChangedDate() << ")\n";
        Add(log, oss, "</h1>\n<p>");
        log << "Start des Zeitungsgenerators maker (" << pt::second_clock::local_time() << ") im Verzeichnis " << fs::current_path() << "...\n";

//        log << "pwd: " << fs::current_path(ec);
//        log << " (ec: " << ec.value() << "/" << ec.message() << ")";
//        log << ".\n";
    }

    {
        // # Die CSV-Datenbank nach FeGinfo.tex transformieren
        Add(log, oss, "</p><h3>");
        log << "Die CSV-Datenbank nach FeGinfo.tex transformieren\n";
        Add(log, oss, "</h3><pre class=\"pex-dev\">");
        fs::remove(pexLogfile, ec);
        log << "Protokolldatei (" << pexLogfile.c_str() << ") " << (ec ? "gelöscht" : "nicht gelöscht") << ".\n";
        log << "Lese Artikel aus der Datenbank (" << inputDatabaseFile.c_str() << "),\n";
        log << "verwende dazu PeX (" << scriptPex.c_str() << ") ...\n";

        // perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/FeGinfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
#if defined(WIN32)
        bio::file_descriptor_sink pe_log(pexLogfile);
#else
        bio::file_descriptor_sink pe_log(pexLogfile.c_str());
#endif
        bp::monitor c11 = bp::make_child(
                    bp::paths(exePerl.c_str(), BERGCGIDIR.c_str())
                    , bp::arg(scriptPex.c_str())
                    , bp::arg(inputDatabaseFile.c_str())
                    , bp::arg(texFile.c_str())
                    , bp::std_out_to(pe_log)
                    , bp::std_err_to(pe_log)
                    );
        log << "Inhalt der Protokolldatei (" << pexLogfile.c_str() << "):\n";
        int ret = c11.join(); // wait for PeX completion
        AddFileToLog(pexLogfile, log, oss);
        log << "PeX return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
        if (ret != 0) { ++errors; }

        // mv $BERGLOGDIR/pe.log $BERGDLBDIR
        log << "mv/cp " << pexLogfile.c_str() << " -&gt; " << BERGDLBDIR.c_str();
        //        fs::remove(BERGDLBDIR / pexLogfile.filename(), ec); // ignore error code
        //        fs::copy_file(pexLogfile, BERGDLBDIR / pexLogfile.filename(), ec);
        fs::rename(pexLogfile, BERGDLBDIR / pexLogfile.filename(), ec);
        CheckErrorCode(log, "mv", ec, errors);
        log << ".\n";

        // cp $BERGDBDIR/FeGinfo.tex $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        log << "cp " << texFile.c_str() << " -&gt; " << BERGDLBDIR.c_str();
        fs::remove(BERGDLBDIR / texFile.filename(), ec); // ignore error code
        log << " (remove ec: " << ec.value() << "/" << ec.message() << ")";
        fs::copy_file(texFile, BERGDLBDIR / texFile.filename(), ec);
        CheckErrorCode(log, "copy_file", ec, errors);
        log << ".\n";
    }

    {
        // cp $BERGDBDIR/*.sty  $BERGDBDIR/*.jpg $BERGOUTDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        CopyToOutDir("sectsty.sty", log);
        CopyToOutDir("wrapfig.sty", log);
        CopyToOutDir("feglogo.jpg", log);
    }

    {
        // # LaTeX-Lauf der .pdf und auch .log erzeugt (pdflatex darf keine Ausgabe erzeugen!)
        Add(log, oss, "</pre></p><h2>");
        log << "LaTeX-Lauf der .pdf und auch .log erzeugt\n";
        Add(log, oss, "</h2><p><pre class=\"pex-dev\">");
        // cd $BERGDBDIR && pdflatex -interaction=nonstopmode -file-line-error FeGinfo.tex  >/dev/null
        log << "cd " << BERGOUTDIR.c_str() << ".\n"; // this is done bp::paths(exe, working directory) below

#if defined(BOOST_WINDOWS_API)
        const wstring wsTexFileString = texFile.parent_path().c_str(); // c_str in Win is wstring
        const string texFileString(wsTexFileString.begin(), wsTexFileString.end());
#else
        const string texFileString = texFile.parent_path().c_str();
#endif
        const string outputdir = string("-output-directory=") + texFileString;
        const string texFilenameOnly = texFile.filename().c_str();
        log << exePdfLatex.c_str() << " -interaction=nonstopmode -file-line-error " << outputdir << " " << texFilenameOnly;
        log << "\n";

#if defined(WIN32)
        bio::file_descriptor_sink tex_log(texLogfile);
#else
        bio::file_descriptor_sink tex_log(texLogfile.c_str());
#endif
        bp::monitor c12 = bp::make_child(
                    bp::paths(exePdfLatex.c_str(), BERGOUTDIR.c_str())
                    , bp::arg("-interaction=nonstopmode")
                    , bp::arg("-file-line-error")
                    , bp::arg(outputdir)
                    , bp::arg(texFilenameOnly)
                    , bp::std_out_to(tex_log)
                    , bp::std_err_to(tex_log)
                    );
        log << "Inhalt der Protokolldatei (" << texLogfile.c_str() << "):\n";
        int ret = c12.join(); // wait for pdflatex completion
        AddFileToLog(texLogfile, log, oss);
        log << "pdfTeX return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
        if (ret != 0) { ++errors; }
    }

    {
        // # Bildverzeichnis erzeugen
        Add(log, oss, "</pre></p><h2>");
        log << "Bildverzeichnis erzeugen\n";
        Add(log, oss, "</h2><p><pre class=\"pex-dev\">");
        //        #cd $BERGDBDIR && if [ -f FeGinfo.idx ]; xindy FeGinfo.idx; fi 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        //        #echo "xindy calling .." >>$BERGLOGDIR/log.txt
        //        #cd $BERGDBDIR && xindy -L german-din FeGinfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        //        echo "makeindex calling .." >>$BERGLOGDIR/log.txt
        //        cd $BERGDBDIR && makeindex FeGinfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        //        cd $BERGDBDIR && which ls 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        //        cd $BERGDBDIR && which makeindex 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        if (fs::exists(idxFile) && fs::exists(exeMakeindex))
        {
            log << exeMakeindex.c_str() << " " << idxFile.c_str();
            log << "\n";

#if defined(WIN32)
            bio::file_descriptor_sink tex_log(idxLogfile);
#else
            bio::file_descriptor_sink idx_log(idxLogfile.c_str());
#endif
            bp::monitor c12 = bp::make_child(
                        bp::paths(exeMakeindex.c_str(), BERGOUTDIR.c_str())
                        , bp::arg(idxFile.c_str())
                        , bp::std_out_to(idx_log)
                        , bp::std_err_to(idx_log)
                        );
            log << "Inhalt der Protokolldatei (" << idxLogfile.c_str() << "):\n";
            int ret = c12.join(); // wait for makeindex completion
            AddFileToLog(idxLogfile, log, oss);
            log << "Makeindex return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
            if (ret != 0) { ++errors; }
        }
        else
        {
            if (!fs::exists(idxFile))
            {
                log << "Indexdatei (" << idxFile.c_str() << ") für das Bildverzeichnise existiert nicht. ";
            }
            if (!fs::exists(exeMakeindex))
            {
                log << "Makeindex (" << exeMakeindex.c_str() << ") existiert nicht. ";
            }
            log << "Bildverzeichnis wird nicht aktualisiert.\n";
        }
    }

    {
        Add(log, oss, "</pre></p><h2>");
        log << "Dateien in den Downloadbereich kopieren\n";
        Add(log, oss, "</h2><p><pre class=\"pex-dev\">");
        //        mv $BERGDBDIR/FeGinfo.log $BERGDBDIR/FeGinfo.pdf $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt - kommt als letztes
        //        cp $BERGDBDIR/feginfo.csv $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
        log << "cp " << inputDatabaseFile.c_str() << " -&gt; " << BERGDLBDIR.c_str();
        fs::remove(BERGDLBDIR / inputDatabaseFile.filename(), ec);
        CheckErrorCode(log, "remove", ec, errors);
        fs::copy_file(inputDatabaseFile, BERGDLBDIR / inputDatabaseFile.filename(), ec);
        CheckErrorCode(log, "copy_file", ec, errors);
        log << ".\n";

        log << "cp " << pdfFile.c_str() << " -&gt; " << BERGDLBDIR.c_str();
        fs::remove(BERGDLBDIR / pdfFile.filename(), ec);
        CheckErrorCode(log, "remove", ec, errors);
        fs::copy_file(pdfFile, BERGDLBDIR / pdfFile.filename(), ec);
        CheckErrorCode(log, "copy_file", ec, errors);
        log << ".\n";
    }

    //        echo "Zeitungsgenerators beendet (`date`)." >>$BERGLOGDIR/log.txt
    //        echo "Hier noch das Log von pex.pl:" >>$BERGLOGDIR/log.txt
    //        cat $BERGLOGDIR/log.txt $BERGDLBDIR/pe.log >$BERGDLBDIR/log.txt
    bchrono::system_clock::time_point stop = bchrono::system_clock::now();
    log << "Zeitungsgenerator maker beendet (" << pt::second_clock::local_time() << ") ...\n";
    log << "Bearbeitungszeit betrug " << boost::chrono::duration_cast<bchrono::milliseconds>(stop-start).count() << " ms.\n";
    log << "mv " << makerLogfile.c_str() << " -&gt; " << BERGDLBDIR.c_str();
    log.flush();
    log.close();
    resp << oss.str() << "\n\n\n";

    resp << "Bearbeitungszeit betrug " << boost::chrono::duration_cast<bchrono::milliseconds>(stop-start).count() << " ms.\n";

    fs::rename(makerLogfile, BERGDLBDIR / makerLogfile.filename(), ec);
    CheckErrorCode(resp, "", ec, errors);

    resp << "</pre></p>"
         << "<h2>Bearbeitungsergebnis</h2>";
    if (errors == 0)
    {
        resp << "<p class=\"success\">Keine Fehler.</p>";
    }
    else
    {
        resp << "<p class=\"failure\">" << errors << " Fehler! Hinweise zu den Ursachen sollten sich weiter oben finden lassen.</p>";
    }
    resp << "</body></html>";

    return cgi::commit(req, resp);
}


void AddFileToLog(fs::path const& logFile, TeeStream &log, ostringstream &oss)
{
    if (fs::exists(logFile))
    {
        fs::ifstream ifs(logFile);
        if (ifs.is_open())
        {
            Add(log, oss, "</p><p><pre class=\"pex-log\">");
            string line;
            int cnt = 0;
            while (ifs.good())
            {
                getline(ifs, line);
                ++cnt;
                //log << "Zeile " << cnt << ": ";
                log << line << "\n";
            }
            //log << "Aus Protokolldatei " << cnt << " Zeile(n) gelesen.\n";
            Add(log, oss, "</pre></p><p>");
        }
        else
        {
            log << "Bearbeitung vermutlich fehlgeschlagen, da Protokolldatei (" << logFile.c_str() << ") nicht geöffnet werden konnte!\n";
        }
    }
    else
    {
        log << "Bearbeitung vermutlich fehlgeschlagen, da Protokolldatei (" << logFile.c_str() << ") nicht existiert!\n";
    }
}

/**
  * copy the given file from DB to OUT dir.
  */
void CopyToOutDir(fs::path const& filename, TeeStream & log)
{
    if (!fs::exists(BERGDBDIR / filename))
    {
        log << "cp " << filename.c_str() << " -&gt; " << BERGOUTDIR.c_str();
        bs::error_code ec;
        fs::copy_file(filename, BERGOUTDIR / filename.filename(), ec);
        log << " (ec: " << ec.value() << "/" << ec.message() << ")";
        log << ".\n";
    }
}

/**
  * Adds the string to the HTML output stream. The Log is flushed before issued the given HTML code.
  */
void Add(TeeStream & log, ostringstream & oss, string const& html)
{
    log.flush();
    oss << html;
}

/**
  * Add Error Code to the resp and increment errors is ec is an error.
  */
void CheckErrorCode(cgi::response & resp, std::string const& functionName, bs::error_code const& ec, uint & errors)
{
    std::string errorString;
    CheckErrorCode(errorString, "", ec, errors);
    resp << errorString;
}

/**
  * Add Error Code to the log and increment errors is ec is an error.
  */
void CheckErrorCode(TeeStream & log, std::string const& functionName, bs::error_code const& ec, uint & errors)
{
    std::string errorString;
    CheckErrorCode(errorString, "", ec, errors);
    log << errorString;
}

void CheckErrorCode(std::string & errorString, std::string const& functionName, bs::error_code const& ec, uint & errors)
{
    ostringstream oss;
    oss << " (ec: " << ec.value() << "/" << ec.message() << ")";
    errorString = oss.str();
    if (0 < ec.value()) { ++errors; }
}


int main(int argc, char* argv[])
{
    return Common::InvokeWithErrorHandling(&HandleRequest);
}
