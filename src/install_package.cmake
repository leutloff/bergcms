# install_package.cmake
#
# This file holds the information to create a ZIP package.
# This can the be used to transfer the whole application to the web server.
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

include("${PROJECT_SOURCE_DIR}/directory_layout.cmake")
include("${PROJECT_SOURCE_DIR}/shared_config.cmake")

# CPack settings
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Berg CMS - Web App to publish regular printed news letter.")
set(CPACK_PACKAGE_VENDOR "Christian Leutloff")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "leutloff@sundancer.oche.de")
set(CPACK_PACKAGE_CONTACT "leutloff@sundancer.oche.de")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/../README.md")
#set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING.txt")
#set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "${APPLICATION_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${APPLICATION_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${APPLICATION_VERSION_PATCH}")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY True)# omit/add leading Berg-n.n.n-Linux/
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_SOURCE_IGNORE_FILES ${CPACK_SOURCE_IGNORE_FILES}
/.git/;/build/;~$;.*\\\\.bin$;.*\\\\.swp$)
#set(CPACK_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
set(CPACK_INSTALL_PREFIX "")
set(CPACK_STRIP_FILES TRUE)
set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_GENERATOR "ZIP")
set(APPLICATION_VERSION "${APPLICATION_VERSION_MAJOR}.${APPLICATION_VERSION_MINOR}.${APPLICATION_VERSION_PATCH}")
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}-${APPLICATION_VERSION}")
# TODO add build system (lsb_release -dcs ) and architecture (uname -m) instead of buildhostname
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${CMAKE_CXX_COMPILER_ID}-${BUILDHOST}")
include(CPack)

# Add the deploy scripts
install(PROGRAMS "${PROJECT_SOURCE_DIR}/../deploy.sh"
        DESTINATION "/")
install(PROGRAMS "${PROJECT_SOURCE_DIR}/../deploy_ssh.sh"
        DESTINATION "/")

# BERG_INSTALL_HTDOCS is htdocs/brg

# add javascript/CSS
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/css" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/js" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/doc" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        
# add images/icons
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/bgico" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# add the templates - not needed anymore!?
#install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/template" DESTINATION "${BERG_INSTALL_CGIBIN}"
#        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# add empty archive directory (archive_content) and other required directories - the README.txt describes the purpose
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/archive_content/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/archive_content")
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/gi_backup/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/gi_backup")
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/log/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/log")
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/out/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/out")
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/tidx/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/tidx")

# HTML favicon
install(FILES    "${PROJECT_SOURCE_DIR}/../www/htdocs/favicon.ico"
        DESTINATION "${BERG_INSTALL_HTDOCS}")

# Download Area (Download-Bereich) still outside of the brg directory
install(FILES    "${PROJECT_SOURCE_DIR}/../www/htdocs/dlb/README.txt"
        DESTINATION "${BERG_INSTALL_HTDOCS}/../dlb")

# add static HTML pages
install(FILES    "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/hilfe.html"
                 "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/.htaccess"
        DESTINATION "${BERG_INSTALL_HTDOCS}")

# add required perl scripts
install(PROGRAMS "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/pex.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/berg.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/bgcrud.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/bgul.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/xsc.pl"
        DESTINATION "${BERG_INSTALL_CGIBIN}")
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/xsc.sh"
        DESTINATION "${BERG_INSTALL_CGIBIN}")
# add perl5 Libraries
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/perl5/README.txt"
        DESTINATION "${BERG_INSTALL_CGIBIN}/perl5")
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/perl5/Algorithm/Diff.pm"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/perl5/Algorithm/Merge.pm"
        DESTINATION "${BERG_INSTALL_CGIBIN}/perl5/Algorithm")
# the sample database
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/feginfo.csv"
                 "${PROJECT_SOURCE_DIR}/../images/berg-v1/berg.jpg"
        DESTINATION "${BERG_INSTALL_CGIBIN}/br")
# The LaTeX files
install(FILES    "${PROJECT_SOURCE_DIR}/../latex/class_berg/generated/berg.cls"
        DESTINATION "${BERG_INSTALL_CGIBIN}/br")
#install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/data" DESTINATION "${BERG_INSTALL_CGIBIN}/br"
#        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

install(FILES    "${PROJECT_SOURCE_DIR}/../images/berg-v1/berg.jpg"
        DESTINATION "${BERG_INSTALL_CGIBIN}/br/bilder")

# add files used for testing purposes.
install(PROGRAMS "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/testcase.pl"
        DESTINATION "${BERG_INSTALL_CGIBIN}")
install(FILES    "${PROJECT_SOURCE_DIR}/test/input/single_article.csv"
                 "${PROJECT_SOURCE_DIR}/test/input/some_articles.csv"
                 "${PROJECT_SOURCE_DIR}/test/input/two_articles.csv"
                 "${PROJECT_SOURCE_DIR}/test/input/api_examples.csv"
        DESTINATION "${BERG_INSTALL_CGIBIN}/testcases-db")


#install(CODE "MESSAGE(\"Sample install message.\")")
