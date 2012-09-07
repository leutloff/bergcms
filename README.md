Berg
====

Berg is web based system for publishing a regular printed news letter,
e.g. a bimonthly parish newsletter. It is suitable for small editorial
committees.

The focus of the system is the next issue to publish. An issue consists
of several articles. These articles are preprocessed and then composited
by LaTeX. The outcome is a PDF file that can be downloaded and then
sent directly to the print shop.

**At the time of this writing some code is still missing. It will be added file by file in the next weeks ...**


Testsuite
=========

The testsuite is based on the Selenium IDE. Get the Firefox plugin Selenium IDE
from [http://seleniumhq.org/download/](http://seleniumhq.org/download/).
Installation is described at [http://seleniumhq.org/docs/02_selenium_ide.html](http://seleniumhq.org/docs/02_selenium_ide.html).
The testsuites and test cases are located in the folder testsuite.
Put the file www/cgi-bin/brg/testcase.pl only on testing instances.
The CGI script will copy a database according the selected test case.
This will destroy the existing database. The existence of the testcase.pl
file allows the test cases to modify the database content.


History and License
===================

The system was originally written by Heiko Decker using Perl. Work started
in 2006 and is used for production of a bimonthly parish newsletter since 2009.
Since 2011 the actual maintainer is Christian Leutloff. New modules are
written in C++.

License is [AGPL](https://www.gnu.org/licenses/agpl-3.0) for C++ Code and
[Artistic](http://www.perlfoundation.org/artistic_license_2_0)/[GPL](https://www.gnu.org/licenses/gpl-3.0)
for the Perl Code. Each file will state explicitly the license it belongs to.
Copies of the Licenses are found in the LICENSES folder.


Coding Guidelines
=================

- Indentation must use spaces only. Do not use tabs for this purpose.
- Character encoding must be UTF-8 in every place.
- Line ending should be Unix style (LF only).


Feedback
========

Feedback is welcome. Patches and pull requests are even more welcome.


