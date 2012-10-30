# Single file experiments.
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

message("***   Entering exp - the experimental programs   ***")

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
if(MSVC)
    add_definitions(${BERG_ADD_DEFINITIONS})
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS regex filesystem system REQUIRED)

include_directories(
    ${CX_INC_DIR}
    .
    ${PROJECT_SOURCE_DIR}/lib
    ${Boost_INCLUDE_DIRS}
    ${BOOST_CGI_INCLUDEDIR}
    ${CTEMPLATE_INCLUDEDIR}
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
        "${BOOST_LIBRARYDIR}"
        "${CTEMPLATE_LIBRARYDIR}"
        "${ICU_LIBRARYDIR}"
        )
endif()

add_executable (hello_world hello_world.cpp)
install(TARGETS hello_world DESTINATION "${BERG_INSTALL_CGIBIN}")

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    add_executable (show_rpath show_rpath.cpp)
    install(TARGETS show_rpath DESTINATION "${BERG_INSTALL_CGIBIN}")
    target_link_libraries(show_rpath  "dl")
    #set_target_properties(show_rpath PROPERTIES LINK_FLAGS "-Wl,-rpath=lib -Wl,-rpath=../brg/lib -Wl,-rpath=$ORIGIN/../brg/lib")
endif()

add_executable (simple_regex simple_regex.cpp)
target_link_libraries(simple_regex ${Boost_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES} ${SYSTEM_SPECIFIC_LIBRARIES})
if(${BERG_LINK_FLAGS})
    set_target_properties(simple_regex PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
install(TARGETS simple_regex DESTINATION "${BERG_INSTALL_CGIBIN}")

add_executable (echo echo.cpp)
target_link_libraries(echo ${Boost_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES} ${SYSTEM_SPECIFIC_LIBRARIES})
if(${BERG_LINK_FLAGS})
    set_target_properties(echo PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
install(TARGETS echo DESTINATION "${BERG_INSTALL_CGIBIN}")

add_executable (exptemplate exptemplate.cpp)
target_link_libraries(exptemplate ${Boost_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES} ${CTEMPLATE_LIBRARY} ${SYSTEM_SPECIFIC_LIBRARIES})
if(${BERG_LINK_FLAGS})
    set_target_properties(exptemplate PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()
install(TARGETS exptemplate DESTINATION "${BERG_INSTALL_CGIBIN}")

