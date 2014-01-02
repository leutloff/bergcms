/**
 * @file Helper.h
 * Some static helper methods.
 * 
 * Copyright 2012, 2014 Christian Leutloff <leutloff@sundancer.oche.de>
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
#if !defined(BERG_HELPER_H)
#define BERG_HELPER_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include <string>

namespace berg
{

/**
 * Helper class.
 */
class Helper
{
public:
    // #3#2012 -> 239
    /**
      * Calculates the issue number from the given month and year.
      */
    static unsigned GetNumberFromMonthYear(std::string const& month, std::string const& year);

    /**
      * Calculates the month from the issue number.
      * @return 1,3,5,7,9 or 11
      */
    static unsigned GetMonthFromNumber(unsigned number)
    {
        unsigned month = ((number + 3) % 6) * 2;
        return (0 == month) ? 11 : month - 1;
    }

    /**
      * Calculates the year from the issue number.
      */
    static unsigned GetYearFromNumber(unsigned number)
    {
        return 1972 + (number + 2) / 6;
    }

    /**
      * returns the issue from the number, e.g.
      * for 237 it returns November/Dezember 2011.
      */
    static void GetIssueFromNumber(std::string & issue, unsigned number);
    static void GetIssueFromNumber(std::string & issue, std::string const& number);

};

}

#endif // BERG_HELPER_H
