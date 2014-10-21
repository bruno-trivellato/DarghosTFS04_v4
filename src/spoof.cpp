#include "otpch.h"
#include "spoof.h"
#include "iologindata.h"
#include "game.h"
#include "scheduler.h"

extern Game g_game;

Spoof::Spoof(){
    m_hours.emplace(0, 30);
    m_hours.emplace(1, 20);
    m_hours.emplace(2, 15);
    m_hours.emplace(3, 10);
    m_hours.emplace(4, 10);
    m_hours.emplace(5, 10);
    m_hours.emplace(6, 10);
    m_hours.emplace(7, 15);
    m_hours.emplace(8, 15);
    m_hours.emplace(9, 20);
    m_hours.emplace(10, 25);
    m_hours.emplace(11, 25);
    m_hours.emplace(12, 30);
    m_hours.emplace(13, 30);
    m_hours.emplace(14, 30);
    m_hours.emplace(15, 30);
    m_hours.emplace(16, 30);
    m_hours.emplace(17, 30);
    m_hours.emplace(18, 30);
    m_hours.emplace(19, 40);
    m_hours.emplace(20, 50);
    m_hours.emplace(21, 60);
    m_hours.emplace(22, 50);
    m_hours.emplace(23, 40);
}

bool Spoof::onStartup(){
    return IOLoginData::getInstance()->generateSpoofList(m_spoofList);
}

void Spoof::onLogin(Player* player){

    //we will not open any spoof for now
    //return;

    time_t current = time(nullptr);
    tm* date = localtime(&current);

    auto it = m_hours.find(date->tm_hour);
    if (it == m_hours.end()) {
        //need debug
        return;
    }

    uint32_t base_chance = it->second;
    uint32_t rand = (uint32_t)random_range(0, 100);

    if(rand <= base_chance){
        PlayerList plist;
        //uint32_t n = 0;
        //do{
            Player* loaded_player = loadPlayer();
            if(loaded_player){
                std::clog << "[Spoof System] Player " << loaded_player->getName() << " spoofed by " << player->getName() << "." << std::endl;
                uint32_t login_delay = (uint32_t)random_range(1000, 3000);
                Dispatcher::getInstance().addTask(createTask(login_delay, std::bind(&Spoof::loginPlayer, this, loaded_player, player)));
                plist.push_back(loaded_player);

                //n++;
            }
        //}
        //while(n < 25);
        m_players[player->getGUID()] = plist;
    }
}

void Spoof::loginPlayer(Player* player, Player* spoofer){
    player->setID();
    player->addList();
    player->setSpoof(true, spoofer);
    g_game.checkPlayersRecord(player);
    IOLoginData::getInstance()->updateOnlineStatus(player->getGUID(), true, 1);
}

void Spoof::onLogout(Player* player){
    auto it = m_players.find(player->getGUID());
    if (it == m_players.end()) {
        return;
    }

    PlayerList plist = it->second;
    for(Player* loaded_player : plist){
        if(loaded_player && !loaded_player->isRemoved()){
            logoutPlayer(loaded_player, player);
        }
    }

    m_players.erase(it);
}

void Spoof::forceUnspoof(Player* player){

    std::clog << "[Spoof System] Player " << player->getName() << " unpoofed by reaplace login." << std::endl;
    Player* spoofer = player->getSpoofer();
    onLogout(spoofer);
}

void Spoof::logoutPlayer(Player* player, Player* kicker){
    if(player){
        if(kicker)
            std::clog << "[Spoof System] Player " << player->getName() << " unpoofed by " << kicker->getName() << "." << std::endl;
        else
            std::clog << "[Spoof System] Player " << player->getName() << " unpoofed." << std::endl;

        for(SpoofPlayer_t& item : m_spoofList){
            if(item.id == player->getGUID())
                item.online = false;
        }

        IOLoginData::getInstance()->updateOnlineStatus(player->getGUID(), false);
        IOLoginData::getInstance()->updatePlayerLastLogin(player);
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
