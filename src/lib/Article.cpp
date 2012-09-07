/**
 * @file Article.cpp
 * Article related methods.
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

#include "Article.h"
#include "BoostFlags.h"

#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>
#include <sstream>

using namespace std;
using namespace berg;
namespace tpl = ctemplate;

const std::string Article::ITEM_SEPARATOR = "\t";

Article::Article(std::string wholeArticle)
{
    std::vector<std::string> parts;
    boost::split(parts, wholeArticle, boost::is_any_of(ITEM_SEPARATOR));
    if (9 != parts.size())
    {
        ostringstream oss;
        oss << "Invalid Format: Unexpected amount of fields. Expected: " << 9 << " Detected: " << parts.size()
            << ends;
        throw oss.str();
    }
    try
    {
        boost::trim(parts[0]);
        id = boost::lexical_cast<unsigned>(parts[0]);
    }
    catch(boost::bad_lexical_cast &)
    {
        id = -1;
    }
    chapter = UndoPrepareForFileStorage(parts[1]);
    try
    {
        boost::trim(parts[2]);
        priority = boost::lexical_cast<int>(parts[2]);
    }
    catch(boost::bad_lexical_cast &)
    {
        priority = -1;
    }
    title = UndoPrepareForFileStorage(parts[3]);
    type = UndoPrepareForFileStorage(parts[4]);
    header = UndoPrepareForFileStorage(parts[5]);
    body = UndoPrepareForFileStorage(parts[6]);
    footer = UndoPrepareForFileStorage(parts[7]);
    lastChanged = UndoPrepareForFileStorage(parts[8]);
}

void Article::GetArticleForFileStorage(std::string & wholeArticle) const
{
    ostringstream oss;
    wholeArticle.clear();
    oss << boost::lexical_cast<string>(id) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(chapter) << ITEM_SEPARATOR;
    oss << boost::lexical_cast<string>(priority) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(title) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(type) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(header) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(body) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(footer) << ITEM_SEPARATOR;
    oss << PrepareForFileStorage(lastChanged);// << ITEM_SEPARATOR; - no further separator because field check in constructor will fail otherwise
    wholeArticle = oss.str();
}

void Article::FillDictionaryBody(ctemplate::TemplateDictionary & dict) const
{
    dict.SetValue("ARTICLE_ID", boost::lexical_cast<string>(id));
    dict.SetValue("ARTICLE_CHAPTER", chapter);
    dict.SetValue("ARTICLE_PRIORITY", boost::lexical_cast<string>(priority));
    dict.SetValue("ARTICLE_TITLE", title);
    dict.SetValue("ARTICLE_TYPE", type);
    dict.SetValue("ARTICLE_HEADER", header);
    dict.SetValue("ARTICLE_BODY", body);
    dict.SetValue("ARTICLE_FOOTER", footer);
    dict.SetValue("ARTICLE_LASTCHANGED", lastChanged);
}
