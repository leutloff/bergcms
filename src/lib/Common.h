/**
 * @file Common.h
 * Some static shared methods.
 * 
 * Copyright 2012, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#if !defined(BERG_COMMON_H)
#define BERG_COMMON_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include "BoostFlags.h"
#include <boost/cgi/cgi.hpp>
#include <boost/function.hpp>
#if defined(USE_CTEMPLATE)
#include <ctemplate/template_dictionary.h>
#endif
#include <string>

namespace berg
{

/**
 * Some static shared methods.
 */
class Common
{
public:

#if defined(USE_CTEMPLATE)
    /**
     * Adds the Common strings to the dictionary, like System title
     * version and copyright information.
     */
    static void FillDictionaryCommon(ctemplate::TemplateDictionary & dict);

    /**
     * Adds the Head related content to the dictionary.
     */
    static void FillDictionaryHead(ctemplate::TemplateDictionary & dict);

#endif

    /**
      * Returns the full path to the template.
      * Searches in some predefined locations.
      *
      * @param templateBase the templates file name.
      * @return the full path to the template.
      */
    static std::string GetTemplate(std::string const& templateBase);

    /**
      * Calls the given handler.
      * Any exception is convertet into an error page or standard output.
      * @param handler to process the CGI input.
      * @return CGI program exit code.
      */
    static int InvokeWithErrorHandling(boost::function<int (boost::cgi::request& req)> handler);

    /**
      * Sends the errors formatted back to the browser.
      * @return CGI program exit code.
      */
    static int SendErrorPage(boost::cgi::request& req, std::string const& errorType, std::string const& errorMsg);

    /**
      * Sends the response back to the browser.
      * @return CGI program exit code.
      */
    static int SendResponse(boost::cgi::request& req, std::string const& output);

    /**
      * Returns Library Version.
      */
    static std::string GetBergVersion();

    /**
      * Returns the last changed date of the Library.
      */
    static std::string GetBergLastChangedDate();

};

}


#endif // BERG_COMMON_H
