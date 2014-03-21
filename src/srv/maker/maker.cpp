/**
 * @file maker.cpp
 * Extracts the actual articles and generates the PDF.
 * 
 * Copyright 2012, 2013, 2014 Christian Leutloff <leutloff@sundancer.oche.de>
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
 * But improved since then, e.g. added makeindex calls.
 */

#include "Common.h"
#include "DirectoryLayout.h"
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
#include <stdlib.h>

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
void CopyToOutDir(fs::path const& bergOutDir, fs::path const& filename, TeeStream & log);
void Add(TeeStream & log, ostringstream & oss, string const& html);
void CheckErrorCode(cgi::response & resp, std::string const& functionName, bs::error_code const& ec, uint & errors);
void CheckErrorCode(TeeStream & log, std::string const& functionName, bs::error_code const& ec, uint & errors);
void CheckErrorCode(std::string & errorString, std::string const& functionName, bs::error_code const& ec, uint & errors);

int HandleRequest(boost::cgi::request& req)
{
    bchrono::system_clock::time_point start = bchrono::system_clock::now();
    bchrono::system_clock::time_point stop = start;
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

    // Path definitions
    // /home/aachen/cgi-bin/brg/br
    const fs::path BERGDBDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "br");
    // /home/aachen/cgi-bin/brg/log
    const fs::path BERGLOGDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "log");
    const fs::path BERGOUTDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "out"); // processing output
    //const fs::path BERGDLBDIR("/home/aachen/htdocs/dlb");

    const fs::path makerLogfile      = fs::path(BERGLOGDIR / "log.txt");

    const fs::path pexLogfile        = fs::path(BERGLOGDIR / "pe.log");
    const fs::path texLogfile        = fs::path(BERGLOGDIR / "pdflatex.log");
    const fs::path idxLogfile        = fs::path(BERGLOGDIR / "makeindex.log");

    const fs::path inputDatabaseFile = fs::path(BERGDBDIR  / "feginfo.csv");
    const fs::path texFile           = fs::path(BERGOUTDIR / "feginfo.tex");
    const fs::path idxFile           = fs::path(             "feginfo.idx");
    const fs::path pdfFile           = fs::path(BERGOUTDIR / "feginfo.pdf");

    const fs::path exePerl           = fs::path("/usr/bin/perl");
    const fs::path exePdfLatex       = fs::path("/usr/bin/pdflatex");
    const fs::path exeMakeindex      = fs::path("/usr/bin/makeindex");
    const fs::path scriptPex         = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "pex.pl");

    try
    {
        resp << "\n<p><pre class=\"berg-dev\">\n";
        resp << "Programmname: " << DirectoryLayout::Instance().GetProgramName() << ".\n";
        if (fs::exists(DirectoryLayout::Instance().GetCgiBinDir()))
        {
            resp << "cgi-bin Verzeichnis: " << DirectoryLayout::Instance().GetCgiBinDir() << ".\n";
        }
        else
        {
            resp << "cgi-bin Verzeichnis " << DirectoryLayout::Instance().GetCgiBinDir() << " existiert nicht.\n";
            ++errors;
        }
        //  mkdir -p $BERGLOGDIR;
        if (!fs::exists(BERGLOGDIR))
        {
            resp << "Log Verzeichnis " << BERGLOGDIR << " anlegen...";
            fs::create_directory(BERGLOGDIR, ec);
            CheckErrorCode(resp, "", ec, errors);
        }
        else
        {
            resp << "Log Verzeichnis " << BERGLOGDIR << " existiert.\n";
        }
        if (!fs::exists(BERGOUTDIR))
        {
            resp << "Ausgabeverzeichnis " << BERGOUTDIR << " anlegen...";
            fs::create_directory(BERGOUTDIR, ec);
            CheckErrorCode(resp, "", ec, errors);
        }
        else
        {
            resp << "Ausgabeverzeichnis " << BERGOUTDIR << " existiert.\n";
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
            pt::time_facet *facet = new pt::time_facet("%d.%m.%Y %H:%M:%S");
            log.imbue(locale(log.getloc(), facet));
            log << "Start des Zeitungsgenerators maker (" << pt::second_clock::local_time() << ") im Verzeichnis " << fs::current_path() << "...\n";
//            log << "pwd: " << fs::current_path(ec);
//            log << " (ec: " << ec.value() << "/" << ec.message() << ")";
//            log << ".\n";
            Add(log, oss, "</p>\n");
        }

        {
            // # Die CSV-Datenbank nach feginfo.tex transformieren
            Add(log, oss, "<h3>");
            log << "Artikel aus der Datenbank holen\n";
            Add(log, oss, "</h3><pre class=\"berg-dev\">");
            fs::remove(pexLogfile, ec);
            log << "Protokolldatei (" << pexLogfile.c_str() << ") " << (ec ? "gelöscht" : "nicht gelöscht") << ".\n";
            log << "Lese Artikel aus der Datenbank (" << inputDatabaseFile.c_str() << "),\n";
            log << "verwende dazu Perl-Script PeX (" << scriptPex.c_str() << ") ...\n";

            // perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
#if defined(WIN32)
            bio::file_descriptor_sink pe_log(pexLogfile);
#else
            bio::file_descriptor_sink pe_log(pexLogfile.c_str());
#endif
            bp::monitor c11 = bp::make_child(
                        bp::paths(exePerl.c_str(), DirectoryLayout::Instance().GetCgiBinDir().c_str())
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
            log << "mv/cp " << pexLogfile.c_str() << " -&gt; " << DirectoryLayout::Instance().GetHtdocsDownloadDir().c_str();
            //        fs::remove(BERGDLBDIR / pexLogfile.filename(), ec); // ignore error code
            //        fs::copy_file(pexLogfile, BERGDLBDIR / pexLogfile.filename(), ec);
            fs::rename(pexLogfile, DirectoryLayout::Instance().GetHtdocsDownloadDir() / pexLogfile.filename(), ec);
            CheckErrorCode(log, "mv", ec, errors);
            log << ".\n";

            // cp $BERGDBDIR/feginfo.tex $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            log << "cp " << texFile.c_str() << " -&gt; " << DirectoryLayout::Instance().GetHtdocsDownloadDir().c_str();
            fs::remove(DirectoryLayout::Instance().GetHtdocsDownloadDir() / texFile.filename(), ec); // ignore error code
            log << " (remove ec: " << ec.value() << "/" << ec.message() << ")";
            fs::copy_file(texFile, DirectoryLayout::Instance().GetHtdocsDownloadDir() / texFile.filename(), ec);
            CheckErrorCode(log, "copy_file", ec, errors);
            log << ".\n";
            Add(log, oss, "</pre></p>\n");
        }

// this is no longer needed - TEXINPUTS is set appropriate below
//        {
//            // cp $BERGDBDIR/*.sty  $BERGDBDIR/*.jpg $BERGOUTDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
//            CopyToOutDir(BERGOUTDIR, BERGDBDIR / "sectsty.sty", log);
//            CopyToOutDir(BERGOUTDIR, BERGDBDIR / "wrapfig.sty", log);
//            CopyToOutDir(BERGOUTDIR, BERGDBDIR / "feglogo.jpg", log);
//        }

        {
            // # LaTeX-Lauf der .pdf und auch .log erzeugt (pdflatex darf keine Ausgabe erzeugen!)
            Add(log, oss, "<h2>");
            log << "PDF-Datei erzeugen\n";
            Add(log, oss, "</h2>");
            if (fs::exists(exePdfLatex))
            {
                Add(log, oss, "<p><pre class=\"berg-dev\">");
                // cd $BERGDBDIR && pdflatex -interaction=nonstopmode -file-line-error feginfo.tex  >/dev/null
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
                            , bp::environment("TEXINPUTS",
                                              ".//:../br//:/usr/share/texmf-texlive/tex/latex//:/usr/share/texlive/texmf-dist/tex/latex//"
                                              ":/usr/share/texmf-texlive/tex/generic//:/usr/share/texlive/texmf-dist/tex/generic//"
                                              ":/etc/texmf/tex//:/usr/share/texmf//")
                            , bp::std_out_to(tex_log)
                            , bp::std_err_to(tex_log)
                            );
                log << "Inhalt der Protokolldatei (" << texLogfile.c_str() << "):\n";
                int ret = c12.join(); // wait for pdflatex completion
                AddFileToLog(texLogfile, log, oss);
                log << "pdfTeX return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
                if (ret != 0) { ++errors; }
                Add(log, oss, "</pre>");
            }
            else
            {
                Add(log, oss, "<p class=\"berg-failure\"");
                log << "PDFLaTeX (" << exePdfLatex.c_str() << ") existiert nicht. PDF kann deswegen nicht erzeugt werden.";
                ++errors;
            }
            Add(log, oss, "</p>\n");
        }

        {
            // # Bildverzeichnis erzeugen
            Add(log, oss, "<h2>");
            log << "Bildverzeichnis für den nächsten Durchlauf erzeugen\n";
            Add(log, oss, "</h2>");
            //        #cd $BERGDBDIR && if [ -f feginfo.idx ]; xindy feginfo.idx; fi 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            //        #echo "xindy calling .." >>$BERGLOGDIR/log.txt
            //        #cd $BERGDBDIR && xindy -L german-din feginfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            //        echo "makeindex calling .." >>$BERGLOGDIR/log.txt
            //        cd $BERGDBDIR && makeindex feginfo.idx 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            //        cd $BERGDBDIR && which ls 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            //        cd $BERGDBDIR && which makeindex 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            if (fs::exists(BERGOUTDIR / idxFile) && fs::exists(exeMakeindex))
            {
                Add(log, oss, "<p><pre class=\"berg-dev\">");
                log << "cd " << BERGOUTDIR.c_str() << ".\n"; // this is done bp::paths(exe, working directory) below
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
                Add(log, oss, "</pre>");
            }
            else
            {
                Add(log, oss, "<p class=\"berg-failure\"");
                if (!fs::exists(BERGOUTDIR / idxFile))
                {
                    log << "Indexdatei (" << idxFile.c_str() << ") für das Bildverzeichnis existiert nicht. ";
                    ++errors;
                }
                if (!fs::exists(exeMakeindex))
                {
                    log << "Makeindex (" << exeMakeindex.c_str() << ") existiert nicht. ";
                    ++errors;
                }
                log << "Bildverzeichnis wird nicht aktualisiert.\n";
            }
            Add(log, oss, "</p>\n");
        }

        {
            Add(log, oss, "<h2>");
            log << "Dateien in den Downloadbereich kopieren\n";
            Add(log, oss, "</h2><p><pre class=\"berg-dev\">");
            //        mv $BERGDBDIR/feginfo.log $BERGDBDIR/feginfo.pdf $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt - kommt als letztes
            //        cp $BERGDBDIR/feginfo.csv $BERGDLBDIR 1>>$BERGLOGDIR/log.txt 2>>$BERGLOGDIR/log.txt
            log << "cp " << inputDatabaseFile.c_str() << " -&gt; " << DirectoryLayout::Instance().GetHtdocsDownloadDir().c_str();
            fs::remove(DirectoryLayout::Instance().GetHtdocsDownloadDir() / inputDatabaseFile.filename(), ec);
            CheckErrorCode(log, "remove", ec, errors);
            fs::copy_file(inputDatabaseFile, DirectoryLayout::Instance().GetHtdocsDownloadDir() / inputDatabaseFile.filename(), ec);
            CheckErrorCode(log, "copy_file", ec, errors);
            log << ".\n";

            log << "cp " << pdfFile.c_str() << " -&gt; " << DirectoryLayout::Instance().GetHtdocsDownloadDir().c_str();
            fs::remove(DirectoryLayout::Instance().GetHtdocsDownloadDir() / pdfFile.filename(), ec);
            CheckErrorCode(log, "remove", ec, errors);
            fs::copy_file(pdfFile, DirectoryLayout::Instance().GetHtdocsDownloadDir() / pdfFile.filename(), ec);
            CheckErrorCode(log, "copy_file", ec, errors);
            log << ".\n";
            Add(log, oss, "</pre></p>\n");
        }

        {
            //        echo "Zeitungsgenerators beendet (`date`)." >>$BERGLOGDIR/log.txt
            //        echo "Hier noch das Log von pex.pl:" >>$BERGLOGDIR/log.txt
            //        cat $BERGLOGDIR/log.txt $BERGDLBDIR/pe.log >$BERGDLBDIR/log.txt
            Add(log, oss, "<p><pre class=\"berg-dev\">");
            log << "Zeitungsgenerator maker beendet (" << pt::second_clock::local_time() << ") ...\n";
            log << "mv " << makerLogfile.c_str() << " -&gt; " << DirectoryLayout::Instance().GetHtdocsDownloadDir().c_str();
            log.flush();
            log.close();
            resp << oss.str();
            fs::rename(makerLogfile, DirectoryLayout::Instance().GetHtdocsDownloadDir() / makerLogfile.filename(), ec);
            CheckErrorCode(resp, "", ec, errors);
            resp << "</pre></p>\n";
            stop = bchrono::system_clock::now();
        }
    }
    catch(std::exception const& ex)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Fehler: " << ex.what() << "</p>";
    }
    catch(std::string const& ex)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Interner Fehler: " << ex << "</p>";
    }
    catch(...)
    {
        ++errors;
        resp << "<p class=\"berg-failure\">Fehler: Exception.</p>";
    }


    resp << "<h2>Bearbeitungsergebnis</h2>";
    resp << "<p class=\"berg-dev\">Bearbeitungszeit betrug " << boost::chrono::duration_cast<bchrono::milliseconds>(stop-start).count() << " ms.</p>\n";
    if (errors == 0)
    {
        resp << "<p id=\"processing-result\" class=\"berg-success\">Keine Fehler.</p>";
    }
    else
    {
        resp << "<p id=\"processing-result\" class=\"berg-failure\">" << errors << " Fehler! Hinweise zu den Ursachen sollten sich weiter oben finden lassen.</p>";
    }
    resp << "<p>Einige Download-Links:</p>"
            << "<p><a href=\"/dlb/feginfo.pdf\">PDF des Gemeindebriefs</a>,<br />"
            << "<a href=\"/dlb/feginfo.tex\">LaTeX-Datei</a>,<br />"
            << "<a href=\"/dlb/feginfo.csv\">die CSV-Datenbank</a></p>";
    resp << "\n</body></html>\n";

    return cgi::commit(req, resp);
}


void AddFileToLog(fs::path const& logFile, TeeStream &log, ostringstream &oss)
{
    if (fs::exists(logFile))
    {
        fs::ifstream ifs(logFile);
        if (ifs.is_open())
        {
            Add(log, oss, "</p><p><pre class=\"berg-log\">");
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
void CopyToOutDir(fs::path const& bergOutDir, fs::path const& filename, TeeStream & log)
{
    const fs::path target = bergOutDir / filename.filename();
    if (!fs::exists(target))
    {
        log << "cp " << filename.c_str() << " -&gt; " << target.c_str();
        bs::error_code ec;
        fs::copy_file(filename, target, ec);
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
    if (0 < ec.value()) { ++errors; }
    oss << " (ec: " << ec.value() << "/" << ec.message() << ")";
    errorString = oss.str();
}


int main(int argc, char* argv[])
{
    if (0 < argc) { DirectoryLayout::MutableInstance().SetProgramName(argv[0]); }
    return Common::InvokeWithErrorHandling(&HandleRequest);
}

