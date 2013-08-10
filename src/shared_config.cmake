# shared_config.cmake
# This file holds all the shared configurations.
# It will load all other configurations.
#
# Copyright 2012, 2013 Christian Leutloff <leutloff@sundancer.oche.de>
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

# The server-side directory layout is reflected in the ZIP archive
set(BERG_INSTALL_CGIBIN "cgi-bin/brg")
set(BERG_INSTALL_HTDOCS "htdocs/brg")

# determine the hostname of this build
if(WIN32)
    set(BUILDHOST $ENV{COMPUTERNAME})
else()
    find_program(SYSHOSTNAME NAMES hostname)
    # Get the build name and hostname
    exec_program(${SYSHOSTNAME} ARGS OUTPUT_VARIABLE tmphostname)
    string(REGEX REPLACE "[/\\\\+<> #]" "-" BUILDHOST "${tmphostname}")
endif()
#message("BUILDHOST is ${BUILDHOST}")

# add standard boost library
#include("${PROJECT_SOURCE_DIR}/boost_config.cmake")

# has not worked in the first try:
#include("${PROJECT_SOURCE_DIR}/crosscompile_config.cmake")

# add CGI library - header only
set(BOOST_CGI_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/boost-cgi")

# add Process library - header only
set(BOOST_PROCESS_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/boost-process")

# add ctemplate library - header
if(MSVC AND EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/src/windows/ctemplate")
    set(CTEMPLATE_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/src/windows")
elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/src/ctemplate")
    set(CTEMPLATE_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/src")
elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate/include/ctemplate")
    set(CTEMPLATE_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/ctemplate/include")
else()
    set(CTEMPLATE_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/ctemplate/include")
    message("Include directory for Ctemplate not found! Default location: ${CTEMPLATE_INCLUDEDIR}")
endif()

# add ctemplate library - header for tests
if(EXISTS "${CTEMPLATE_INCLUDEDIR}/../../src/tests")
    set(CTEMPLATETESTS_INCLUDEDIR "${CTEMPLATE_INCLUDEDIR}/../../src")
elsif(EXISTS "${CTEMPLATE_INCLUDEDIR}/../src/tests")
    set(CTEMPLATETESTS_INCLUDEDIR "${CTEMPLATE_INCLUDEDIR}/../src")
else()
    set(CTEMPLATETESTS_INCLUDEDIR "${CTEMPLATE_INCLUDEDIR}/../src")
    #message("Include directory for Ctemplate TESTS not found (${CTEMPLATE_INCLUDEDIR}/../src/tests)! Default location: ${CTEMPLATETESTS_INCLUDEDIR}")
endif()

# add ctemplate library - compiled dynamic lib
if(EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate/lib")
    set(CTEMPLATE_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/ctemplate/lib")
elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/lib")
    set(CTEMPLATE_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/lib")
elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/Debug")
    set(CTEMPLATE_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/ctemplate-2.0/Debug")
else()
    set(CTEMPLATE_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/ctemplate/lib")
endif()
#message("berg - CTEMPLATE_INCLUDEDIR: ${CTEMPLATE_INCLUDEDIR},\n CTEMPLATETESTS_INCLUDEDIR: ${CTEMPLATETESTS_INCLUDEDIR},\n  CTEMPLATE_LIBRARYDIR: ${CTEMPLATE_LIBRARYDIR}")

if(MSVC)
    set(CTEMPLATE_LIBRARY "libctemplate")
    set(VISUAL_LEAK_DETECTOR_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/visual_leak_detector/include")
    set(VISUAL_LEAK_DETECTOR_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/visual_leak_detector/lib/Win32")
else()
    set(CTEMPLATE_LIBRARY "ctemplate")
endif()
if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}")
    install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libctemplate.so.0.1.3" DESTINATION "${BERG_INSTALL_CGIBIN}/lib" RENAME "libctemplate.so.0")
else()
    #install(PROGRAMS "${CTEMPLATE_LIBRARYDIR}/libctemplate.so.0.1.3" DESTINATION "${BERG_INSTALL_CGIBIN}/lib" RENAME "libctemplate.so.0")
    install(PROGRAMS "${CTEMPLATE_LIBRARYDIR}/libctemplate.so.2.0.1" DESTINATION "${BERG_INSTALL_CGIBIN}/lib" RENAME "libctemplate.so.2")
    #install(PROGRAMS "${CTEMPLATE_LIBRARYDIR}/libctemplate.so.0" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
endif()

# add icu libs:
if(NOT MSVC)
    if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}")
        if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicuuc.so.48")
            set(BERG_ICU_VERSION 48)
        elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicuuc.so.44")
            set(BERG_ICU_VERSION 44)
        elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicuuc.so.38")
            set(BERG_ICU_VERSION 38)
        else()
            message("${PROJECT_SOURCE_DIR}/external/libicuNN found or version not tested/used. This is okay when system library is used.")
        endif()

        if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicuuc.so.${BERG_ICU_VERSION}")
            set(ICU_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}}")
            #message("Use ICU version ${BERG_ICU_VERSION} from external/lib-${BUILDHOST}.")

            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicuuc.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicui18n.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}/libicudata.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
        endif()
    else()
        if(EXISTS "${PROJECT_SOURCE_DIR}/external/libicu48")
            set(BERG_ICU_VERSION 48)
        elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/libicu44")
            set(BERG_ICU_VERSION 44)
        elseif(EXISTS "${PROJECT_SOURCE_DIR}/external/libicu38")
            set(BERG_ICU_VERSION 38)
        else()
            message("${PROJECT_SOURCE_DIR}/external/libicuNN found or version not tested/used. This is okay when system library is used.")
        endif()

        if(EXISTS "$${PROJECT_SOURCE_DIR}/external/libicu${BERG_ICU_VERSION}/lib/libicuuc.so.${BERG_ICU_VERSION}")
            set(ICU_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/libicu${BERG_ICU_VERSION}/lib")
            #message("Use ICU version ${BERG_ICU_VERSION} from external/libicu${BERG_ICU_VERSION}.")

            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/libicu${BERG_ICU_VERSION}/lib/libicuuc.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/libicu${BERG_ICU_VERSION}/lib/libicui18n.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
            install(PROGRAMS "${PROJECT_SOURCE_DIR}/external/libicu${BERG_ICU_VERSION}/lib/libicudata.so.${BERG_ICU_VERSION}" DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
        endif()
    endif()
endif(NOT MSVC)

# enable MS VC specific stuff
if(MSVC)
    set(BERG_ADD_DEFINITIONS "-D_WIN32_WINNT=0x0501")
endif()

# enable gcc specific stuff
if(CMAKE_COMPILER_IS_GNUCXX)
    # pthread is added automatically to boost_thread
    # rt is required for Debian Squeeze, other systems are okay, too
    set(BERG_SYSTEM_SPECIFIC_LIBRARIES rt)
#    set_source_files_properties(${BERG_STORAGE_LIB_SRC} PROPERTIES COMPILE_FLAGS "-g")
#    set(BERG_LINK_FLAGS "-Wl,-rpath=lib -Wl,-rpath=../brg/lib")
endif()

##### Set RPATH to find the required dynamic libraries for local use and on web server after installation
# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

#SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
#set(CMAKE_INSTALL_RPATH "lib:$ORIGIN/lib:$ORIGIN/../brg/lib")
set(CMAKE_INSTALL_RPATH "lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
#SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

