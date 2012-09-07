/**
 * @file IFilter.h
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

#ifndef IFILTER_H_
#define IFILTER_H_

#include "Article.h"

namespace berg
{

/**
 * Interface definition (aka abstract class) for the different filters used to select types of articles.
 * This filter is applied directly after reading the Article just before it is stored in the storage.
 */
class IFilter
{
public:
    virtual ~IFilter() {}

    /**
     * Returns true, if the given Article should be stored for further processing.
     * @param article to inspect
     * @returns true, if the Article matches the Filter.
     */
    virtual bool IsMatching(Article const& article) const = 0;

};

} // namespace berg

#endif /* IFILTER_H_ */
