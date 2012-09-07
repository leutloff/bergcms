/**
 * @file Helper.cpp
 * Some static helper methods.
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

#include <Helper.h>
#include <boost/lexical_cast.hpp>
#include <sstream>

using namespace std;
using namespace berg;

//static const std::string MONTHS_en[] = { "Jan", "Feb", "Mar", "April", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec" };
static const std::string MONTHS_de[] = { "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" };

unsigned Helper::GetNumberFromMonthYear(std::string const& month, std::string const& year)
{
    // $NUMMER=($Jahr-1972)*6+($Monat+1)/2-3;
    unsigned yearNumber = boost::lexical_cast<unsigned>(year);
    unsigned monthNumber = boost::lexical_cast<unsigned>(month);
    return (yearNumber-1972)*6+(monthNumber+1)/2-3;;
}

void Helper::GetIssueFromNumber(std::string & issue, unsigned number)
{
    ostringstream oss;
    const unsigned month = GetMonthFromNumber(number);
    oss << MONTHS_de[month-1] << "/" <<  MONTHS_de[month]  << " " << GetYearFromNumber(number);
    issue = oss.str();
}

void Helper::GetIssueFromNumber(std::string & issue, std::string const& number)
{
    GetIssueFromNumber(issue, boost::lexical_cast<unsigned>(number));
}

// unsigned Helper::GetMonthFromNumber(unsigned number)
// {
//    unsigned month = ((number + 3) % 6) * 2;
//    return (0 == month) ? 11 : month - 1;
// }

// unsigned Helper::GetYearFromNumber(unsigned number)
// {
//     return 1972 + (number + 2) / 6;
// }
