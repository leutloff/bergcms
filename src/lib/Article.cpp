/**
 * @file Article.cpp
 * Article related methods.
 *
 * Copyright 2012, 2013, 2016 Christian Leutloff <leutloff@sundancer.oche.de>
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

#include <boost/algorithm/string.hpp>
#include <boost/foreach.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/tokenizer.hpp>
#include <algorithm>
#include <limits>
#include <sstream>
#include <vector>

using namespace std;
using namespace berg;
#if defined(USE_CTEMPLATE)
namespace tpl = ctemplate;
#endif
namespace pt = boost::property_tree;


const std::string Article::ITEM_SEPARATOR = "\t";
const size_t      Article::INCREMENT_LINECOUNT_FOR_DISPLAY = 3;

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

// #if defined(USE_CTEMPLATE)
// void Article::FillDictionaryBody(ctemplate::TemplateDictionary & dict) const
// {
//     dict.SetValue("ARTICLE_ID", boost::lexical_cast<string>(id));
//     dict.SetValue("ARTICLE_CHAPTER", chapter);
//     dict.SetValue("ARTICLE_PRIORITY", boost::lexical_cast<string>(priority));
//     dict.SetValue("ARTICLE_TITLE", title);
//     dict.SetValue("ARTICLE_TYPE", type);

//     dict.SetValue("ARTICLE_HEADER", header);
//     unsigned lines = CountDisplayedLines(header) + INCREMENT_LINECOUNT_FOR_DISPLAY;
//     dict.SetValue("ARTICLE_HEADER_LINES", boost::lexical_cast<string>(lines));

//     dict.SetValue("ARTICLE_BODY", body);
//     lines = CountDisplayedLines(body) + INCREMENT_LINECOUNT_FOR_DISPLAY;
//     dict.SetValue("ARTICLE_BODY_LINES", boost::lexical_cast<string>(lines));

//     dict.SetValue("ARTICLE_FOOTER", footer);
//     lines = CountDisplayedLines(footer) + INCREMENT_LINECOUNT_FOR_DISPLAY;
//     dict.SetValue("ARTICLE_FOOTER_LINES", boost::lexical_cast<string>(lines));

//     dict.SetValue("ARTICLE_LASTCHANGED", lastChanged);
// }
// #endif

size_t Article::CountDisplayedLines(std::string const& articlePart)
{
    unsigned cnt = 1;
    // count wrapped lines
    typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
    boost::char_separator<char> sep("\n");
    tokenizer tokens(articlePart, sep);
    BOOST_FOREACH (string const& paragraph, tokens)
    {
        cnt += paragraph.length() / 100; // this assumes 100 chars per displayed line
    }
    // count line breaks itself
    cnt += std::count(articlePart.begin(), articlePart.end(), '\n');
    return cnt;
}

void Article::SetFromJSON(const string &jsonArticle)
{
    pt::ptree tree;
    istringstream iss(jsonArticle);
    pt::read_json(iss, tree);

//    id = tree.get<unsigned>("article.id");
//    priority = tree.get<int>("article.priority", 100);
//    type = tree.get("article.type", "A");
//    chapter = tree.get("article.chapter", "");
//    title = tree.get("article.title", "");
//    header = tree.get("article.header", "");
//    body = tree.get("article.body", "");
//    footer = tree.get("article.footer", "");
//    lastChanged = tree.get("article.lastChanged", "");

    id = tree.get<unsigned>("id", numeric_limits<unsigned>::max());
    priority = tree.get<int>("priority", 100);
    type = tree.get("type", "A");
    chapter = tree.get("chapter", "");
    title = tree.get("title", "");
    header = tree.get("header", "");
    body = tree.get("body", "");
    footer = tree.get("footer", "");
    lastChanged = tree.get("lastChanged", "");
}

///**
// * @brief AddJsonValue writes the value w/o quotes.
// */
//void AddJsonValue(ostream & os, string const& name, string const& value, bool isLastElement = false)
//{
//    os << "    \"" << name << "\": " << value;
//    if (!isLastElement) { os << ","; }
//    os << "\r\n";
//}
///**
// * @brief AddJsonQuotedValue writes the element as quoted value.
// */
//void AddJsonQuotedValue(ostream & os, string const& name, string const& value, bool isLastElement = false)
//{
//    string quoted = "\"" + value + "\"";
//    AddJsonValue(os, name, quoted, isLastElement);
//}

//void Article::GetAsJSON(std::string & jsonArticle) const
//{
//    jsonArticle.clear();
//    ostringstream oss;
//    oss << "{" << "\r\n";
//    AddJsonValue(oss, "id", boost::lexical_cast<string>(id));
//    AddJsonValue(oss, "priority", boost::lexical_cast<string>(priority));
//    AddJsonQuotedValue(oss, "type", type);
//    AddJsonQuotedValue(oss, "chapter", chapter);
//    AddJsonQuotedValue(oss, "title", title);
//    AddJsonQuotedValue(oss, "header", header);
//    AddJsonQuotedValue(oss, "body", body);
//    AddJsonQuotedValue(oss, "footer", footer);
//    AddJsonQuotedValue(oss, "lastChanged", lastChanged, true);
//    oss << "}";
//    jsonArticle = oss.str();
//}

void Article::GetAsJSON(std::string & jsonArticle) const
{
    jsonArticle.clear();
    pt::ptree tree;
    tree.put("id", id);
    tree.put("priority", priority);
    tree.put("type", type);
    tree.put("chapter", chapter);
    tree.put("title", title);
    tree.put("header", header);
    tree.put("body", body);
    tree.put("footer", footer);
    tree.put("lastChanged", lastChanged);
    ostringstream oss;
    pt::write_json(oss, tree);
    jsonArticle = oss.str();
}

boost::property_tree::ptree Article::Get() const
{
    pt::ptree tree;
    tree.put("id", id);
    tree.put("priority", priority);
    tree.put("type", type);
    tree.put("chapter", chapter);
    tree.put("title", title);
    tree.put("header", header);
    tree.put("body", body);
    tree.put("footer", footer);
    tree.put("lastChanged", lastChanged);
    return tree;
}
