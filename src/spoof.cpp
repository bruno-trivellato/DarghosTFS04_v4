#include "otpch.h"
#include "spoof.h"
#include "iologindata.h"
#include "game.h"
#include "scheduler.h"

extern Game g_game;

Spoof::Spoof(){

    HourMapArgs args;
    args.push_back(5); args.push_back(1);
    m_hours.emplace(5, args);

    args.clear();
    args.push_back(5); args.push_back(1);
    m_hours.emplace(6, args);

    args.clear();
    args.push_back(5); args.push_back(1);
    m_hours.emplace(7, args);

    args.clear();
    args.push_back(5); args.push_back(1);
    m_hours.emplace(8, args);

    args.clear();
    args.push_back(10); args.push_back(2);
    m_hours.emplace(9, args);

    args.clear();
    args.push_back(10); args.push_back(3);
    m_hours.emplace(10, args);

    args.clear();
    args.push_back(10); args.push_back(3);
    m_hours.emplace(11, args);

    args.clear();
    args.push_back(15); args.push_back(4);
    m_hours.emplace(12, args);

    args.clear();
    args.push_back(15); args.push_back(4);
    m_hours.emplace(13, args);

    args.clear();
    args.push_back(15); args.push_back(4);
    m_hours.emplace(14, args);

    args.clear();
    args.push_back(20); args.push_back(4);
    m_hours.emplace(15, args);

    args.clear();
    args.push_back(20); args.push_back(4);
    m_hours.emplace(16, args);

    args.clear();
    args.push_back(20); args.push_back(4);
    m_hours.emplace(17, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(18, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(19, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(20, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(21, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(22, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(23, args);

    args.clear();
    args.push_back(25); args.push_back(4);
    m_hours.emplace(0, args);

    args.clear();
    args.push_back(20); args.push_back(4);
    m_hours.emplace(1, args);

    args.clear();
    args.push_back(20); args.push_back(4);
    m_hours.emplace(2, args);

    args.clear();
    args.push_back(15); args.push_back(4);
    m_hours.emplace(3, args);

    args.clear();
    args.push_back(10); args.push_back(3);
    m_hours.emplace(4, args);
}

bool Spoof::onStartup(){
    return IOLoginData::getInstance()->generateSpoofList(m_spoofList);
}

void Spoof::onThink(){

    //we will not open any spoof for now
    //return;

    time_t current = time(nullptr);
    tm* date = localtime(&current);

    auto it = m_hours.find(date->tm_hour);
    if (it == m_hours.end()) {
        //need debug
        return;
    }

    HourMapArgs args = it->second;
    uint32_t expectedSpoofCount = args.front();

    std::clog << "[Spoof System] Expected spoof count " << expectedSpoofCount << "." << std::endl;

    uint32_t rand = (uint32_t)random_range(0, 100000);

    if(m_players.size() < expectedSpoofCount){
        if(rand <= 15000){

            Player* loaded_player = loadPlayer();
            if(loaded_player){
                std::clog << "[Spoof System] Player " << loaded_player->getName() << " spoofed." << std::endl;
                uint32_t login_delay = (uint32_t)random_range(1000, 3000);
                Dispatcher::getInstance().addTask(createTask(login_delay, std::bind(&Spoof::loginPlayer, this, loaded_player)));
            }
        }
    }
    else{
        uint32_t expectedUnspoofCount = args.back();
        uint32_t kickChance = (100000 / (60 / expectedUnspoofCount));

        std::clog << "[Spoof System] Expected unspoof count " << expectedUnspoofCount << " with chance " << kickChance << "." << std::endl;

        if(rand <= kickChance){

            std::random_shuffle(m_players.begin(), m_players.end());

            Player* player = g_game.getPlayerByGuid(m_players.front());
            unspoof(player);
        }
    }
}

void Spoof::loginPlayer(Player* player){
    player->setID();
    player->addList();
    player->setSpoof(true, NULL);
    g_game.checkPlayersRecord(player);
    IOLoginData::getInstance()->updateOnlineStatus(player->getGUID(), true, 1);

    m_players.push_back(player->getGUID());
}

void Spoof::unspoof(Player* player){
    if(player){

        std::clog << "[Spoof System] Player " << player->getName() << " unpoofed." << std::endl;

        for(SpoofPlayer_t& item : m_spoofList){
            if(item.id == player->getGUID())
                item.online = false;
        }

        IOLoginData::getInstance()->updateOnlineStatus(player->getGUID(), false);
        IOLoginData::getInstance()->updatePlayerLastLogin(player);

        m_players.erase(std::remove(m_players.begin(), m_players.end(), player->getGUID()), m_players.end());
        g_game.removeCreature(player);
    }
}

Player* Spoof::loadPlayer(){


    uint32_t player_id = 0;
    std::string player_name = "";
    uint32_t tries = 0;

    do{
        uint32_t rand = (uint32_t)random_range(0, m_spoofList.size() - 1);
        SpoofPlayer_t& data = m_spoofList[rand];

        if(!g_game.getPlayerByAccount(data.account_id) && !data.online){
            player_id = data.id;
            player_name = data.name;
            data.online = true;
        }
        else{
            tries++;
            if(tries == 5) break;
        }
    }
    while(player_id == 0);

    Player* player = new Player(player_name, NULL);

    if(player_id != 0){
        if (IOLoginData::getInstance()->loadPlayer(player, player_name)) {
            return player;
        }
    }

    return NULL;
}

void Spoof::onExiva(Player* player, Player* target){
    std::clog << "[Spoof System] Player " << player->getName() << " using exiva on spoof " << target->getName() << "." << std::endl;
}
