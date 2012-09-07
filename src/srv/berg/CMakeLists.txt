# 
message("***   Entering srv/berg (main entry point on web server)   ***")

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")
if(MSVC)
    add_definitions(${BERG_ADD_DEFINITIONS})
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")
    add_definitions("-DHAS_VISUAL_LEAK_DETECTOR")
endif()

find_package(Boost ${BERG_BOOST_VERSION} COMPONENTS date_time filesystem regex system thread REQUIRED)

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
        )
endif()

set(BERG_SRC berg.cpp)

add_executable(berg ${BERG_SRC})

target_link_libraries(berg berg_storage ${Boost_LIBRARIES} ${CMAKE_REQUIRED_LIBRARIES} ${CTEMPLATE_LIBRARY} ${SYSTEM_SPECIFIC_LIBRARIES})

add_dependencies(berg berg_storage)


if(${BERG_LINK_FLAGS})
    set_target_properties(berg PROPERTIES LINK_FLAGS ${BERG_LINK_FLAGS})
endif()

install(TARGETS berg DESTINATION "${BERG_INSTALL_CGIBIN}")
