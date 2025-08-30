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

#ifndef __SCHEDULER__
#define __SCHEDULER__
#include "otsystem.h"
#include "dispatcher.h"

#include <unordered_set>

#define SCHEDULER_MINTICKS 50

class SchedulerTask : public Task
{
    public:
        void setEventId(uint32_t id) {
            eventId = id;
        }
        uint32_t getEventId() const {
            return eventId;
        }

        std::chrono::system_clock::time_point getCycle() const {
            return expiration;
        }

    protected:
        SchedulerTask(uint32_t delay, const std::function<void (void)>& f) : Task(delay, f) {
            eventId = 0;
        }

        uint32_t eventId;

        friend SchedulerTask* createSchedulerTask(uint32_t, const std::function<void (void)>&);
};

inline SchedulerTask* createSchedulerTask(uint32_t delay, const std::function<void (void)>& f)
{
    return new SchedulerTask(std::max<uint32_t>(delay, SCHEDULER_MINTICKS), f);
}

struct TaskComparator {
    bool operator()(const SchedulerTask* lhs, const SchedulerTask* rhs) const {
        return lhs->getCycle() > rhs->getCycle();
    }
};

class Scheduler
{
    public:
        Scheduler();

        uint32_t addEvent(SchedulerTask* task);
        bool stopEvent(uint32_t eventId);

        void start();
        void stop();
        void shutdown();
        void join();

    protected:
        void schedulerThread();
        void setState(ThreadState newState) {
            threadState.store(newState, std::memory_order_relaxed);
        }

        ThreadState getState() const {
            return threadState.load(std::memory_order_relaxed);
        }

        std::thread thread;
        std::mutex eventLock;
        std::condition_variable eventSignal;

        uint32_t lastEventId;
        std::priority_queue<SchedulerTask*, std::deque<SchedulerTask*>, TaskComparator> eventList;
        std::unordered_set<uint32_t> eventIds;
        std::atomic<ThreadState> threadState{THREAD_STATE_TERMINATED};
};

extern Scheduler g_scheduler;
#endif
