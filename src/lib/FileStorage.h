/**
 * @file FileStorage.h
 * Storage related class.
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

#if !defined(BERG_STORAGE_H)
#define BERG_STORAGE_H

#include "Article.h"
#include "Filter.h"

#define BOOST_SYSTEM_NO_DEPRECATED
#include <boost/shared_ptr.hpp>
#include <boost/date_time/posix_time/posix_time_types.hpp> //no i/o just types
#include <ctemplate/template_dictionary.h>

#include <string> 
#include <vector>

namespace berg
{

class FileStorage
{
public:
    /// Wait at most ms to get access to the FileStorage file for reading or writing.
    static const int WAIT_FOR_FILE_LOCK_TIMEOUT_ms = 5000;

private:
    typedef std::vector<boost::shared_ptr<Article> > TArticles;
    TArticles articles;
    unsigned lastArticleId;
    std::string storageName; ///< archive including path and extension
    std::string archiveName; ///< name of the archive used for references

    boost::shared_ptr<IFilter> filter;

public:
    FileStorage() : lastArticleId(0), storageName(), filter( new FilterAcceptsAll())
    {
    }
    ~FileStorage()
    {
    }

    void SetFilter(boost::shared_ptr<IFilter> const& filterToUse) { filter = filterToUse; }

    void Load(std::string const& filename);
    void Save(std::string const& filename) const;

    Article const& GetArticle(unsigned no) const;
    Article const& GetArticle(std::string const& no) const;
    void SetArticle(unsigned no, Article const& article);

    /**
     * Adds the Body related content to the dictionary.
     */
    void FillDictionaryBody(ctemplate::TemplateDictionary & dict) const;

private:
    void ResetLastArticleId() { lastArticleId = 0; }
    void SetLastArticleId(unsigned id)
    {
        if (id > lastArticleId) { lastArticleId = id; }
    }
};

} // namespace berg

#endif // FILE_STORAGE_H