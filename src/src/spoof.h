#ifndef FS_SPOOF_H
#define FS_SPOOF_H

#include "enums.h"
#include "fileloader.h"
#include "position.h"

#define SPOOF_USE_RECORDS 0

enum BotScriptAction_t
{
	BSA_MOVE = 0,
	BSA_MOVE_DIR = 1,
	BSA_USE_MAP_ITEM = 2,
	BSA_USE_ROPE = 3,
	BSA_LOOP_START = 4,
	BSA_LOOP_END = 5
};

class PlayerBot;
class Player;
class PlayerRecord;
class NetworkMessage;
class BotScript;

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
    HourInfo(uint16_t _min, uint16_t _max){
        min = _min;
        max = _max;
    }

    uint16_t min;
    uint16_t max;
};

struct ScriptParam{
    Position pos;
    Direction dir;
};

typedef std::vector<uint32_t> PlayerIdVec;
typedef std::unordered_map<uint32_t, HourInfo> HourMap;
typedef std::map<PlayerRecord*, uint32_t> RecordList;
typedef std::deque<RecordAction> RecordActionList;

typedef std::pair<BotScriptAction_t, ScriptParam> ScriptParam_t;
typedef std::vector<ScriptParam_t> ScriptList;
typedef std::map<std::string, BotScript> BotScriptsList;

class BotScript{
    public:
        BotScript(std::string _name){
            name = _name;
            looping = false;
            loop_start = loop_end = 0;
            list_pos = 0;
        }

        BotScript(){
            loop_start = loop_end = 0;
            list_pos = 0;
        }

        bool hasNextStep();
        ScriptParam_t getNextStep();
        void save();
        bool loadStream(PropStream& stream);

    private:
        std::string name;
        bool looping;
        Position start_pos;
        uint32_t loop_start, loop_end;
        ScriptList list;
        uint32_t list_pos;
        std::list<uint32_t> botsUsing;

    friend class SpoofScripts;
    friend class PlayerBot;
    friend class LuaInterface;
    friend class IOLoginData;
};

class SpoofScripts{
    public:
        SpoofScripts(){
            current = nullptr;
        }

        bool newBotScript(std::string name);
        bool botScriptStartPosition(Position pos);
        bool botScriptMove(Position pos);
        bool botScriptMoveDir(Direction dir);
        bool botScriptUseMapItem(Position pos);
        bool botScriptUseRope(Position pos);
        bool botScriptStartLoop();
        bool botScriptEndLoop();
        bool botScriptFinished();
        void load(std::string name);
        BotScript* assignScript();

    private:
        BotScript* current;
        BotScriptsList list;

    friend class LuaInterface;
    friend class PlayerBot;
};

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

