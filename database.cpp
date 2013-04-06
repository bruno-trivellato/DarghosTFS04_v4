////////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#include <string>

#include "database.h"
#ifdef __USE_MYSQL__
#include "databasemysql.h"
#endif
#ifdef __USE_SQLITE__
#include "databasesqlite.h"
#endif
#ifdef __USE_PGSQL__
#include "databasepgsql.h"
#endif

#if defined MULTI_SQL_DRIVERS
#include "configmanager.h"
extern ConfigManager g_config;
#endif

boost::recursive_mutex DBQuery::databaseLock;
Database* _Database::_instance = NULL;

Database* _Database::getInstance()
{
	if(!_instance)
	{
#if defined MULTI_SQL_DRIVERS
#ifdef __USE_MYSQL__
		if(g_config.getString(ConfigManager::SQL_TYPE) == "mysql")
			_instance = new DatabaseMySQL;
#endif
#ifdef __USE_SQLITE__
		if(g_config.getString(ConfigManager::SQL_TYPE) == "sqlite")
			_instance = new DatabaseSQLite;
#endif
#ifdef __USE_PGSQL__
		if(g_config.getString(ConfigManager::SQL_TYPE) == "pgsql")
			_instance = new DatabasePgSQL;
#endif
#else
		_instance = new Database;
#endif
	}

	_instance->use();
	return _instance;
}

DBResult* _Database::verifyResult(DBResult* result)
{
	if(result->next())
		return result;

	result->free();
	result = NULL;
	return NULL;
}

DBInsert::DBInsert(Database* db)
{
	m_db = db;
	m_rows = 0;
	// checks if current database engine supports multiline INSERTs
	m_multiLine = m_db->getParam(DBPARAM_MULTIINSERT);

#ifdef __DARGHOS_THREAD_SAVE__
    useMultithreading = false;
#endif
}

void DBInsert::setQuery(const std::string& query)
{
	m_query = query;
	m_buf = "";
	m_rows = 0;
}

#ifdef __DARGHOS_THREAD_SAVE__
bool DBInsert::storeQuery(QueryWeight_t queryWeight/* = QUERY_WEIGHT_NORMAL*/)
{
	if(!m_multiLine || m_buf.length() < 1 || !m_rows) // INSERTs were executed on-fly or there's no rows to execute
		return true;

    switch(queryWeight)
    {
        case QUERY_WEIGHT_NORMAL:
        {
            normalQuerys.push_back(m_query + m_buf);
            break;
        }

        case QUERY_WEIGHT_HEAVY:
        {
            heavyQuerys.push_back(m_query + m_buf);
            break;
        }


        case QUERY_WEIGHT_LIGHT:
        {
            lightQuerys.push_back(m_query + m_buf);
            break;
        }

        default:
        {
            return false;
        }
    }

    m_rows = 0;
    m_buf = "";

    return true;
}

void DBInsert::runQueryList(QueryList& list)
{
    Database db;

    if(list.size() > 0)
    {
        QueryList::iterator it = list.begin();
        while(it != list.end())
        {
            if(!db.query(*it))
            {
                //std::clog << "Cannot execute threaded query: " << (*it) << std::endl;
            }

            it++;
        }

        list.clear();
    }
}

void DBInsert::runQuerys(QueryWeight_t queryWeight)
{
    switch(queryWeight)
    {
        case QUERY_WEIGHT_NORMAL:
        {
            runQueryList(normalQuerys);
            break;
        }

        case QUERY_WEIGHT_LIGHT:
        {
            runQueryList(lightQuerys);
            break;
        }

        case QUERY_WEIGHT_HEAVY:
        {
            runQueryList(heavyQuerys);
            break;
        }
    }

    boost::this_thread::at_thread_exit(boost::bind(&DBInsert::onThreadExit, this));
}

void DBInsert::onThreadExit()
{
    for(std::list<boost::thread*>::iterator it = threads.begin(); it != threads.end();)
    {
        if((*it)->get_id() == boost::this_thread::get_id())
        {
            threads.erase(it);
            delete (*it);

            break;
        }

        it++;
    }
}

void DBInsert::runThreadedQuerys()
{
    std::clog << "Running " << normalQuerys.size() << " normal querys, " << lightQuerys.size() << " light querys and " << heavyQuerys.size() << " heavy querys..." << std::endl;

    boost::thread* thread = new boost::thread(boost::bind(&DBInsert::runQuerys, this, QUERY_WEIGHT_NORMAL));
    threads.push_back(thread);

    thread = new boost::thread(boost::bind(&DBInsert::runQuerys, this, QUERY_WEIGHT_LIGHT));
    threads.push_back(thread);

    thread = new boost::thread(boost::bind(&DBInsert::runQuerys, this, QUERY_WEIGHT_HEAVY));
    threads.push_back(thread);
}
#endif

bool DBInsert::addRow(const std::string& row)
{

#ifdef __DARGHOS_THREAD_SAVE__
    if(!m_multiLine) // executes INSERT for current row
    {
        if(useMultithreading)
        {
            m_buf = "(" + row + ")";
            return storeQuery();
        }
        else
            return m_db->query(m_query + "(" + row + ")");

    }
#else
	if(!m_multiLine) // executes INSERT for current row
		return m_db->query(m_query + "(" + row + ")");
#endif

	m_rows++;
	int32_t size = m_buf.length();
	// adds new row to buffer
	if(!size)
		m_buf = "(" + row + ")";
	else if(size > 8192)
	{
		if(!execute())
			return false;

		m_buf = "(" + row + ")";
	}
	else
		m_buf += ",(" + row + ")";

	return true;
}

bool DBInsert::addRow(std::stringstream& row)
{
	bool ret = addRow(row.str());
	row.str("");
	return ret;
}

bool DBInsert::execute()
{
	if(!m_multiLine || m_buf.length() < 1 || !m_rows) // INSERTs were executed on-fly or there's no rows to execute
		return true;

#ifdef __DARGHOS_THREAD_SAVE__
    if(useMultithreading)
    {
        return storeQuery();
    }
#endif

	m_rows = 0;
	// executes buffer
	bool ret = m_db->query(m_query + m_buf);
	m_buf = "";
	return ret;
}
