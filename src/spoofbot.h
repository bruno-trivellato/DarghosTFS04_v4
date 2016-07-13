#ifndef FS_SPOOFBOT_H
#define FS_SPOOFBOT_H

#include "player.h"
#include "spoof.h"

typedef std::map<uint32_t, time_t> EnemyMap;

class PlayerBot : public Player
{
    public:
        explicit PlayerBot(const std::string& name, ProtocolGame* p);
        ~PlayerBot();

        // non-copyable
        PlayerBot(const PlayerBot&) = delete;
        PlayerBot& operator=(const PlayerBot&) = delete;

        PlayerBot* getBot() final {
            return this;
        }
        const PlayerBot* getBot() const final {
            return this;
        }

        void onLoad();
        void onExiva(Player* player);
        void onAutoWalk();
        void placeOnMap();
        bool remove();
        void onAttacked(Creature* creature);
        void onThink();
        void unPause();
        bool canDoNextAction();
        bool checkHeal();
        void onOutOfSync();
        void onCompleteMove();

        bool syncPath(RecordAction* nextAction);
        bool resume(uint32_t& delay);

        void lookAt(Player* actor, int32_t lookDistance);
        std::string logHeader();

        Creature* findTarget();
        void updateTargetList();
        void onCreatureAppear(const Creature* creature);

    private:
        EnemyMap m_enemies;
        uint64_t m_loginMicro;
        uint8_t m_outOfSync;
        time_t m_lastOutOfSync;
        uint32_t m_resumeTaskId;
        std::ostringstream m_logFile;
        uint32_t m_minutes;
        BotScript* m_botScript;

    friend class PlayerRecord;

};

#endif
