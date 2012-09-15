# install_package.cmake
# This file holds the information to create a ZIP package.
# This can the be used to transfer the whole application to the web server.
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

include("${PROJECT_SOURCE_DIR}/shared_config.cmake")

# CPack settings
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Berg CMS - Redaktionssystem zur Erstellung der Gemeindeinformation (Pfarrbrief) für die FeG Aachen.")
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
set(CPACK_STRIP_FILES  TRUE)
set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_GENERATOR "ZIP")
#set(CPACK_PACKAGE_NAME "${PROJECT_NAME}-${APPLICATION_VERSION_MAJOR}.${APPLICATION_VERSION_MINOR}.${APPLICATION_VERSION_PATCH}-${CMAKE_SYSTEM}")
# TODO add build system (lsb_release -dcs ) and architecture (uname -m) instead of buildhostname
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}-${BUILDHOST}")
include(CPack)

# BERG_INSTALL_HTDOCS is htdocs/brg

# add javascript/CSS
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/css" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# add images/icons
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/bgico" DESTINATION "${BERG_INSTALL_HTDOCS}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# add the templates
install(DIRECTORY "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/template" DESTINATION "${BERG_INSTALL_CGIBIN}"
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# add empty archive directory (archive_content)
install(FILES "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/archive_content/README.txt" DESTINATION "${BERG_INSTALL_CGIBIN}/archive_content")

# HTML favicon
install(FILES    "${PROJECT_SOURCE_DIR}/../www/htdocs/favicon.ico"
        DESTINATION "${BERG_INSTALL_HTDOCS}")

# add static HTML pages
install(FILES "${PROJECT_SOURCE_DIR}/../www/htdocs/brg/hilfe.html"
        DESTINATION "${BERG_INSTALL_HTDOCS}")

# add required perl scripts
install(PROGRAMS "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/pex.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/berg.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/bgcrud.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/bgul.pl"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/xsc.pl"
        DESTINATION "${BERG_INSTALL_CGIBIN}")
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/xsc.sh"
        DESTINATION "${BERG_INSTALL_CGIBIN}" RENAME "xsc")
# sample database and LaTeX files
#install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/feginfo.csv"
#                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/feglogo.jpg"
install(FILES    "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/sectsty.sty"
                 "${PROJECT_SOURCE_DIR}/../www/cgi-bin/brg/br/wrapfig.sty"
        DESTINATION "${BERG_INSTALL_CGIBIN}/br")

#install(CODE "MESSAGE(\"Sample install message.\")")
