#include "otpch.h"
#include "spoof.h"
#include "iologindata.h"
#include "game.h"
#include "spoofbot.h"

#include <fstream>

extern Game g_game;
extern Spoof g_spoof;

Spoof::Spoof(){
    m_startTime = time(nullptr);

    m_hours.emplace(5, HourInfo(30, 38));
    m_hours.emplace(6, HourInfo(35, 42));
    m_hours.emplace(7, HourInfo(45, 54));
    m_hours.emplace(8, HourInfo(57, 63));
    m_hours.emplace(9, HourInfo(67, 76));
    m_hours.emplace(10, HourInfo(76, 81));
    m_hours.emplace(11, HourInfo(84, 91));
    m_hours.emplace(12, HourInfo(87, 96));
    m_hours.emplace(13, HourInfo(92, 101));
    m_hours.emplace(14, HourInfo(96, 104));
    m_hours.emplace(15, HourInfo(95, 107));
    m_hours.emplace(16, HourInfo(97, 109));
    m_hours.emplace(17, HourInfo(101, 107));
    m_hours.emplace(18, HourInfo(105, 111));
    m_hours.emplace(19, HourInfo(107, 114));
    m_hours.emplace(20, HourInfo(109, 116));
    m_hours.emplace(21, HourInfo(111, 121));
    m_hours.emplace(22, HourInfo(102, 115));
    m_hours.emplace(23, HourInfo(94, 106));
    m_hours.emplace(0, HourInfo(81, 94));
    m_hours.emplace(1, HourInfo(55, 72));
    m_hours.emplace(2, HourInfo(44, 52));
    m_hours.emplace(3, HourInfo(37, 46));
    m_hours.emplace(4, HourInfo(25, 39));

    m_expectedSpoofCount = 0;

    KICKS_COUNT = 0;
    LOGINS_COUNT = 0;
    OUTSYNC_COUNT = 0;
    CURRENT_RECORD = 1;

    m_lastStatistcMessage = time(nullptr);
    m_lastUpdateExpectedCount = 0;
}

bool Spoof::onStartup(){
    return true;
}

void Spoof::onThink(){

    updateExpectedCount();

    if(m_players.size() >= m_expectedSpoofCount){

        uint32_t diff = m_players.size() - m_expectedSpoofCount;
        uint32_t max_chance = 100000;
        uint32_t chance2 = max_chance / std::max(diff, 1u);
        uint32_t rand = (uint32_t)random_range(1u, max_chance);

        if(rand >= chance2)
            return;
    }

    loadBot();

    time_t current = time(nullptr);
    if(m_lastStatistcMessage + 60 < current){
        float outSyncsPercent = (OUTSYNC_COUNT > 0) ? (((float)OUTSYNC_COUNT / (float)KICKS_COUNT) * 100) : 0;
        std::cout << "[Spoof System Statistics] Total logins: " << LOGINS_COUNT << ", Kicks count: " << KICKS_COUNT << ", OutSync: " << OUTSYNC_COUNT << " (" << std::round(outSyncsPercent) << "%)" << std::endl;

        uint32_t cleans = 0;
        uint32_t total = m_records.size();

        RecordList::iterator it;
        for (it=m_records.begin(); it!=m_records.end(); ++it){
            if(!g_game.getPlayerByGuid(it->second)){
                delete it->first;
                m_records.erase(it);
                cleans++;
            }
        }

        std::cout << "[Spoof System Statistics] Records unused deleted: " << cleans << "/" << total << std::endl;

        m_lastStatistcMessage = current;
    }
}

void Spoof::updateExpectedCount(){
    time_t current = time(nullptr);
    if(m_lastUpdateExpectedCount + (60 * 10) < current){
        m_lastUpdateExpectedCount = current;

        tm* date = localtime(&current);

        auto it = m_hours.find(date->tm_hour);
        if (it == m_hours.end()) {
            //need debug
            return;
        }

        HourInfo hinfo = it->second;
        m_expectedSpoofCount = random_range(hinfo.min, hinfo.max);
    }
}

void Spoof::loadBot(){

    PlayerRecord* record = new PlayerRecord();
    PlayerBot* bot = nullptr;

    if(!IOLoginData::getInstance()->loadRecordPlayer(record, bot)){
        if(g_spoof.CURRENT_RECORD == 1)
            IOLoginData::getInstance()->loadRecordPlayer(record, bot);
    }
}

void Spoof::checkBotIdResume(uint32_t player_id){

    Player* player = g_game.getPlayerByGuid(player_id);
    if(player && !player->isRemoved()){
        PlayerBot* bot = player->getBot();

        uint32_t delay = 0;

        if(bot->resume(delay)){
            g_scheduler.addEvent(createSchedulerTask(delay ,std::bind(&Spoof::checkBotIdResume, this, bot->getGUID())));
        }
    }
}

void Spoof::checkBotResume(PlayerBot* bot){

    if(!bot || bot->isRemoved()){
        return;
    }

    uint32_t delay = 0;
    if(bot->resume(delay)){
        g_scheduler.addEvent(createSchedulerTask(delay ,std::bind(&Spoof::checkBotIdResume, this, bot->getGUID())));
    }
}

PlayerRecord::PlayerRecord(){

    m_id = 0;
    m_playerId = 0;
    m_levelLogin = 0;
    m_player = nullptr;
    m_date = OTSYS_TIME();
    m_pause = false;
    m_recordDuration = 0;
    m_lastAction = nullptr;
    m_ignoredPackets = 0;
}

PlayerRecord::~PlayerRecord(){
    for(RecordAction action : m_actions){
        action._free();
    }

    m_actions.clear();
}

void PlayerRecord::onLoad(){

    m_iterator = m_actions.begin();
}

bool PlayerRecord::readNextAction(PropStream& propStream, RecordAction& m_nextAction){

    uint8_t byte;
    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_Action){
        std::cout << "Cannot find byte (action)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    if(!propStream.getType<uint8_t>(m_nextAction.action)){
        std::cout << "Cannot read action..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_Timestamp){
        std::cout << "Cannot find byte (timestamp)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    if(!propStream.getType<uint64_t>(m_nextAction.timestamp)){
        std::cout << "Cannot read timestamp..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_DataSize){
        std::cout << "Cannot find byte (datasize)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    if(!propStream.getType<uint32_t>(m_nextAction.msgSize)){
        std::cout << "Cannot read msgsize..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_Data){
        std::cout << "Cannot find byte (data)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    if(m_nextAction.msgSize != 0){
        m_nextAction.msg = new char[m_nextAction.msgSize + 1];

        if(!propStream.readBuffer(m_nextAction.msg, m_nextAction.msgSize)){
            std::cout << "Cannot read data..." << std::endl;
            return false;
        }
    }

    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_Move){
        std::cout << "Cannot find byte (move)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    if(!propStream.getType<uint32_t>(m_nextAction.posx)){
        std::cout << "Cannot find byte (posz)..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint32_t>(m_nextAction.posy)){
        std::cout << "Cannot find byte (posz)..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint16_t>(m_nextAction.posz)){
        std::cout << "Cannot find byte (posz)..." << std::endl;
        return false;
    }

    if(!propStream.getType<uint8_t>(byte) || byte != RecordAttr_End){
        std::cout << "Cannot find byte (endpoint)... Frame " << m_actions.size() << std::endl;
        return false;
    }

    return true;
}

void PlayerRecord::onDoAction(uint8_t action, NetworkMessage &msg){

    RecordAction record;

    record.action = action;
    record.timestamp = OTSYS_TIME() - m_date;

    record.msgSize = msg.getLength() - 1;
    record.msg = new char[record.msgSize + 1];
    msg.serializeBuffer(record.msg);

    record.posx = m_player->getPosition().getX();
    record.posy = m_player->getPosition().getY();
    record.posz = m_player->getPosition().getZ();

    if(m_actions.size() > 0){
        RecordAction lastRecord = m_actions.back();
        if(lastRecord.timestamp + 200 > record.timestamp && lastRecord.action == record.action && record.posx == lastRecord.posx && record.posy == lastRecord.posy && record.posz == lastRecord.posz && record.msgSize == lastRecord.msgSize && memcmp(record.msg, lastRecord.msg, record.msgSize) == 0){
            m_ignoredPackets++;
            return;
        }
    }

    if(m_ignoredPackets >= 1000){
        std::cout << "[Recording System] Ignored " << m_ignoredPackets << " repeated packets from " << m_player->getName() << std::endl;
        m_ignoredPackets = 0;
    }

    m_actions.push_back(record);

}

void PlayerRecord::onLogout(){

    if(m_actions.size() > 200000){
        std::cout << "[Recording System] Record with more then " << m_actions.size() << " actions ignore from " << m_player->getName() << std::endl;
        return;
    }

    for(RecordAction record : m_actions){
        m_data.addType<uint8_t>(RecordAttr_Action);
        m_data.addType<uint8_t>(record.action);

        m_data.addType<uint8_t>(RecordAttr_Timestamp);
        m_data.addType<uint64_t>(record.timestamp);

        m_data.addType<uint8_t>(RecordAttr_DataSize);
        m_data.addType<uint32_t>(record.msgSize);

        m_data.addType<uint8_t>(RecordAttr_Data);

        for(uint8_t i = 0; i < record.msgSize; i++){
            m_data.addType<uint8_t>(record.msg[i]);
        }

        m_data.addType<uint8_t>(RecordAttr_Move);
        m_data.addType<uint32_t>(record.posx);
        m_data.addType<uint32_t>(record.posy);
        m_data.addType<uint16_t>(record.posz);

        m_data.addType<uint8_t>(RecordAttr_End);

        record._free();
    }

    m_actions.clear();

    m_levelLogout = m_player->getLevel();
    IOLoginData::getInstance()->saveRecordPlayer(m_player);
}
