# Main CMake file
#
# Copyright 2012 Christian Leutloff <leutloff@sundancer.oche.de>
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

# Debian Lenny only provides 2.6
cmake_minimum_required (VERSION 2.6)

message("***   Entering the main CMakeLists.txt file  ***")

project (Berg CXX)

# set these for release
set(APPLICATION_VERSION_MAJOR "3")
set(APPLICATION_VERSION_MINOR "0")
set(APPLICATION_VERSION_PATCH "2")

if(NOT DEFINED CMAKE_VERBOSE_MAKEFILE)
    set(CMAKE_VERBOSE_MAKEFILE  TRUE)# set to true to see the full compile and link commands
    message("setting CMAKE_VERBOSE_MAKEFILE to true.")
endif()
#set(CMAKE_VERBOSE_MAKEFILE TRUE)
message("CMAKE_VERBOSE_MAKEFILE is ${CMAKE_VERBOSE_MAKEFILE}.")

if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "selects the configuration for the Makefile generator. Known values: None, Debug, Release, RelWithDebInfo, MinSizeRel, Distribution")
message("CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}.")


# provide a special link flag for lib foo?
#SET_TARGET_PROPERTIES(foo PROPERTIES LINK_FLAGS -Wl,-specialFlag)

#set_target_properties(archive PROPERTIES LINK_FLAGS  -Wl,-rpath=. )

# TODO add flags from Release, too. Add strip step, too!?
#set(CMAKE_BUILD_TYPE distribution)
set(CMAKE_CXX_FLAGS_DISTRIBUTION "-O3")
set(CMAKE_C_FLAGS_DISTRIBUTION "-O3")


# add all the subdirectories
add_subdirectory(lib)# the libraries shared between all the projects
add_subdirectory(srv)# CGI programs on the web server
add_subdirectory(test)# unit tests
add_subdirectory(tools)# helper programs
add_subdirectory(exp)# programs used to experiment with something, e.g. getting started with a new library

#add information to create a ZIP package for transfering it to the web server.
include("${PROJECT_SOURCE_DIR}/install_package.cmake")

message("BUILDHOST is ${BUILDHOST}.")
message("Use ICU version ${BERG_ICU_VERSION}.")
message("BOOST_LIBRARYDIR is ${BOOST_LIBRARYDIR}.")
