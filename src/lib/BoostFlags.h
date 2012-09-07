/*
 * @file: BoostFlags.h
 * Common definitions to tailor the different boost libraries.
 * 
 * Copyright 2012 Christian Leutloff <leutloff@sundancer.oche.de>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef BOOSTFLAGS_H_
#define BOOSTFLAGS_H_

// avoid the warning: »boost::system::posix_category« definiert, aber nicht verwendet [-Wunused-variable]
#define BOOST_SYSTEM_NO_DEPRECATED

// use v3 only of boost_filesystem
#define BOOST_FILESYSTEM_NO_DEPRECATED

// make the deprecated functions of chrono are not available
#define BOOST_CHRONO_IO_V1_DONT_PROVIDE_DEPRECATED

#endif /* BOOSTFLAGS_H_ */
