# crosscompile_config.cmake
# This file holds the configuration for cross compiling.
# This is an archive for the first failed trial.
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


if(CMAKE_CROSSCOMPILING)
    #message("cross-compiling BOOST_ROOT: ${BOOST_ROOT}, ")
    message("cross-compiling ")
    set(Boost_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/external/boost_1_48_0")
    set(BOOST_LIBRARYDIR "${PROJECT_SOURCE_DIR}/cross-compile/lenny/usr/local/lib")
    set(Boost_DEBUG TRUE)
    #find_package(Boost 1.48.0)
endif()


# /usr/lib/gcc/x86_64-linux-gnu/4.3.2/:
# /usr/x86_64-linux-gnu/lib/x86_64-linux-gnu/4.3.2/:
# /usr/lib/x86_64-linux-gnu/4.3.2/:
# /lib/x86_64-linux-gnu/4.3.2/:
# /usr/x86_64-linux-gnu/lib/:
# /lib/:
# /usr/lib/

# these are not BOOST related, but shared ...
if(CMAKE_CROSSCOMPILING)
    set(CX_ROOT "${PROJECT_SOURCE_DIR}/cross-compile/lenny")
#     set(CX_INC_DIR  "${CX_ROOT}/usr/include"
#                     "${CX_ROOT}/usr/include/linux"
#                     "${CX_ROOT}/usr/include/c++/4.3/tr1" 
#                     "${CX_ROOT}/usr/include/c++/4.3" 
#                     "${CX_ROOT}/usr/include/c++/4.3/x86_64-linux-gnu"
#                     "${CX_ROOT}/usr/include/x86_64-linux-gnu/bits"
#                     "${CX_ROOT}/usr/lib/gcc/x86_64-linux-gnu/4.3/include"
#                     "${CX_ROOT}/usr/src/linux-headers-2.6.26-2-amd64/include/linux"
#                     )

# /usr/include/c++/4.6/x86_64-linux-gnu
#/lib/x86_64-linux-gnu
#/usr/include/x86_64-linux-gnu
    set(CX_INC_DIR  "${CX_ROOT}/usr/src/linux-headers-2.6.26-2-amd64/include/linux"
                    "${CX_ROOT}/usr/src/linux-headers-2.6.26-2-common/include/linux"
                    "${CX_ROOT}/usr/include/c++/4.3/x86_64-linux-gnu"
                    "${CX_ROOT}/usr/include/c++/4.3" 
                    "${CX_ROOT}/usr/include/x86_64-linux-gnu/bits"
                    "${CX_ROOT}/usr/lib/gcc/x86_64-linux-gnu/4.3/include"
                    "${CX_ROOT}/usr/include/linux"
                    "${CX_ROOT}/usr/include"
                    )
    set(CX_LIB_DIR  "${CX_ROOT}/lib"
                    "${CX_ROOT}/usr/lib")
    message("CX_INC_DIR: ${CX_INC_DIR}")
    message("CX_LIB_DIR: ${CX_LIB_DIR}")
    if(CMAKE_COMPILER_IS_GNUCXX)
        #set(SYSTEM_SPECIFIC_LIBRARIES pthread-2.7 c-2.7)
        set(SYSTEM_SPECIFIC_LIBRARIES pthread)
        #set(CMAKE_CXX_FLAGS "-nostdlib -nostdinc -Wall -fno-builtin -fno-exceptions -fno-threadsafe-statics -fno-rtti -g" )
        set(CMAKE_CXX_FLAGS "-nostdlib -nostdinc -Wall" )
    endif()
else()
endif()
