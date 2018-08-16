# boost_config.cmake
# This file holds all the Boost related configurations.
#
# Copyright 2012, 2013, 2016, 2017, 2018 Christian Leutloff <leutloff@sundancer.oche.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

    # using distribution specific versions - feel free to add your distribution, too.
    # apt-get install libboost-all-dev
    # Ubuntu 16.04 xenial LTS -> 1.58 (32 and 64 bit)
    # Ubuntu 16.10 -> 1.61
    # Ubuntu 17.04 -> 1.62
    # Ubuntu 18.04 -> 1.65
    # Debian jessie -> 1.55.0
    # Windows latest as of 20160317 -> 1.60.0
    # Boost filesystem < 1.57 can not be compiled with -std=c++11 (undefined reference to `boost::filesystem::detail::copy_file)
    if(EXISTS "/usr/lib/x86_64-linux-gnu/libboost_thread.so.1.65.1")
        set(BERG_BOOST_VERSION 1.65.1)
    elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libboost_thread.so.1.62.0")
        set(BERG_BOOST_VERSION 1.62.0)
    elseif(EXISTS "/usr/lib/libboost_filesystem.so.1.61.0")
        set(BERG_BOOST_VERSION 1.61.0)
    elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.61.0")
        set(BERG_BOOST_VERSION 1.61.0)
    elseif(EXISTS "/usr/lib/libboost_filesystem.so.1.60.0")
        set(BERG_BOOST_VERSION 1.60.0)
    elseif(EXISTS "/usr/lib/libboost_filesystem.so.1.59.0")
        set(BERG_BOOST_VERSION 1.59.0)
    elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.58.0")
        set(BERG_BOOST_VERSION 1.58.0)
    elseif(EXISTS "/usr/lib/i386-linux-gnu/libboost_filesystem.so.1.58.0")
        set(BERG_BOOST_VERSION 1.58.0)
    elseif(EXISTS "/usr/lib/libboost_filesystem.so.1.58.0")
        set(BERG_BOOST_VERSION 1.58.0)
    elseif(EXISTS "/usr/local/lib/libboost_filesystem.so.1.58.0")
        set(BERG_BOOST_VERSION 1.58.0)
    else()
        # Library versions below 1.58 are not tested any more. But feel free to test them and make them work...
        # Even lower than 1.58 are returning not useful utf-16 chars in JSON parse-tree writer.
        message("Specific version of the Boost Filesystem Library not found. Please add it to the list above in boost_config.cmake.")
        set(BERG_BOOST_VERSION 1.58.0)
    endif()

if(MSVC)
    set(Boost_USE_MULTITHREADED     ON)# only multithreaded libs build for MSVC
else()
    set(Boost_USE_MULTITHREADED     OFF)
endif()
set(Boost_USE_STATIC_LIBS      OFF)
set(Boost_USE_STATIC_RUNTIME   OFF)# OFF to get -shared-libgcc, this is required to use exceptions
set(Boost_NO_BOOST_CMAKE       TRUE)

if(NOT DEFINED Boost_DEBUG)
    set(Boost_DEBUG TRUE)# enable to see some of the findings of the find package
endif()

if(MSVC)
    if (NOT DEFINED BOOST_ALL_DYN_LINK)
        set(BOOST_ALL_DYN_LINK TRUE)
    endif()
    set(BOOST_ALL_DYN_LINK "${BOOST_ALL_DYN_LINK}" CACHE BOOL "Boost enable dynamic linking")
    if(BOOST_ALL_DYN_LINK)
        add_definitions(-DBOOST_ALL_DYN_LINK) #setup boost auto-linking in msvc
    else()
        unset(BOOST_REQUIRED_COMPONENTS) #empty components list for static link
    endif()
endif(MSVC)

if (WIN32)
    add_definitions(${Boost_LIB_DIAGNOSTIC_DEFINITIONS})
endif()

find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS chrono date_time filesystem iostreams locale program_options regex signals thread unit_test_framework serialization system REQUIRED)
#message("berg Boost_LIBRARY_DIRS: ${Boost_LIBRARY_DIRS} - deprecated: BOOST_LIBRARYDIR: ${BOOST_LIBRARYDIR}.")

# Add the boost libs to the install package.
include("${PROJECT_SOURCE_DIR}/directory_layout.cmake")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_chrono.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_date_time.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_filesystem.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_iostreams.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_locale.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_program_options.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_regex.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_signals.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_system.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_thread.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_unit_test_framework.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${Boost_LIBRARY_DIRS}/libboost_serialization.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
