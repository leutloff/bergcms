# Testing the library using C++ unit tests.
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

message("***   Entering test (C++ unit tests), target: bergunittests   ***")

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
if(MSVC)
    add_definitions(${BERG_ADD_DEFINITIONS})
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    #add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

#find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS date_time filesystem iostreams regex system thread unit_test_framework REQUIRED)

include_directories(
    ${CX_INC_DIR}
    .
    ${PROJECT_SOURCE_DIR}/lib
    ${Boost_INCLUDE_DIRS}
    ${BOOST_CGI_INCLUDEDIR}
    ${BOOST_PROCESS_INCLUDEDIR}
    ${CTEMPLATE_INCLUDEDIR}
    ${CTEMPLATETESTS_INCLUDEDIR}
    ${VISUAL_LEAK_DETECTOR_INCLUDEDIR}
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
        "${CTEMPLATE_LIBRARYDIR}"
        "${ICU_LIBRARYDIR}"
        ${VISUAL_LEAK_DETECTOR_LIBRARYDIR}
        )
endif()

set(UNITTEST_H   TestShared.h)

set(UNITTEST_SRC TestMain.cpp
                 TestArticle.cpp TestStorage.cpp TestHelper.cpp
                 TestTexGenerationUsingPex.cpp
                 TestDirectoryLayout.cpp
                 TestArticleJson.cpp TestRESTfulApi.cpp)

# add -lpthread when required
set(THREADS_PREFER_PTHREAD_FLAG ON)
#find_package(Threads REQUIRED)
find_package(Threads)

add_executable(bergunittests ${UNITTEST_SRC} ${UNITTEST_H})
IF (MSVC)
    target_link_libraries(bergunittests berg_storage ${Boost_LIBRARIES} ${CTEMPLATE_LIBRARY} ${BERG_SYSTEM_SPECIFIC_LIBRARIES})
ELSE()
    target_link_libraries(bergunittests berg_storage ${Boost_LIBRARIES} ${CTEMPLATE_LIBRARY} ${BERG_SYSTEM_SPECIFIC_LIBRARIES} Threads::Threads)
ENDIF()
add_dependencies(bergunittests berg_storage)
if(${BERG_LINK_FLAGS})
    set_target_properties(bergunittests PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
target_compile_features(bergunittests PRIVATE ${BERG_USED_CXX_FEATURES})



