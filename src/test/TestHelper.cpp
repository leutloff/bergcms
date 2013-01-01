/**
 * @file TestHelper.cpp
 * Testing the helper classes.
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
#if defined(HAS_VISUAL_LEAK_DETECTOR)
#include <vld.h>
#endif

// vc is showing a memory leak when this file is included, see https://code.google.com/p/ctemplate/issues/detail?id=42 for the reasoning
//#include <ctemplate/template_string.h>

#include <Helper.h>

#include <boost/filesystem.hpp>
// include Boost.Test
#include <boost/test/unit_test.hpp>

using namespace std;
using namespace berg;
namespace fs = boost::filesystem;

BOOST_AUTO_TEST_CASE(test_month_to_issue_number)
{
    BOOST_REQUIRE(true);
    BOOST_CHECK_EQUAL(1, Helper::GetNumberFromMonthYear("7", "1972"));
    BOOST_CHECK_EQUAL(222, Helper::GetNumberFromMonthYear("5", "2009"));
    BOOST_CHECK_EQUAL(227, Helper::GetNumberFromMonthYear("3", "2010"));

    BOOST_CHECK_EQUAL(232, Helper::GetNumberFromMonthYear("1", "2011"));
    BOOST_CHECK_EQUAL(233, Helper::GetNumberFromMonthYear("3", "2011"));
    BOOST_CHECK_EQUAL(234, Helper::GetNumberFromMonthYear("5", "2011"));
    BOOST_CHECK_EQUAL(235, Helper::GetNumberFromMonthYear("7", "2011"));
    BOOST_CHECK_EQUAL(236, Helper::GetNumberFromMonthYear("9", "2011"));
    BOOST_CHECK_EQUAL(237, Helper::GetNumberFromMonthYear("11", "2011"));

    BOOST_CHECK_EQUAL(238, Helper::GetNumberFromMonthYear("1", "2012"));
    BOOST_CHECK_EQUAL(239, Helper::GetNumberFromMonthYear("3", "2012"));
    BOOST_CHECK_EQUAL(240, Helper::GetNumberFromMonthYear("5", "2012"));
    BOOST_CHECK_EQUAL(241, Helper::GetNumberFromMonthYear("7", "2012"));
    BOOST_CHECK_EQUAL(242, Helper::GetNumberFromMonthYear("9", "2012"));
    BOOST_CHECK_EQUAL(243, Helper::GetNumberFromMonthYear("11", "2012"));
}


BOOST_AUTO_TEST_CASE(test_issue_number_to_month)
{
    BOOST_CHECK_EQUAL(7, Helper::GetMonthFromNumber(1));//"7", "1972"));
    BOOST_CHECK_EQUAL(5, Helper::GetMonthFromNumber(222));//"5", "2009"));
    BOOST_CHECK_EQUAL(3, Helper::GetMonthFromNumber(227)); //"3", "2010"));

    BOOST_CHECK_EQUAL(1, Helper::GetMonthFromNumber(232));
    BOOST_CHECK_EQUAL(3, Helper::GetMonthFromNumber(233));
    BOOST_CHECK_EQUAL(5, Helper::GetMonthFromNumber(234));
    BOOST_CHECK_EQUAL(7, Helper::GetMonthFromNumber(235));
    BOOST_CHECK_EQUAL(9, Helper::GetMonthFromNumber(236));
    BOOST_CHECK_EQUAL(11, Helper::GetMonthFromNumber(237)); //"11", "2011"));

    BOOST_CHECK_EQUAL(1, Helper::GetMonthFromNumber(238)); //"1", "2012"));
    BOOST_CHECK_EQUAL(3, Helper::GetMonthFromNumber(239)); //"3", "2012"));
    BOOST_CHECK_EQUAL(5, Helper::GetMonthFromNumber(240));
    BOOST_CHECK_EQUAL(7, Helper::GetMonthFromNumber(241));
    BOOST_CHECK_EQUAL(9, Helper::GetMonthFromNumber(242));
    BOOST_CHECK_EQUAL(11, Helper::GetMonthFromNumber(243));
}


BOOST_AUTO_TEST_CASE(test_issue_number_to_year)
{
    BOOST_CHECK_EQUAL(1972, Helper::GetYearFromNumber(1));//"7", "1972"));
    BOOST_CHECK_EQUAL(2009, Helper::GetYearFromNumber(222));//"5", "2009"));
    BOOST_CHECK_EQUAL(2010, Helper::GetYearFromNumber(227)); //"3", "2010"));

    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(232));
    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(233));
    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(234));
    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(235));
    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(236));
    BOOST_CHECK_EQUAL(2011, Helper::GetYearFromNumber(237)); //"11", "2011"));

    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(238)); //"1", "2012"));
    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(239)); //"3", "2012"));
    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(240));
    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(241));
    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(242));
    BOOST_CHECK_EQUAL(2012, Helper::GetYearFromNumber(243));
}

BOOST_AUTO_TEST_CASE(test_get_issue_from_number)
{
    string issue;
    Helper::GetIssueFromNumber(issue, 222);
    BOOST_CHECK_EQUAL("Mai/Juni 2009", issue);//"5", "2009"));
    Helper::GetIssueFromNumber(issue, 227);
    BOOST_CHECK_EQUAL("März/April 2010", issue); //"3", "2010"));

    Helper::GetIssueFromNumber(issue, 226);
    BOOST_CHECK_EQUAL("Januar/Februar 2010", issue);
    Helper::GetIssueFromNumber(issue, 227);
    BOOST_CHECK_EQUAL("März/April 2010", issue);
    Helper::GetIssueFromNumber(issue, 228);
    BOOST_CHECK_EQUAL("Mai/Juni 2010", issue);
    Helper::GetIssueFromNumber(issue, 229);
    BOOST_CHECK_EQUAL("Juli/August 2010", issue);
    Helper::GetIssueFromNumber(issue, 230);
    BOOST_CHECK_EQUAL("September/Oktober 2010", issue);
    Helper::GetIssueFromNumber(issue, 231);
    BOOST_CHECK_EQUAL("November/Dezember 2010", issue);

    Helper::GetIssueFromNumber(issue, 232);
    BOOST_CHECK_EQUAL("Januar/Februar 2011", issue);
    Helper::GetIssueFromNumber(issue, 233);
    BOOST_CHECK_EQUAL("März/April 2011", issue);
    Helper::GetIssueFromNumber(issue, 234);
    BOOST_CHECK_EQUAL("Mai/Juni 2011", issue);
    Helper::GetIssueFromNumber(issue, 235);
    BOOST_CHECK_EQUAL("Juli/August 2011", issue);
    Helper::GetIssueFromNumber(issue, 236);
    BOOST_CHECK_EQUAL("September/Oktober 2011", issue);
    Helper::GetIssueFromNumber(issue, 237);
    BOOST_CHECK_EQUAL("November/Dezember 2011", issue);

    Helper::GetIssueFromNumber(issue, "222");
    BOOST_CHECK_EQUAL("Mai/Juni 2009", issue);//"5", "2009"));
    Helper::GetIssueFromNumber(issue, "227");
    BOOST_CHECK_EQUAL("März/April 2010", issue); //"3", "2010"));
    Helper::GetIssueFromNumber(issue, "237");
    BOOST_CHECK_EQUAL("November/Dezember 2011", issue);
}
