# shared_config.cmake
# This file holds all the shared configurations.
# It will load all other configurations.
#
# Copyright 2012, 2013, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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

include("${PROJECT_SOURCE_DIR}/directory_layout.cmake")

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
            #message("${PROJECT_SOURCE_DIR}/external/libicuNN found or version not tested/used. This is okay when system library is used.")
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
        elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libicuuc.so.60")
            set(BERG_ICU_VERSION 60)
        elseif(EXISTS "/usr/lib/i386-linux-gnu/libicuuc.so.60")
            set(BERG_ICU_VERSION 60)
        elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libicuuc.so.55")
            set(BERG_ICU_VERSION 55)
        elseif(EXISTS "/usr/lib/i386-linux-gnu/libicuuc.so.55")
            set(BERG_ICU_VERSION 55)
        elseif(EXISTS "/usr/lib/x86_64-linux-gnu/libicuuc.so.52")
            set(BERG_ICU_VERSION 52)
        elseif(EXISTS "/usr/lib/i386-linux-gnu/libicuuc.so.52")
            set(BERG_ICU_VERSION 52)
        else()
            message("Lib ICU not found or version not tested/used. Please check that it is installed. Feel free to add your version in the tests above.")
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
    # _WIN32_WINNT_WIN7 (0x0601)
    set(BERG_ADD_DEFINITIONS "${BERG_ADD_DEFINITIONS} -D_WIN32_WINNT=0x0601")
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

set(BERG_USED_CXX_FEATURES cxx_constexpr cxx_auto_type cxx_range_for cxx_delegating_constructors)
