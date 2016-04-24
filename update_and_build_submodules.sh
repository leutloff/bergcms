#!/bin/bash -e
# Updates the submodules and builds them where needed.
#
# Copyright 2012, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#
SOURCEDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Updating the submodules in $SOURCEDIR..."

pushd $SOURCEDIR
git submodule init
git submodule update
popd

exit 0;
