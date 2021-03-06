/*
 * @file Archive.h
 * This class implements the REST interface for the article specific functions.
 *
 * Copyright 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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
#ifndef RESTARTICLE_H
#define RESTARTICLE_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include "FileStorage.h"
#include <boost/cgi/cgi.hpp>
#include <string>

namespace bergcms
{

class RestArticle
{
    berg::FileStorage storage;

public:
    RestArticle(std::string const& database);
    void dispatchArticles(boost::cgi::request & req, boost::cgi::response & resp);

private:
    int getArticleId(boost::cgi::request & req);

    void getAll(boost::cgi::request & req, boost::cgi::response &resp);
    void getSingle(boost::cgi::request & req, boost::cgi::response &resp);

    void post(boost::cgi::request & req, boost::cgi::response &resp);
    void put(boost::cgi::request & req, boost::cgi::response &resp);
    void deleteSingle(boost::cgi::request & req, boost::cgi::response &resp);

    void extractArticles(boost::cgi::request & req, berg::Article & newArticle, berg::Article & oldArticle);
};

}

#endif // RESTARTICLE_H
