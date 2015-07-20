#include "otpch.h"

#include <fstream>

#include "spoofbot.h"
#include "spoof.h"
#include "iologindata.h"
#include "tools.h"
#include "game.h"

extern Spoof g_spoof;
extern Game g_game;

PlayerBot::PlayerBot(const std::string& name, ProtocolGame* p) :
    Player(name, p)
{
    m_loginMicro = OTSYS_TIME();
    m_outOfSync = 0;
    m_lastOutOfSync = 0;
}

PlayerBot::~PlayerBot()
{
    if(m_logFile.tellp() > 0){
        std::ostringstream logFile;
        logFile << "data/logs/records/id_" << m_record->m_id << ".log";
        std::ofstream out(logFile.str(), std::ios::app);
        if (out.is_open()) {

            out << m_logFile.str();
            out.close();
        }
    }
/*
    for(RecordAction* action : m_record->m_actions){
        delete action;
    }

    m_record->m_actions.clear();
    */
}

void PlayerBot::onExiva(Player* player){
    std::cout << "[Spoof System] Player " << player->getName() << " using exiva on spoof " << getName() << "." << std::endl;
}

void PlayerBot::placeOnMap(){

    std::cout << "[Spoof System] Bot " << getName() << " loaded with record #" << m_record->m_id << std::endl; 

    if(!m_record->m_pause && m_record->m_iterator == m_record->m_actions.begin()){
        m_record->m_lastAction = *m_record->m_iterator;
        m_record->m_iterator++;

        Position tempPos;
        tempPos.x = m_record->m_lastAction->posx;
        tempPos.y = m_record->m_lastAction->posy;
        tempPos.z = m_record->m_lastAction->posz;

        Position recPos;
        recPos.x = m_record->m_posx;
        recPos.y = m_record->m_posy;
        recPos.z = m_record->m_posz;

        if(tempPos.getX() != recPos.getX() || tempPos.getY() != recPos.getY() || tempPos.getZ() != recPos.getZ()){
            if (!g_game.placeCreature(getPlayer(), tempPos)) {
                std::clog << "[Spoof System] Can not load spoof " << getName() << " on map." << std::endl;
                return;
            }

            m_logFile << logHeader() << " [" << getName() << "] Try to sync pos moving to first action pos. [" << tempPos.getX() << ", " << tempPos.getY() << ", " << tempPos.getZ() << "]" << std::endl;
        }
        else{
            if (!g_game.placeCreature(getPlayer(), recPos)) {
                std::clog << "[Spoof System] Can not load spoof " << getName() << " on map." << std::endl;
                return;
            }
        }

        Scheduler::getInstance().addEvent(createSchedulerTask(m_record->m_lastAction->timestamp ,std::bind(&Spoof::checkBotIdResume, &g_spoof, getGUID())));
    }

    onLoad();

    g_spoof.m_players.push_back(getGUID());
    g_spoof.LOGINS_COUNT++;
}

bool PlayerBot::remove(){

    g_spoof.m_players.erase(std::remove(g_spoof.m_players.begin(), g_spoof.m_players.end(), getGUID()), g_spoof.m_players.end());

    if(!m_record){
        IOLoginData::getInstance()->updateOnlineStatus(getGUID(), false);
        removeList();
        setRemoved();

        g_game.removeCreatureCheck(getPlayer());

        return false;
    }

    g_spoof.KICKS_COUNT++;

    if(m_outOfSync >= 3)
        g_spoof.OUTSYNC_COUNT++;

    return true;
}

void PlayerBot::onAttacked(Creature* creature){
    if(creature->getPlayer() == getPlayer())
        return;

    if(creature->getName() == "Trainer")
        return;

    if(!creature->getMaster())
        m_enemies[creature->getID()] = time(nullptr);
    else
        m_enemies[creature->getMaster()->getID()] = time(nullptr);
}

Creature* PlayerBot::findTarget(){
    for (const auto& it : m_enemies) {
        Creature* attacker = g_game.getCreatureByID(it.first);
        if (attacker) {
            if(!g_game.isSightClear(getPosition(), attacker->getPosition(), true)){
                if(attacker == attackedCreature){
                    attackedCreature = nullptr;
                }

                m_enemies.erase(it.first);
            }
        }

        if(!attacker || (it.second + 5 < time(nullptr)))
            m_enemies.erase(it.first);
    }

    for (const auto& it : m_enemies) {
        Creature* attacker = g_game.getCreatureByID(it.first);
        if (attacker) {
            if(!attackedCreature){
                return attacker;
            }
        }
    }

    return nullptr;
}

void PlayerBot::onLoad(){
    lastLogin = std::max<time_t>(time(nullptr), lastLogin + 1);

    //feeding bot
    Condition* condition = getCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT);
    if (condition) {
        condition->setTicks(m_record->m_recordDuration);
    }
    else{
        condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_REGENERATION, (int32_t)m_record->m_recordDuration);
        condition->setParam(CONDITIONPARAM_HEALTHGAIN, vocation->getGainAmount(GAIN_HEALTH));
        condition->setParam(CONDITIONPARAM_HEALTHTICKS, (vocation->getGainTicks(GAIN_HEALTH) * 1000));
        condition->setParam(CONDITIONPARAM_MANAGAIN, vocation->getGainAmount(GAIN_MANA));
        condition->setParam(CONDITIONPARAM_MANATICKS, (vocation->getGainTicks(GAIN_MANA) * 1000));

        addCondition(condition);
    }
}

void PlayerBot::onThink(){
    checkHeal();

    if(m_record){
        if(m_enemies.size() > 0){
            Creature* target = findTarget();
            if(target){
                chaseMode = CHASEMODE_FOLLOW;
                g_game.playerSetAttackedCreature(id, target->getID());
                m_record->m_pause = true;
            }
        }

        if(m_record->m_pause && m_enemies.size() == 0 && !walkTask){
            m_record->m_pause = false;
            g_spoof.checkBotResume(this);
        }

        if(m_lastOutOfSync + 60 < time(nullptr)){
            m_outOfSync = 0;
            m_lastOutOfSync = 0;
        }
    }
}

bool PlayerBot::resume(uint32_t& delay){

    if(m_outOfSync >= 3){
        m_logFile << logHeader() << " [" << getName() << "] 3 times out of sync. Kicking..." << std::endl;
        return false;
    }

    if(m_record->m_iterator != m_record->m_actions.end() && !walkTask){
        if(canDoNextAction()){
            if(!syncPath(m_record->m_lastAction)){
                client->doAction(m_record->m_lastAction);

                uint64_t lastTimestamp = m_record->m_lastAction->timestamp;

                m_record->m_iterator++;
               if(m_record->m_iterator == m_record->m_actions.end()){
                    m_logFile << "[" << getName() << "] finished record successfully." << std::endl;
                    return false;
                }

                m_record->m_lastAction = *m_record->m_iterator;

                delay = m_record->m_lastAction->timestamp - lastTimestamp;
                return true;
            }
        }
    }

    return false;
}

bool PlayerBot::canDoNextAction(){
    if(!m_record->m_pause && m_record->m_lastAction){
        return true;
    }

    return false;
}

bool PlayerBot::syncPath(RecordAction* nextAction){

    if(!nextAction)
        return false;

    Position tempPos;
    tempPos.x = nextAction->posx;
    tempPos.y = nextAction->posy;
    tempPos.z = nextAction->posz;

    std::list<Direction> listDir;

    FindPathParams fpp;
    fpp.maxTargetDist = 0;
    fpp.minTargetDist = 0;
    fpp.clearSight = true;

    if(m_record->m_iterator != m_record->m_actions.end()){
        if(tempPos.getZ() != getPosition().getZ()){
            onOutOfSync();
            return true;
        }

        if(Position::getDistanceX(getPosition(), tempPos) <= 3 && Position::getDistanceY(getPosition(), tempPos) <= 3)
            return false;

        if(getPathTo(tempPos, listDir, fpp)){
            g_game.playerAutoWalk(getID(), listDir);

            m_record->m_pause = true;

            SchedulerTask* task = createSchedulerTask(400, std::bind(&PlayerBot::unPause, this));
            if(m_walkTaskEventBot != 0){
                Scheduler::getInstance().stopEvent(m_walkTaskEventBot);
                m_walkTaskEventBot = 0;
            }
            m_walkTaskBot = task;

            return true;
        }
    }

    return false;
}

void PlayerBot::onOutOfSync(){

    m_logFile << logHeader() << " [" << getName() << "] Floor out of sync. Trying to to resync with pos [" << getPosition().getX() << ", " << getPosition().getY() << ", " << getPosition().getZ() << "]" << std::endl;

    m_outOfSync++;
    m_lastOutOfSync = time(nullptr);

    bool found = false;
    bool near = false;

    RecordActionList::iterator current = m_record->m_iterator;

    for(uint32_t k = 0; (k < 10); k++){
        if(m_record->m_iterator == m_record->m_actions.begin())
            break;

        RecordAction* backAction = *(--m_record->m_iterator);

        Position backPos;
        backPos.x = backAction->posx;
        backPos.y = backAction->posy;
        backPos.z = backAction->posz;

        m_logFile << logHeader() << " #" << std::distance(m_record->m_actions.begin(), m_record->m_iterator) << " [" << backPos.getX() << ", " << backPos.getY() << ", " << backPos.getZ() << "] | Action 0x" << std::hex << static_cast<uint16_t>(backAction->action) << std::dec;

        if(Position::getDistanceX(getPosition(), backPos) == 0 && Position::getDistanceY(getPosition(), backPos) == 0 && Position::getDistanceZ(getPosition(), backPos) == 0){
            m_logFile << " <- found" << std::endl;

            m_record->m_lastAction = backAction;

            found = true;

            break;
        }
        else{
            m_logFile << std::endl;
        }
    }

    if(!found){
        m_record->m_iterator = current;

        for(uint32_t k = 0; (k < 10); k++){
            if(m_record->m_iterator == m_record->m_actions.begin())
                break;

            RecordAction* backAction = *(--m_record->m_iterator);

            Position backPos;
            backPos.x = backAction->posx;
            backPos.y = backAction->posy;
            backPos.z = backAction->posz;

            m_logFile << logHeader() << " #" << std::distance(m_record->m_actions.begin(), m_record->m_iterator) << " [" << backPos.getX() << ", " << backPos.getY() << ", " << backPos.getZ() << "] | Action 0x" << std::hex << static_cast<uint16_t>(backAction->action) << std::dec;

            if(Position::getDistanceX(getPosition(), backPos) <= 5 && Position::getDistanceY(getPosition(), backPos) <= 5 && Position::getDistanceZ(getPosition(), backPos) == 0){
                m_logFile << " <- found (near)" << std::endl;

                m_record->m_lastAction = backAction;

                found = true;
                near = true;

                break;
            }
            else{
                m_logFile << std::endl;
            }
        }
    }

    if(!found){
        m_record->m_iterator = current;
        m_outOfSync = 3;
        m_logFile << logHeader() << " [" << getName() << "] Cannot re-sync. Kicking..." << std::endl;
    }
    else{
        if(!near)
            g_spoof.checkBotResume(this);
        else
            syncPath(m_record->m_lastAction);
    }
}

void PlayerBot::onAutoWalk(){

}

void PlayerBot::unPause(){
    if(m_record){
        m_record->m_pause = false;
        g_spoof.checkBotResume(this);
    }
}

bool PlayerBot::checkHeal(){
    bool needHeal = (health <= std::floor((uint32_t)healthMax * 0.50)) ? true : false;
    std::string spell = "";

    if(needHeal){
        if(isDruid(getVocationId())){
            if(level >= 30)
                spell = "exura vita";
            else if(level >= 20)
                spell = "exura gran";
            else
                spell = "exura";
        }
        else if(isSorcerer(getVocationId())){
            if(level >= 30)
                spell = "exura vita";
            else if(level >= 20)
                spell = "exura gran";
            else
                spell = "exura";
        }
        else if(isPaladin(getVocationId())){
            if(level >= 35)
                spell = "exura san";
            else
                spell = "exura";
        }
        else if(isKnight(getVocationId())){
            spell = "exura ico";
        }

        g_game.playerSay(getID(), 0, SPEAK_SAY, "", spell);
        return true;
    }

    return false;
}

void PlayerBot::lookAt(Player* actor, int32_t lookDistance){

    std::ostringstream s;
    s << "You see " << getDescription(lookDistance);

    if(actor->hasCustomFlag(PlayerCustomFlag_CanSeeCreatureDetails)){
        s << std::endl << "Position: " << getPosition().getX() << ", " << getPosition().getY() << ", " << getPosition().getZ();
        s << std::endl << "Record: #" << m_record->m_id << ", Frame: " << std::distance(m_record->m_actions.begin(), m_record->m_iterator) << "/" << std::distance(m_record->m_actions.begin(), m_record->m_actions.end()) << ", Duration: ";

        uint32_t duration = (uint32_t)m_record->m_recordDuration / 1000;

        const uint32_t cseconds_in_hour = 3600;
        const uint32_t cseconds_in_minute = 60;
        const uint32_t cseconds = 1;

        uint32_t hours = duration / cseconds_in_hour;
        uint32_t minutes = (duration % cseconds_in_hour) / cseconds_in_minute;
        uint32_t seconds = ((duration % cseconds_in_hour) % cseconds_in_minute) / cseconds;

        if(hours > 0){
            s << hours << "h ";
        }

        if(minutes > 0){
            s << minutes << "m ";
        }

        if(seconds > 0){
            s << seconds << "s ";
        }

        s << std::endl << "Flags: ";

        std::vector<std::string> v;
        std::ostringstream o;

        if(m_record->m_pause){
            o << "pause";
            v.push_back(o.str());
            o.str("");
        }

        if(m_outOfSync > 0){
            if(m_outOfSync == 3)
                o << "outOfSync";
            else
                o << "sync tries " << m_outOfSync;

            v.push_back(o.str());
            o.str("");
        }

        if(m_enemies.size() > 0){
            o << m_enemies.size() << " enemies";
            v.push_back(o.str());
            o.str("");
        }

        if(!m_record->m_pause || m_record->m_iterator != m_record->m_actions.end()){

            uint64_t timestamp;

            if(m_record->m_iterator == m_record->m_actions.begin()){
                RecordAction* action = *m_record->m_iterator;
                timestamp = action->timestamp;
            }
            else{
                RecordAction* action = *std::prev(m_record->m_iterator);
                timestamp = m_record->m_lastAction->timestamp - action->timestamp;
            }

            o << "next frame in " << timestamp << "ms";
            v.push_back(o.str());
            o.str("");
        }

        if(v.size() > 0){
            std::string front = v.front();
            for(std::string string : v){
                if(string != front)
                    s << ", ";

                s << string;
            }
        }
    }

    actor->sendTextMessage(MSG_INFO_DESCR, s.str());
}

std::string PlayerBot::logHeader(){

    time_t ticks = time(nullptr);
    const tm* now = localtime(&ticks);
    char buf[32];
    strftime(buf, sizeof(buf), "%d/%m/%Y %H:%M", now);
    std::string str(buf);
    return str;
}
