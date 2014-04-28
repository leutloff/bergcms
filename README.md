Berg CMS
========

Berg Content Management System is a web based CMS for publishing a regular
printed news letter, e.g. a bimonthly parish newsletter. It is suitable
for small editorial committees.

The focus of the system is the next issue to publish. An issue consists
of several articles. These articles are preprocessed and then composed
by LaTeX. The outcome is a PDF file that can be downloaded and then
sent directly to the print shop.


Building from Source
====================

[![Build Status](https://travis-ci.org/leutloff/berg.png)](https://travis-ci.org/leutloff/berg)

The most up-to-date documentation will be the Continuous Integration build
on Travis CI. The file .travis.yml performs the build of the C++ based
modules, runs C++ and Perl based unit tests, installs everything on a 
local Apache web server and will perform some GUI tests. Nevertheless these 
are the steps to perform a build:

- Clone or download the repository.
- Execute the script update_and_build_submodules.sh to initialize, update and
  build the submodules.
- Install the [Boost C++ library](http://boost.org). The easiest way is to 
  install the version provided by the distribution, e.g. for an up-to-date
  Ubuntu only the following command is necessary:
    sudo apt-get install libboost-all-dev
  For Ubuntu 12.04 LTS use the PPA https://launchpad.net/~ukplc-team and
  install boost with these commands - an up-to-date version is located in
  .travis.yml:
    sudo add-apt-repository ppa:ukplc-team/testing
    sudo apt-get update
    sudo apt-get install libboost1.49-dev libboost-chrono1.49-dev libboost-date-time1.49-dev libboost-filesystem1.49-dev libboost-iostreams1.49-dev libboost-locale1.49-dev libboost-program-options1.49-dev libboost-regex1.49-dev libboost-serialization1.49-dev libboost-signals1.49-dev libboost-system1.49-dev libboost-test1.49-dev libboost-thread1.49-dev libboost-timer1.49-dev 
  The last way is to download the Boost C++ Library from 
  [http://www.boost.org/users/download/](http://www.boost.org/users/download/)
  (start with version 1.49, when unsure). Then extract and build boost library 
  in src/external.
- Copy your libicu to src/external/libicuNN. If used other than the mentioned
  in shared_config.cmake, add your version, too. Supported out of the box
  are at least libicu48, libicu44 and libicu38.
- Launch CMake GUI and point the source code the src directory and
  build the project. Alternatively the build can done using these commands:
    mkdir build && pushd build && cmake -D CMAKE_BUILD_TYPE=Release ../src
    make 
    popd  
- Run the script make_zip.sh. This will build all applications and put all
  the required files in a single ZIP file.
- Install the content of the ZIP file on the Web Server. An outline of the
  Apache configuration is shown in doc/etc_apache2. Use the script 
  install_locally.sh to perform this step together with some tweaks with
  regard the file permissions. The used install path can be adapted to
  local differences by overriding shell variables in a file named
  install_locally.cfg.


Installation/Deployment
=======================

The installation means copying the content of the archive to the web server 
executing the web applications. This can be accomplished in different ways depending
on the requirements of the web server. The archive is build during the build 
process as described above.

Part of the archive content is a deployment script. The script deploy.sh copies 
the surrounding files to a web server using ncftpput. So the version deployed 
to web server depends on the path where the deploy.sh script is executed.

The servers are configured in a file named remotehosts.cfg. The supported 
parameters should be copied from the beginning of the deploy.sh script. Here are 
some examples calling the deploy.sh script. 

Showing the available options and components:
    ./deploy.sh -h

The script supports the deployment to two different servers. One is called test 
and the other one is the production server. Deploying the static HTML files to 
the test server can be done using this command:
    ./deploy.sh -t test -c html

Copying everything to the production server:
    ./deploy.sh -t prod -c all


GUI Tests and Unit Tests
========================

The test suite for the user interface is based on the Selenium IDE.
Get the Firefox plug-in Selenium IDE
from [http://seleniumhq.org/download/](http://seleniumhq.org/download/).
Installation is described at
[http://seleniumhq.org/docs/02_selenium_ide.html](http://seleniumhq.org/docs/02_selenium_ide.html).

The test suites and test cases are located in the folder testsuite.
Put the file www/cgi-bin/brg/testcase.pl only on testing instances.
The CGI script will copy a database according the selected test case.
This will destroy the existing database. The existence of the testcase.pl
file allows the test cases to modify the database content.

Additional to the GUI test the different parts of the system are tested with
different types of unit tests. You will find unit tests written in C++ and
Perl. New unit tests should be written in C++ when feasible.

The unit tests for the C++-Code are located in src/test. Execute the project
named test to execute the C++ test cases. These test cases are based on
boost unit test.

The Perl related unit tests are located in www/cgi-bin/brg/t. Use the script
www/cgi-bin/brg/t/run_tests.sh to execute all the Perl based tests.


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


