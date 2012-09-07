# boost_config.cmake
# This file holds all the Boost related configurations.
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

set(BERG_BOOST_VERSION 1.48.0)
set(BOOST_ROOT "${PROJECT_SOURCE_DIR}/external/boost_1_48_0")
if(MSVC) 
	set(Boost_USE_MULTITHREADED     ON)# only multithreaded libs build for MSVC
else()
	set(Boost_USE_MULTITHREADED     OFF)
endif()
set(Boost_USE_STATIC_LIBS       OFF)
set(Boost_USE_STATIC_RUNTIME    OFF)# OFF to get -shared-libgcc, this is required to use exceptions
set(Boost_NO_SYSTEM_PATHS      TRUE)
set(Boost_NO_BOOST_CMAKE       TRUE)
set(Boost_ADDITIONAL_VERSIONS   "1.48" "1.48.0" )
set(BOOST_INCLUDEDIR "${PROJECT_SOURCE_DIR}/external/boost_1_48_0")
#message("berg BOOST_INCLUDEDIR: ${BOOST_INCLUDEDIR}")#
if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}")
    # use single host specific lib path
    set(BOOST_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}")
else()
    set(BOOST_LIBRARYDIR "${PROJECT_SOURCE_DIR}/external/boost_1_48_0/stage/lib")
endif()
#message("berg BOOST_LIBRARYDIR: ${BOOST_LIBRARYDIR}")


if(NOT DEFINED Boost_DEBUG)
    set(Boost_DEBUG TRUE)# enable to see some of the findings of the find package
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
	# on lenny std::locale("") throws an exception 8-(
	add_definitions(-DBOOST_NO_STD_LOCALE)
endif()

if(MSVC)
    if (NOT DEFINED BOOST_ALL_DYN_LINK)
        set(BOOST_ALL_DYN_LINK TRUE)
    endif()
    set(BOOST_ALL_DYN_LINK "${BOOST_ALL_DYN_LINK}" CACHE BOOL "boost enable dynamic linking")
    if(BOOST_ALL_DYN_LINK)
        add_definitions(-DBOOST_ALL_DYN_LINK) #setup boost auto-linking in msvc
    else(BOOST_ALL_DYN_LINK)
        unset(BOOST_REQUIRED_COMPONENTS) #empty components list for static link
    endif(BOOST_ALL_DYN_LINK)
endif(MSVC)

if (WIN32)
    add_definitions(${Boost_LIB_DIAGNOSTIC_DEFINITIONS})
endif()

install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_chrono.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_date_time.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_filesystem.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_iostreams.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_program_options.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_regex.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_signals.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_system.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_thread.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
#install(PROGRAMS ${BOOST_LIBRARYDIR}/libboost_unit_test_framework.so.${BERG_BOOST_VERSION} DESTINATION "${BERG_INSTALL_CGIBIN}/lib")


