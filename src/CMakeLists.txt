# Main CMake file
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

# Debian Lenny only provides 2.6, Jessie 3.0
# Ubuntu Trusty 2.8, Xenial 3.3
# Install CMake 2.5 from https://cmake.org/files/v3.5/cmake-3.5.0-Linux-x86_64.sh or https://cmake.org/files/v3.5/cmake-3.5.0-Linux-i386.sh
cmake_minimum_required (VERSION 3.5)

message("***   Entering the main CMakeLists.txt file  ***")

project (Berg CXX)

# set these for release
set(APPLICATION_VERSION_MAJOR "3")
set(APPLICATION_VERSION_MINOR "2")
set(APPLICATION_VERSION_PATCH "4")

# use this command to enable verbose CMAKE processing
# cmake -D CMAKE_VERBOSE_MAKEFILE=true -D CMAKE_BUILD_TYPE=Debug -D Boost_DEBUG=FALSE ../src
#set(CMAKE_VERBOSE_MAKEFILE TRUE)
message("CMAKE_VERBOSE_MAKEFILE is ${CMAKE_VERBOSE_MAKEFILE}.")

if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
    set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "selects the configuration for the Makefile generator. Known values: None, Debug, Release, RelWithDebInfo, MinSizeRel, Distribution")
endif()
message("CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}.")

if(NOT DEFINED USE_CTEMPLATE)
    set(USE_CTEMPLATE TRUE)
    set(USE_CTEMPLATE "${USE_CTEMPLATE}" CACHE BOOL "flag wheter the build should be with ctemplate or not.")
ENDIF()
message("USE_CTEMPLATE is ${USE_CTEMPLATE}.")

if(COMMAND cmake_policy)
    # Included scripts do automatic cmake_policy PUSH and POP.
    cmake_policy(SET CMP0011 NEW)
    # link_directories() treats paths relative to the source dir
    cmake_policy(SET CMP0015 NEW)
endif()

# provide a special link flag for lib foo?
#SET_TARGET_PROPERTIES(foo PROPERTIES LINK_FLAGS -Wl,-specialFlag)

#set_target_properties(archive PROPERTIES LINK_FLAGS  -Wl,-rpath=. )

# TODO add flags from Release, too. Add strip step, too!?
#set(CMAKE_BUILD_TYPE distribution)
set(CMAKE_CXX_FLAGS_DISTRIBUTION "-O3")
set(CMAKE_C_FLAGS_DISTRIBUTION "-O3")
set(BERG_ADD_DEFINITIONS "")

# add standard boost library
include("${PROJECT_SOURCE_DIR}/boost_config.cmake")

# add all the subdirectories
add_subdirectory(lib)# the libraries shared between all the projects
add_subdirectory(srv)# CGI programs on the web server
add_subdirectory(test)# unit tests
add_subdirectory(tools)# helper programs
add_subdirectory(exp)# programs used to experiment with something, e.g. getting started with a new library

#add information to create a ZIP package for transfering it to the web server.
include("${PROJECT_SOURCE_DIR}/install_package.cmake")

message("Name of BUILDHOST is ${BUILDHOST}.")
message("ICU version: ${BERG_ICU_VERSION}.")
#message("Using the BOOST_LIBRARYDIR with the value of ${BOOST_LIBRARYDIR}.")
message("Using the Boost_LIBRARY_DIRS with the value of ${Boost_LIBRARY_DIRS}.")
message("Using the Boost_INCLUDE_DIRS with the value of ${Boost_INCLUDE_DIRS}.")
