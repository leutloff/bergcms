/**
 * @file maker.cpp
 * Extracts the actual articles and generates the PDF.
 *
 * Copyright 2012, 2013, 2014, 2016, 2018 Christian Leutloff <leutloff@sundancer.oche.de>
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
#include <boost/cgi/cgi.hpp>
#include <boost/chrono.hpp>
#include <boost/foreach.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/fusion/container/vector/vector.hpp>
#include <boost/fusion/container/generation/make_vector.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/iostreams/tee.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/process.hpp>
#include <boost/locale.hpp>
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
void AddFileToLog(fs::path const& logFile, TeeStream &log, ostringstream &oss, std::string fileEncoding);
void CopyToOutDir(fs::path const& bergOutDir, fs::path const& filename, TeeStream & log);
void Add(TeeStream & log, ostringstream & oss, string const& html);
void AddHeading(TeeStream & log, ostringstream & oss, int level, string const& title);
void CheckErrorCode(cgi::response & resp, std::string const& functionName, bs::error_code const& ec, int & errors);
void CheckErrorCode(TeeStream & log, std::string const& functionName, bs::error_code const& ec, int & errors);
void CheckErrorCode(std::string & errorString, std::string const& functionName, bs::error_code const& ec, int & errors);

int HandleRequest(boost::cgi::request& req)
{
    bchrono::system_clock::time_point start = bchrono::system_clock::now();
    bchrono::system_clock::time_point stop = start;
    int errors = 0;

    req.load(cgi::parse_get); // Read and parse STDIN data - GET only plus ENV.
    cgi::response resp;
    bs::error_code ec;
    resp << cgi::content_type("text/html") << cgi::charset("utf-8");

    resp << "<!DOCTYPE html>\n" // HTML5
         << "<html><head>\n"
         << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/brg/css/bgcrud.css\" />\n"
         << "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
         << "<title>Generator (maker) - Berg CMS</title>\n";
    resp << "</head><body>";

    // Path definitions
    // /home/bergcms/cgi-bin/brg/br
    const fs::path BERGDBDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "br");
    // /home/bergcms/cgi-bin/brg/log
    const fs::path BERGLOGDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "log");
    const fs::path BERGOUTDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "out"); // processing output
    const fs::path BERGFONTDIR = fs::path(DirectoryLayout::Instance().GetCgiBinDir() / "out" / ".texmf-var");
    //const fs::path BERGDLBDIR("/home/bergcms/htdocs/dlb");
    const string texinputs =  string(".//:../br//:/usr/share/texmf-texlive/tex/latex//:/usr/share/texlive/texmf-dist/tex/latex//"
                                     ":/usr/share/texmf-texlive/tex/generic//:/usr/share/texlive/texmf-dist/tex/generic//"
                                     ":/etc/texmf/tex//:/usr/share/texmf//:/usr/local/share/texmf//:") + BERGFONTDIR.c_str();

    const fs::path makerLogfile      = fs::path(BERGLOGDIR / "log.txt");

    const fs::path pexLogfile        = fs::path(BERGLOGDIR / "pe.log");
    const fs::path texLogfile        = fs::path(BERGLOGDIR / "pdflatex.log");
    const fs::path idxLogfile        = fs::path(BERGLOGDIR / "makeindex.log");

    const fs::path inputDatabaseFile = fs::path(BERGDBDIR  / "feginfo.csv");
    const fs::path texFile           = fs::path(BERGOUTDIR / "feginfo.tex");
    const fs::path idxFile           = fs::path(             "feginfo.idx");
    const fs::path pdfFile           = fs::path(BERGOUTDIR / "feginfo.pdf");

    const fs::path exePerl           = fs::path("/usr/bin/perl");
    //const fs::path exePdfLatex       = fs::path("/usr/bin/lualatex");
    const fs::path exePdfLatex       = fs::path("/usr/bin/pdflatex");
    const fs::path exeMakeindex      = fs::path("/usr/bin/makeindex");
    const fs::path exeMktexpk        = fs::path("/usr/bin/mktexpk");
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
            CheckErrorCode(resp, "create_directory", ec, errors);
        }
        else
        {
            resp << "Log Verzeichnis " << BERGLOGDIR << " existiert.\n";
        }
        if (!fs::exists(BERGOUTDIR))
        {
            resp << "Ausgabeverzeichnis " << BERGOUTDIR << " anlegen...";
            fs::create_directory(BERGOUTDIR, ec);
            CheckErrorCode(resp, "create_directory", ec, errors);
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
            ostringstream o;
            o << "Generator (maker " << Common::GetBergVersion() << " " << Common::GetBergLastChangedDate() << ")";
            AddHeading(log, oss, 1, o.str());
            Add(log, oss, "<p>");
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
            AddHeading(log, oss, 2, "Artikel aus der Datenbank holen");
            Add(log, oss, "<p><pre class=\"berg-dev\">");
            fs::remove(pexLogfile, ec);
            log << "Protokolldatei (" << pexLogfile.c_str() << ") " << (ec ? "gelöscht" : "nicht gelöscht") << ".\n";
            log << "Lese Artikel aus der Datenbank (" << inputDatabaseFile.c_str() << "),\n";
            log << "verwende dazu Perl-Script PeX (" << scriptPex.c_str() << ") ...\n";

            // perl pex.pl $BERGDBDIR/feginfo.csv $BERGDBDIR/feginfo 1>>$BERGLOGDIR/pe.log 2>>$BERGLOGDIR/pe.log
            bp::child c11(
                        exePerl
                        , scriptPex
                        , inputDatabaseFile
                        , texFile
                        , bp::std_out > pexLogfile
                        , bp::std_err > pexLogfile
                        , bp::start_dir = DirectoryLayout::Instance().GetCgiBinDir()
                        );
            log << "Inhalt der Protokolldatei (" << pexLogfile.c_str() << "):\n";
            c11.wait(); // wait for PeX completion
            int ret = c11.exit_code();
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

        {
            // id
            AddHeading(log, oss, 2, "id");
            Add(log, oss, "<p><pre class=\"berg-dev\">");
            const fs::path idLogfile = fs::path(BERGLOGDIR / "id.log");
            bp::child c12(
                        bp::search_path("id")
                        , bp::std_out > idLogfile
                        , bp::std_err > idLogfile
                    );
            log << "Inhalt der Protokolldatei (" << idLogfile.c_str() << "):\n";
            //c12.wait(); // wait for id completion
            int ret = c12.exit_code();
            AddFileToLog(idLogfile, log, oss);
            log << "id return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
            if (ret != 0) { ++errors; }
            Add(log, oss, "</pre>");

            Add(log, oss, "</p>\n");
        }

        {
            AddHeading(log, oss, 2, "Fonts erzeugen");
            if (fs::exists(exeMktexpk))
            {
                const fs::path ECFONTDIR = fs::path(BERGFONTDIR / "fonts" / "pk" / "ljfour" / "jknappen" / "ec");
                const string pkdestdir = string("--destdir=") + ECFONTDIR.c_str();
                const string fontNames[] = {"ecss1200", "ecss1440", "ecsx1440", "ecsi1440", "ecss1728", "ecsx1728", "ecsx2074", "ecsx2488"};
                const fs::path texpkLogfile = fs::path(BERGLOGDIR / "texpk.log");
                for (auto fontName : fontNames)
                {
                    // create required font: mktexpk --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 ecsi1440
                    // ./.texmf-var/fonts/pk/ljfour/jknappen/ec/ecsi1440.600pk
                    // create required font: mktexpk --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 ecsx2074
                    // /.texmf-var/fonts/pk/ljfour/jknappen/ec/ecsx2074.600pk
                    if (!fs::exists(ECFONTDIR / fs::path(fontName + string(".600pk"))))
                    {
                        Add(log, oss, "<p><pre class=\"berg-dev\">");
                        //const string fontName = "ecsi1440";
                        log << exeMktexpk.c_str() << " --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 " << fontName << "\n";
                        bp::child c12(
                                    exeMktexpk
                                    , "--mfmode /"
                                    , "--bdpi 600"
                                    , "--mag 1+0/600"
                                    , "--dpi=600"
                                    , pkdestdir
                                    , fontName
                                    , bp::env["TEXINPUTS"]= texinputs
                                              , bp::std_out > texpkLogfile
                                              , bp::std_err > texpkLogfile
                                    , bp::start_dir=BERGOUTDIR
                                );
                        log << "Inhalt der Protokolldatei (" << texLogfile.c_str() << "):\n";
                        c12.wait(); // wait for mktexpk completion
                        int ret = c12.exit_code();
                        AddFileToLog(texLogfile, log, oss, "Latin1");
                        log << "mktexpk return code: " <<  ret << " - " << (ret == 0 ? "ok." : "Fehler!") << "\n";
                        if (ret != 0) { ++errors; }
                        Add(log, oss, "</pre></p>");
                    }
                }
            }
            else
            {
                Add(log, oss, "<p class=\"berg-failure\"");
                log << "mktexpk (" << exeMktexpk.c_str() << ") existiert nicht. Font kann deswegen nicht erzeugt werden.";
                ++errors;
                Add(log, oss, "</p>\n");
            }
        }

        {
            // # LaTeX-Lauf der .pdf und auch .log erzeugt (pdflatex darf keine Ausgabe erzeugen!)
            AddHeading(log, oss, 2, "PDF-Datei erzeugen");
            if (fs::exists(exePdfLatex))
            {
                Add(log, oss, "<p><pre class=\"berg-dev\">");
                // cd $BERGDBDIR && pdflatex -interaction=nonstopmode -file-line-error feginfo.tex  >/dev/null
                log << "cd " << BERGOUTDIR.c_str() << ".\n"; // this is done through start_dir below

#if defined(BOOST_WINDOWS_API)
                const wstring wsTexFileString = texFile.parent_path().c_str(); // c_str in Win is wstring
                const string texFileString(wsTexFileString.begin(), wsTexFileString.end());
                const wstring wsFilenameOnly = texFile.filename().c_str();
                const string texFilenameOnly(wsFilenameOnly.begin(), wsFilenameOnly.end());
#else
                const string texFileString = texFile.parent_path().c_str();
                const string texFilenameOnly = texFile.filename().c_str();
#endif
                const string outputdir = string("-output-directory=") + texFileString;
                log << exePdfLatex.c_str() << " -interaction=nonstopmode -file-line-error " << outputdir << " " << texFilenameOnly;
                log << "\n";

                bp::child c12(
                            exePdfLatex
                            , "-interaction=nonstopmode"
                            , "-file-line-error"
                            , outputdir
                            , texFilenameOnly
                            , bp::env["TEXINPUTS"] = texinputs
                            , bp::std_out > texLogfile
                            , bp::std_err > texLogfile
                            , bp::start_dir=BERGOUTDIR
                        );
                log << "Inhalt der Protokolldatei (" << texLogfile.c_str() << "):\n";
                c12.wait(); // wait for pdflatex completion
                int ret = c12.exit_code();
                AddFileToLog(texLogfile, log, oss, "Latin1");
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
            AddHeading(log, oss, 2, "Bildverzeichnis für den nächsten Durchlauf erzeugen");
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
                log << "cd " << BERGOUTDIR.c_str() << ".\n"; // this is done using start_dir below
                log << exeMakeindex.c_str() << " " << idxFile.c_str() << "\n";

                bp::child c12(
                            exeMakeindex
                            , idxFile
                            , bp::std_out > idxLogfile
                            , bp::std_err > idxLogfile
                            , bp::start_dir=BERGOUTDIR
                        );
                log << "Inhalt der Protokolldatei (" << idxLogfile.c_str() << "):\n";
                c12.wait(); // wait for makeindex completion
                int ret = c12.exit_code();
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
            CheckErrorCode(resp, "rename", ec, errors);
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
                oss << line << "\n";
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

void AddFileToLog(fs::path const& logFile, TeeStream &log, ostringstream &oss, std::string fileEncoding)
{
    if (fs::exists(logFile))
    {
        fs::ifstream ifs(logFile);
        if (ifs.is_open())
        {
            Add(log, oss, "</p><p><pre class=\"berg-log\">[" + fileEncoding + "]");
            string otherenc_line;
            string utf8_line;
            int cnt = 0;
            while (ifs.good())
            {
                getline(ifs, otherenc_line);
                ++cnt;
                utf8_line = boost::locale::conv::to_utf<char>(otherenc_line, fileEncoding);
                //log << "Zeile " << cnt << ": ";
                log << utf8_line << "\n";
                 oss << utf8_line << "\n";
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
  * Copy the given file from DB to OUT dir.
  */
void CopyToOutDir(fs::path const& bergOutDir, fs::path const& filename, TeeStream & log)
{
    auto target = bergOutDir / filename.filename();
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
  * Adds the title as heading with level to the HTML output stream. The Log is flushed before issued the given HTML code.
  * The title is written to the log, too.
  */
void AddHeading(TeeStream & log, ostringstream & oss, int level, string const& title)
{
    log.flush();
    log << "\n\n" << title << "\n";
    oss << "\n<h" << level << ">" << title << "</h" << level << ">\n";
}

/**
  * Add Error Code to the resp and increment errors if ec is an error.
  */
void CheckErrorCode(cgi::response & resp, std::string const& functionName, bs::error_code const& ec, int & errors)
{
    std::string errorString;
    CheckErrorCode(errorString, functionName, ec, errors);
    resp << errorString;
}

/**
  * Add Error Code to the log and increment errors if ec is an error.
  */
void CheckErrorCode(TeeStream & log, std::string const& functionName, bs::error_code const& ec, int & errors)
{
    std::string errorString;
    CheckErrorCode(errorString, functionName, ec, errors);
    log << errorString;
}

/**
  * Add Error Code to the log and increment errors if ec is an error.
  * This is the backing for other functions with the same name.
  */
void CheckErrorCode(std::string & errorString, std::string const& functionName, bs::error_code const& ec, int & errors)
{
    ostringstream oss;
    if (0 < ec.value()) { ++errors; }
    oss << " (" << functionName << ", ec: " << ec.value() << "/" << ec.message() << ")";
    errorString = oss.str();
}

/**
 * @brief main Generates the PDF and returns a HTML-Page with the processing details.
 * @param argc
 * @param argv - can be used to provide the working directory during debugging.
 * @return HTTP status code
 */
int main(int argc, char* argv[])
{
    // For Debugging provide the directory www/cgi-bin/brg/ as command line parameter.
    if (1 < argc) { DirectoryLayout::MutableInstance().SetWorkingDirectory(argv[0], argv[1]); }
    else if (0 < argc) { DirectoryLayout::MutableInstance().SetProgramName(argv[0]); }
    return Common::InvokeWithErrorHandling(&HandleRequest);
}
