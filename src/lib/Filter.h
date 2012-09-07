/*
 * @file Filter.h
 *
 * Implementations of the IFilter interface.
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

#ifndef FILTER_H_
#define FILTER_H_

#include <IFilter.h>
#include <boost/foreach.hpp>
#include <vector>

namespace berg
{

/**
 * Accepts all Articles.
 */
class FilterAcceptsAll: public IFilter
{
public:
    FilterAcceptsAll()
    {
    }
    virtual bool IsMatching(Article const& article)const
    {
        return true;
    }
};

/**
 * Accepts only active Articles, that are used for the current edition.
 */
class FilterIsActive: public IFilter
{
public:
    FilterIsActive()
    {
    }
    virtual bool IsMatching(Article const& article) const
    {
        return article.getPriority() >= 0;
    }
};

/**
 * Accepts only Articles with one of the given chapter names.
 */
class FilterHasSpecificChapterName: public IFilter
{
    std::vector<std::string> chapterNames;
public:
    FilterHasSpecificChapterName(std::string const& chapterName)
    {
        AddChapterName(chapterName);
    }
    FilterHasSpecificChapterName(std::vector<std::string> const& names)
    {
        chapterNames.reserve(names.size());
        std::copy(names.begin(),names.end(),std::back_inserter(chapterNames));
    }

    void AddChapterName(std::string const& chapterName)
    {
        chapterNames.push_back(chapterName);
    }

    virtual bool IsMatching(Article const& article)const
    {
        BOOST_FOREACH(std::string chapterName, chapterNames)
        {
            if (article.getChapter() == chapterName)
            {
                return true;
            }
        }
        return false;
    }
};

} // namespace berg

#endif /* FILTER_H_ */
