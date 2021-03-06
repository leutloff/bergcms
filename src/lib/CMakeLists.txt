# Storage Library
#
# Copyright 2012, 2013, 2014, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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

message("***   Entering lib/berg_storage   ***")

include("${PROJECT_SOURCE_DIR}/directory_layout.cmake")
include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
add_definitions(${BERG_ADD_DEFINITIONS})
if(MSVC)
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    #add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

include_directories(
    ${CX_INC_DIR}
    .
    ${Boost_INCLUDE_DIRS}
    ${BOOST_CGI_INCLUDEDIR}
    )

set(BERG_STORAGE_LIB_SRC Common.cpp Helper.cpp FileStorage.cpp Article.cpp Archive.cpp DirectoryLayout.cpp ProcessStep.cpp RestArticle.cpp)
set(BERG_STORAGE_LIB_H BoostFlags.h Common.h Helper.h FileStorage.h Article.h Archive.h DirectoryLayout.h ProcessStep.h RestArticle.h)

source_group("Headers" FILES ${BERG_STORAGE_LIB_H})
if (MSVC)
    add_library(berg_storage ${BERG_STORAGE_LIB_SRC} ${BERG_STORAGE_LIB_H})
else()
    add_library(berg_storage STATIC ${BERG_STORAGE_LIB_SRC} ${BERG_STORAGE_LIB_H})
endif()

target_compile_features(berg_storage PRIVATE ${BERG_USED_CXX_FEATURES})

install(TARGETS berg_storage DESTINATION "${BERG_INSTALL_CGIBIN}/lib")
