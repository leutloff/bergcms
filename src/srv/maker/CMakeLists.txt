# Compile the maker responsible to create the PDF for printing.
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

message("***   Entering srv/maker (makes the PDF)   ***")

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
add_definitions(${BERG_ADD_DEFINITIONS})
if(MSVC)
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    #add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

#find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS chrono date_time filesystem iostreams regex system thread REQUIRED)

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
        "${Boost_LIBRARY_DIRS}"
        "${ICU_LIBRARYDIR}"
        )
endif()

set(MAKER_SRC maker.cpp)

add_executable(maker ${MAKER_SRC})

set_property(TARGET maker PROPERTY CXX_STANDARD 14)

target_link_libraries(maker berg_storage ${Boost_LIBRARIES} ${BERG_SYSTEM_SPECIFIC_LIBRARIES})

add_dependencies(maker berg_storage)

if(${BERG_LINK_FLAGS})
    set_target_properties(maker PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
target_compile_features(maker PRIVATE ${BERG_USED_CXX_FEATURES})

install(TARGETS maker DESTINATION "${BERG_INSTALL_CGIBIN}")
