%%
%% This is file `berg.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% berg.dtx  (with options: `cls')
%% 
%% Copyright 2012 by Christian Leutloff <leutloff@sundancer.oche.de>
%% 
%% This file was generated from file(s) of the Berg CMS.
%% 
%% It may be distributed under the conditions of the
%% LaTeX Project Public License in the version distributed together
%% with the Berg CMS, see file `lppl.txt'.
%% 
%%% From: berg.dtx
%% \StopEventually{\PrintIndex\PrintChanges}
\NeedsTeXFormat{LaTeX2e}[2009/09/24]
\ProvidesClass{berg}[2013/01/18 v3.0d Berg CMS document class]
\RequirePackage{ifthen}
\RequirePackage[utf8x]{inputenx}
\DeclareOption{draft}{\PassOptionsToClass{draft}{article}}
\DeclareOption{final}{\PassOptionsToClass{final}{article}}
\DeclareOption{a4paper}{\PassOptionsToClass{a4paper}{article}}
\DeclareOption{twoside}{\PassOptionsToClass{twoside}{article}}
\DeclareOption{10pt}{\PassOptionsToClass{10pt}{article}}
\DeclareOption{11pt}{\PassOptionsToClass{11pt}{article}}
\DeclareOption{12pt}{\PassOptionsToClass{12pt}{article}}
\DeclareOption*{%
    \PassOptionsToClass{\CurrentOption}{article}
}
\DeclareOption{ngerman}{%
    \PrerenderUnicode{ä}
    \PrerenderUnicode{ö}
    \PrerenderUnicode{ü}
}
\ExecuteOptions{final,a4paper,12pt,twoside,ngerman}
\ProcessOptions \relax
\LoadClass{article}[2007/10/19]
\RequirePackage[ngerman]{babel}

\RequirePackage{multicol}
\RequirePackage{sectsty}
\RequirePackage{graphicx}
\RequirePackage{wrapfig}
\RequirePackage{calc}
\RequirePackage{makeidx}
\RequirePackage{tabularx}
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\RequirePackage{array}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{pifont}
\RequirePackage[right]{eurosym}
\RequirePackage{mdwlist}
\RequirePackage[hyphens]{url}
\RequirePackage[breaklinks]{hyperref}
\urlstyle{same}%

\providecommand\PeX{%
  P\kern-.2em\lower.7ex\hbox{e}\kern-.06em\raise .3ex\hbox{r}%
  \LaTeX}
\providecommand\Berg{%
  B\kern-.2em\raise.9ex\hbox{e}\kern-.06em\raise.3ex\hbox{r}\kern-.2em\hbox{g} CMS%
}
\providecommand\BergUrl{%
  \url{https://github.com/leutloff/berg}%
}
\providecommand\BergMajorVersion{%
  v3%
}

\setlength{\hoffset}{-15mm}%.......Korrektur des Druckbereichs horizontal
\setlength{\voffset}{-30mm}% ......Korrektur des Druckbereichs vertikal
\setlength{\textwidth}{190mm}%.....TextboxBreite(A4=210)
\setlength{\textheight}{265mm}%....TextboxHöhe(A4=297)
\setlength{\columnsep}{7mm}%.......SpaltenZwischenraum
\setlength{\columnseprule}{0.2pt}%.Spaltentrennlinie
\setlength{\oddsidemargin}{0mm}%...linker Rand ungerade(rechte) Seiten
\setlength{\evensidemargin}{0mm}%..linker Rand gerade(linke) Seiten
\setlength{\footskip}{8mm}%........Abstand: unterer Textbox - Seitenrand
\setlength{\extrarowheight}{3pt}
\setcounter{secnumdepth}{-2}
\setcounter{tocdepth}{2}
\pagestyle{plain}
\renewcommand{\familydefault}{\sfdefault}
\normalfont
\sectionfont{\LARGE\bfseries}
\subsectionfont{\Large\bfseries}
\subsubsectionfont{\large\bfseries}
\setlength{\emergencystretch}{4em}
\setlength{\parindent}{0mm}
\setlength{\parskip}{1.0ex plus 0.8ex minus 0.5ex}
\renewenvironment{quote}{%
  \list{}{%
    \setlength{\leftmargin}{6mm}
    \rightmargin\leftmargin
  }
  \itshape
  \item\relax
}
{\endlist}
\newcounter{bergpicturecreditspage}%
\renewenvironment{theindex}
{%
    \setlength\parindent{0pt}%
    \let\item\@idxitem
}%
{ }%
\makeindex
\providecommand\BergPrintPictureCredits{%
    \hypertarget{bergpicturecreditslabel}{}
    \section*{Bildnachweis}%
    \setcounter{bergpicturecreditspage}{\thepage}%
    %\renewcommand\indexspace{\par\vskip 10pt \plus 5pt \minus 3pt \relax}
    \printindex
}
\providecommand\BergAddPictureCreditsTocEntry{%
   \addtocontents{toc}{\protect\contentsline{section}{Bildnachweis}{\thebergpicturecreditspage}{bergpicturecreditslabel}}
}

\endinput
%%
%% End of file `berg.cls'.
