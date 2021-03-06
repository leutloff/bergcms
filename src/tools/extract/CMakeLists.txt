# Build the tool to extract the articles from the CSV file.
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

message("***   Entering tools/extract   ***")

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
if(MSVC)
    add_definitions(${BERG_ADD_DEFINITIONS})
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    #add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

#find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS date_time filesystem regex program_options thread system REQUIRED)

include_directories(
    ${CX_INC_DIR}
    .
    ${PROJECT_SOURCE_DIR}/lib
    ${Boost_INCLUDE_DIRS}
    ${BOOST_CGI_INCLUDEDIR}
    )

if(EXISTS "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}")
    # use single host specific lib path
    link_directories(
        "${PROJECT_SOURCE_DIR}/external/lib-${BUILDHOST}"
        )
else()
    link_directories(
        ${CX_LIB_DIR}
        "${PROJECT_SOURCE_DIR}/lib"
        #"${BOOST_LIBRARYDIR}"
        "${Boost_LIBRARY_DIRS}"
        "${ICU_LIBRARYDIR}"
        )
endif()

set(EXTRACT_SRC extract.cpp)

add_executable (berg_extract ${EXTRACT_SRC}) 

target_link_libraries(berg_extract berg_storage ${Boost_LIBRARIES} ${BERG_SYSTEM_SPECIFIC_LIBRARIES})

add_dependencies(berg_extract berg_storage)

if(${BERG_LINK_FLAGS})
    set_target_properties(berg_extract PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
target_compile_features(berg_extract PRIVATE ${BERG_USED_CXX_FEATURES})
