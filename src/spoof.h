#ifndef FS_SPOOF_H
#define FS_SPOOF_H

#include "enums.h"
#include "fileloader.h"

class PlayerBot;
class Player;
class PlayerRecord;
class NetworkMessage;

class RecordAction{

    public:
        RecordAction(){
            action = 0;
            timestamp = 0;
            msgSize = 0;
            msg = nullptr;
            posx = 0;
            posy = 0;
            posz = 0;
        }

        void _free(){
            free(msg);
        }

        uint8_t action;
        uint64_t timestamp;
        uint32_t msgSize;
        char* msg;
        uint32_t posx;
        uint32_t posy;
        uint16_t posz;
};

struct HourInfo{
    HourInfo(uint8_t _min, uint8_t _max){
        min = _min;
        max = _max;
    }

    uint8_t min;
    uint8_t max;
};

typedef std::vector<uint32_t> PlayerIdVec;
typedef std::unordered_map<uint32_t, HourInfo> HourMap;
typedef std::map<PlayerRecord*, uint32_t> RecordList;
typedef std::deque<RecordAction> RecordActionList;

class Spoof
{
    public:
        Spoof();

        bool onStartup();
        void onThink();
        void loginPlayer(Player* player);
        void checkBotIdResume(uint32_t player_id);
        void checkBotResume(PlayerBot* bot);
        void updateExpectedCount();

        void loadBot();

        uint32_t KICKS_COUNT;
        uint32_t CURRENT_RECORD;
        uint32_t LOGINS_COUNT;
        uint32_t OUTSYNC_COUNT;

    private:
        PlayerIdVec m_players;
        HourMap m_hours;
        time_t m_startTime;
        uint32_t m_expectedSpoofCount;
        time_t m_lastStatistcMessage;
        time_t m_lastUpdateExpectedCount;
        RecordList m_records;

    friend class PlayerBot;
};

enum RecordAttr{
    RecordAttr_Action = 1,
    RecordAttr_Timestamp,
    RecordAttr_DataSize,
    RecordAttr_Data,
    RecordAttr_End,
    RecordAttr_Move,
};

class PlayerRecord
{
    public:
        PlayerRecord();
        ~PlayerRecord();

        void onDoAction(uint8_t action, NetworkMessage& msg);
        void onLogout();
        void onLoad();
        bool readNextAction(PropStream& propStream, RecordAction& m_nextAction);
        void logProgress();

    private:
        uint32_t m_id;
        uint32_t m_playerId;
        uint64_t m_date;
        uint32_t m_levelLogin;
        uint32_t m_levelLogout;
        PropWriteStream m_data;
        PropStream m_dataRead;
        RecordActionList m_actions;
        uint32_t m_posx, m_posy;
        uint16_t m_posz;
        Player* m_player;
        bool m_pause;
        RecordAction* m_lastAction;
        RecordActionList::iterator m_iterator;
        uint64_t m_recordDuration;
        uint64_t m_ignoredPackets;

    friend class IOLoginData;
    friend class Spoof;
    friend class Player;
    friend class PlayerBot;
};

#endif

