/**
 * @file Article.h
 * A single Article.
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

#if !defined(BERG_ARTICLE_H)
#define BERG_ARTICLE_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#   pragma once
#endif

#include "BoostFlags.h"
#include <boost/algorithm/string.hpp>
#include <boost/property_tree/ptree.hpp>

#include <limits>
#include <string>

namespace berg
{

/**
 * Single Article with all the elements stored in the text database.
 * The elements are separated by a Tab.
 */
class Article
{
private:
    unsigned id;
    int priority;
    std::string type;
    std::string chapter;
    std::string title;
    std::string header;
    std::string body;
    std::string footer;
    std::string lastChanged;

    static const std::string ITEM_SEPARATOR;
    static const size_t      INCREMENT_LINECOUNT_FOR_DISPLAY;

public:
    Article(unsigned newId) { id = newId; priority = -1; type = "A"; }
    Article() : Article (std::numeric_limits<unsigned>::max()) {}
    /// Parses the given article and stores the artifacts in the attributes.
    Article(std::string wholeArticle);
    ~Article()
    {
    }

    /// This is the opposite operation of the constructor.
    void GetArticleForFileStorage(std::string & wholeArticle) const;

    /// Prepares the item for storage, e.g. replace new line/line feed and tabulators.
    static std::string PrepareForFileStorage(std::string const& item)
    {
        std::string ret = boost::replace_all_copy(item, "\n", "<br>");
        ret = boost::replace_all_copy(ret, "\t", "<tab>");
        return ret;
    }


    /// Reverts the replacements of PrepareForFileStorage.
    static std::string UndoPrepareForFileStorage(std::string const& item)
    {
        // $wert=~s/\<br\>/\x0a/g;#LF aus <br> erzeugen
        std::string ret = boost::replace_all_copy(item, "<br>", "\n"); // LF \n \x0a
        ret = boost::replace_all_copy(ret, "<tab>", "\t");
        return ret;
    }

    /**
      * Returns the expected number of lines when displayed in the Browser.
      * @param articlePart one of header, body or footer of the article.
      * @returns number of lines
      */
    static size_t CountDisplayedLines(std::string const& articlePart);

    /**
     * @brief Merges the newArticle into this article. The old article was the starting point when changing to new article.
     * @param newArticle this the desired article
     * @param oldArticle was the starting point
     * @return true when merge was successful.
     */
    bool Merge(Article const& newArticle, Article const& oldArticle);

    /**
     * @brief SetFromJSON sets the whole article from the JSON object (as string).
     * Calls SetFromJSON(ptree).
     * @param jsonArticle the article in a string
     */
    void SetFromJSON(std::string const& jsonArticle);

    /**
     * @brief SetFromJSON sets the whole article from the JSON object.
     * @param json the JSON object
     */
    void SetFromJSON(boost::property_tree::ptree const& tree);

    /**
     * @brief GetAsJSON returns the article as JSON object.
     * @return The article formatted as JSON object.
     */
    void GetAsJSON(std::string &jsonArticle) const;

    /**
     * @brief Get returns the article as property tree object.
     * @return The article formatted as property tree object.
     *         This can then be written as JSON or XML.
     */
    boost::property_tree::ptree Get() const;

    std::string getBody() const
    {
        return body;
    }

    std::string getChapter() const
    {
        return chapter;
    }

    std::string getFooter() const
    {
        return footer;
    }

    std::string getHeader() const
    {
        return header;
    }

    unsigned getId() const
    {
        return id;
    }

    std::string getLastChanged() const
    {
        return lastChanged;
    }

    int getPriority() const
    {
        return priority;
    }

    std::string getTitle() const
    {
        return title;
    }

    std::string getType() const
    {
        return type;
    }

    void setBody(std::string body)
    {
        this->body = body;
    }

    void setChapter(std::string chapter)
    {
        this->chapter = chapter;
    }

    void setFooter(std::string footer)
    {
        this->footer = footer;
    }

    void setHeader(std::string header)
    {
        this->header = header;
    }

    void setId(unsigned id)
    {
        this->id = id;
    }

    void setLastChanged(std::string lastChanged)
    {
        this->lastChanged = lastChanged;
    }

    void setPriority(int priority)
    {
        this->priority = priority;
    }

    void setTitle(std::string title)
    {
        this->title = title;
    }

    void setType(std::string type)
    {
        this->type = type;
    }

};


}// namespace berg

#endif // BERG_ARTICLE_H
