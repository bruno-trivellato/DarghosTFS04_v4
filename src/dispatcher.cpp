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
#include "dispatcher.h"

#include "outputmessage.h"
#if defined __EXCEPTION_TRACER__
#include "exception.h"
#endif

#include "game.h"
extern Game g_game;

void Dispatcher::start()
{
    setState(THREAD_STATE_RUNNING);
    thread = std::thread(&Dispatcher::dispatcherThread, this);
}

void Dispatcher::dispatcherThread()
{
    OutputMessagePool* outputPool = OutputMessagePool::getInstance();

    // NOTE: second argument defer_lock is to prevent from immediate locking
    std::unique_lock<std::mutex> taskLockUnique(taskLock, std::defer_lock);

    while (getState() != THREAD_STATE_TERMINATED) {
        // check if there are tasks waiting
        taskLockUnique.lock();

        if (taskList.empty()) {
            //if the list is empty wait for signal
            taskSignal.wait(taskLockUnique);
        }

        if (!taskList.empty()) {
            // take the first task
            Task* task = taskList.front();
            taskList.pop_front();
            taskLockUnique.unlock();

            if (!task->hasExpired()) {
                // execute it
                outputPool->startExecutionFrame();
                (*task)();
                outputPool->sendAll();

                g_game.map->clearSpectatorCache();
            }
            delete task;
        } else {
            taskLockUnique.unlock();
        }
    }
}

void Dispatcher::addTask(Task* task, bool push_front /*= false*/)
{
    bool do_signal = false;

    taskLock.lock();

    if (getState() == THREAD_STATE_RUNNING) {
        do_signal = taskList.empty();

        if (push_front) {
            taskList.push_front(task);
        } else {
            taskList.push_back(task);
        }
    } else {
        delete task;
    }

    taskLock.unlock();

    // send a signal if the list was empty
    if (do_signal) {
        taskSignal.notify_one();
    }
}

void Dispatcher::stop()
{
    setState(THREAD_STATE_CLOSING);
}

void Dispatcher::shutdown()
{
    Task* task = createTask([this]() {
        setState(THREAD_STATE_TERMINATED);
        taskSignal.notify_one();
    });

    std::lock_guard<std::mutex> lockGuard(taskLock);
    taskList.push_back(task);

    taskSignal.notify_one();
}

void Dispatcher::join()
{
    if (thread.joinable()) {
        thread.join();
    }
}
