/**
 * @file FileStorage.cpp
 * Storage related methods.
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

#include "FileStorage.h"
#include "Archive.h"
#include "BoostFlags.h"

#include <boost/filesystem.hpp>
#include <boost/interprocess/sync/file_lock.hpp>
#include <boost/interprocess/sync/scoped_lock.hpp>
#include <boost/interprocess/sync/sharable_lock.hpp>
#include <fstream>
#include <iostream>

using namespace std;
using namespace berg;
namespace fs = boost::filesystem;
namespace ip = boost::interprocess;
#if defined(USE_CTEMPLATE)
namespace tpl = ctemplate;
#endif

void FileStorage::Load(std::string const& filename)
{
    storageName = filename;
    if (!fs::exists(storageName))
    {
        if (fs::exists(storageName + ".csv"))
        {
            storageName += ".csv";
        }
        else
        {
            // TODO log throw("Die Datenbankdatei " + filename + " existiert nicht!");
            CreateEmptyDatabase(storageName);
        }
    }
    archiveName = Archive::GetArchiveNameFromPath(storageName);
    ResetLastArticleId();
    string line;
    ifstream db(storageName.c_str());
    if (db.is_open())
    {
        ip::file_lock fileLock(storageName.c_str()); //Open the file lock
        {
            // Sharable lock for concurrent reading
            ip::sharable_lock<ip::file_lock> sharedLock(fileLock);//,boost::posix_time::milliseconds(WAIT_FOR_FILE_LOCK_TIMEOUT_ms));
            while (db.good())
            {
                getline(db, line);
                if (0 < line.size())
                {
                    boost::shared_ptr<Article> article(new Article(line));
                    SetLastArticleId(article->getId());
                    if (filter->IsMatching(*article))
                    {
                        articles.push_back(article);
                        //cout << line << endl;
                    }
                }
            }
            db.close();
        }
    }
}

void FileStorage::Save(std::string const& filename) const
{
    ofstream db(filename.c_str());
    if (db.is_open())
    {
        ip::file_lock fileLock(filename.c_str()); //Open the file lock
        {
            string wholeArticle = "";
            // Scoped lock for exclusive access for writing
            ip::scoped_lock<ip::file_lock> scopedLock(fileLock);//,boost::posix_time::milliseconds(WAIT_FOR_FILE_LOCK_TIMEOUT_ms));
            for (TArticles::const_iterator it = articles.begin(); it < articles.end(); ++it)
            {
                (*it)->GetArticleForFileStorage(wholeArticle);
                db << wholeArticle << endl;
            }
            db.flush(); // flush before lock is freed.
        }
        db.close();
    }
}

void FileStorage::CreateEmptyDatabase (std::string const& filename)
{
    ofstream db(filename);
    Article empty(0); // Article 0 is reserved for configuration parameters.
    string wholeArticle = "";
    empty.GetArticleForFileStorage(wholeArticle);
    db << wholeArticle << endl;
    db.close();
}

Article const& FileStorage::GetArticle(unsigned no) const
{
    for (TArticles::const_iterator it = articles.begin(); it < articles.end(); ++it)
    {
        if (no == (*it)->getId())
        {
            return *(*it);
        }
    }
    throw "Article Number " + boost::lexical_cast<string>(no) + " does not exists.";
}

void FileStorage::NewArticle(Article & article)
{
    ++lastArticleId;
    article.setId(lastArticleId);
    boost::shared_ptr<Article> newArticle(new Article(article));
    articles.push_back(newArticle);
    Save();
}

void FileStorage::SetArticle(unsigned no, Article const& article)
{
    for (auto it = articles.begin(); it < articles.end(); ++it)
    {
        if (no == (*it)->getId())
        {
            *(*it) = article;
            Save();
            return;
        }
    }
    throw "Article Number " + boost::lexical_cast<string>(no) + " does not exists. Article not saved.";
}

void FileStorage::DeleteArticle(unsigned no)
{
    for (TArticles::iterator it = articles.begin(); it < articles.end(); ++it)
    {
        if ((*it)->getId() == no)
        {
            articles.erase(it);
            Save();
            return;
        }
    }
}

// #if defined(USE_CTEMPLATE)
// void FileStorage::FillDictionaryBody(ctemplate::TemplateDictionary & dict) const
// {
//     string id;
//     for (TArticles::const_iterator it = articles.begin(); it < articles.end(); ++it)
//     {
//         id = boost::lexical_cast<string>((*it)->getId());
//         tpl::TemplateDictionary* list = dict.AddSectionDictionary("ARTICLE_LIST");
// //        list->SetValue("ARTICLE_TITLE",(*it)->getTitle());
// //        list->SetValue("ARTICLE_NUMBER", id);
//         list->SetValue("ARTICLE_REFERENCE", "?archive=" + archiveName + "&article=" + id);
//         (*it)->FillDictionaryBody(*list);
//     }
// }
// #endif
