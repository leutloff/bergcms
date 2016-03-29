/**
 * @file TestMain.cpp
 * Main function calling unit_test_main. Avoids using the main from the library,
 * because it is not available on the backported library (from wheezy to squeeze).
 *
 * Copyright 2013, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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

#include <boost/version.hpp>

#define BOOST_TEST_DYN_LINK

// the following definition must be defined once per test project
#if (BOOST_VERSION < 105900)
#define BOOST_TEST_MAIN
#else
#define BOOST_TEST_MODULE Berg CMS Library Tests
#endif
#include <boost/test/unit_test.hpp>  // include this to get main()
