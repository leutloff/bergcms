Berg CMS
========

Berg Content Management System is a web based CMS for publishing a regular
printed news letter, e.g. a bimonthly parish newsletter. It is suitable
for small editorial committees.

The focus of the system is the next issue to publish. An issue consists
of several articles. These articles are preprocessed and then composited
by LaTeX. The outcome is a PDF file that can be downloaded and then
sent directly to the print shop.


Building from Source
====================

- Clone or download the repository.
- Execute the script update_and_build_submodules.sh to initialize, update and
  build the submodules.
- Download the Boost C++ Library from http://www.boost.org/users/download/
  (start with version 1.48, when unsure);
  Extract and build boost library in src/external.
- Add your libicu to src/external/libicuNN. If used other than the mentioned
  in shared_config.cmake, add your version, too. Supported out of the box
  are at least libicu48, libicu44 and libicu38.
- Launch CMake and point the source code the src directory and
  build the project.
- Run the script make_zip.sh. This will build all applications and put all
  the required files in a single ZIP file.
- Install the content of the ZIP file on the Web Server. An outline of the
  Apache configuration is shown in doc/etc_apache2. Use the script install_locally.sh
  to perform this step together with some tweaks with regard the file permissions.
  The used install path can be adapted to local differences by overriding
  shell variables in a file named install_locally.cfg.


Testsuite and Unit Tests
========================

The testsuite for the user interface is based on the Selenium IDE.
Get the Firefox plugin Selenium IDE
from [http://seleniumhq.org/download/](http://seleniumhq.org/download/).
Installation is described at
[http://seleniumhq.org/docs/02_selenium_ide.html](http://seleniumhq.org/docs/02_selenium_ide.html).

The testsuites and test cases are located in the folder testsuite.
Put the file www/cgi-bin/brg/testcase.pl only on testing instances.
The CGI script will copy a database according the selected test case.
This will destroy the existing database. The existence of the testcase.pl
file allows the test cases to modify the database content.

Additional to the GUI test the different parts of the system are tested with
different types of unit tests. You will find unit tests written in C++ and
Perl. New unit tests should be written in C++ when feasible.

The unit tests for the C++-Code is located in src/test. Execute the project
named test to execute the C++ test cases. These test cases are based on
boost unit test.

The Perl related unit tests are located in www/cgi-bin/brg/t. Use the script
www/cgi-bin/brg/t/run_tests.sh to exucute all the Perl based tests.


History and License
===================

The system was originally written by Heiko Decker using Perl. Work started
in 2006 and is used for production of a bimonthly parish newsletter since 2009.
Since 2011 the actual maintainer is Christian Leutloff. New modules are
written in C++.

License is [AGPL](https://www.gnu.org/licenses/agpl-3.0) for C++ Code and
[Artistic](http://www.perlfoundation.org/artistic_license_2_0)/[GPL](https://www.gnu.org/licenses/gpl-3.0)
for the Perl Code.
LaTeX related files are licensed using the [LaTeX Project Public License](http://www.latex-project.org/lppl/lppl-1-3c.html).
Javascript Code can be used under the terms of the [MIT License](https://en.wikipedia.org/wiki/MIT_License).

Each file will state explicitly the license it belongs to.
If this is not the case this is considered a bug.
Copies of the Licenses are found in the LICENSES folder.


Coding Guidelines
=================

- Indentation must use spaces only. Do not use tabs for this purpose.
- Character encoding must be UTF-8 in every place.
- Line ending should be Unix style (LF only).
- Use tool based formatting where available.


Feedback
========

Feedback is welcome. Patches and pull requests are even more welcome.


