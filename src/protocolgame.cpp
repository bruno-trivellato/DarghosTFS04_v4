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
#include <boost/function.hpp>
#include <iostream>

#include "protocolgame.h"
#include "textlogger.h"

#include "waitlist.h"
#include "player.h"

#include "connection.h"
#include "networkmessage.h"
#include "outputmessage.h"

#include "iologindata.h"
#include "ioban.h"

#include "items.h"
#include "tile.h"
#include "house.h"

#include "actions.h"
#include "creatureevent.h"
#include "quests.h"

#include "chat.h"
#include "configmanager.h"
#include "game.h"
#include "spoof.h"
#include "spoofbot.h"

extern Game g_game;
extern ConfigManager g_config;
extern Actions actions;
extern CreatureEvents* g_creatureEvents;
extern Chat g_chat;
extern Spoof g_spoof;

template<class FunctionType>
void ProtocolGame::addGameTaskInternal(uint32_t delay, const FunctionType& func)
{
    if(delay > 0)
        g_dispatcher.addTask(createTask(delay, func));
    else
        g_dispatcher.addTask(createTask(func));
}

#ifdef __ENABLE_SERVER_DIAGNOSTIC__
uint32_t ProtocolGame::protocolGameCount = 0;
#endif

void ProtocolGame::setPlayer(Player* p)
{
    player = p;
}

void ProtocolGame::releaseProtocol()
{
    if(player && player->client == this)
        player->client = NULL;

    Protocol::releaseProtocol();
}

void ProtocolGame::deleteProtocolTask()
{
    if(player)
    {
        g_game.freeThing(player);
        player = NULL;
    }

    Protocol::deleteProtocolTask();
}

bool ProtocolGame::login(const std::string& name, uint32_t id, const std::string&,
    OperatingSystem_t operatingSystem, uint16_t version, bool gamemaster)
{
    //dispatcher thread
    PlayerVector players = g_game.getPlayersByName(name);
    Player* _player = NULL;
    if(!players.empty())
        _player = players[random_range(0, (players.size() - 1))];

    if(!_player || name == "Account Manager" || g_config.getNumber(ConfigManager::ALLOW_CLONES) > (int32_t)players.size())
    {
        player = new Player(name, this);
        player->addRef();

        player->setID();
        if(!IOLoginData::getInstance()->loadPlayer(player, name, true))
        {
            disconnectClient(0x14, "Your character could not be loaded.");
            return false;
        }

        Ban ban;
        ban.value = player->getID();
        ban.param = PLAYERBAN_BANISHMENT;

        ban.type = BAN_PLAYER;
        if(IOBan::getInstance()->getData(ban) && !player->hasFlag(PlayerFlag_CannotBeBanned))
        {
            bool deletion = ban.expires < 0;
            std::string name_ = "Automatic ";
            if(!ban.adminId)
                name_ += (deletion ? "deletion" : "banishment");
            else
                IOLoginData::getInstance()->getNameByGuid(ban.adminId, name_, true);

            std::stringstream ss;
            ss << "Your account has been " << (deletion ? "deleted" : "banished") << " at:\n"
                << formatDateEx(ban.added, "%d %b %Y").c_str() << " by: " << name_.c_str() << ",\n"
                << "for the following reason:\n"
                << getReason(ban.reason).c_str() << ".\n"
                << "The action taken was:\n"
                << getAction(ban.action, false).c_str() << ".\nThe comment given was:\n"
                << ban.comment.c_str() << ".\n"
                << "Your " << (deletion ? "account won't be undeleted" : "banishment will be lifted at:\n") << (deletion ? "." : formatDateEx(ban.expires).c_str());

            disconnectClient(0x14, ss.str().c_str());
            return false;
        }

        if(IOBan::getInstance()->isPlayerBanished(player->getGUID(), PLAYERBAN_LOCK) && id != 1)
        {
            if(g_config.getBool(ConfigManager::NAMELOCK_MANAGER))
            {
                player->name = "Account Manager";
                player->accountManager = MANAGER_NAMELOCK;

                player->managerNumber = id;
                player->managerString2 = name;
            }
            else
            {
                disconnectClient(0x14, "Your character has been namelocked.");
                return false;
            }
        }
        else if(player->getName() == "Account Manager")
        {
            if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER))
            {
                disconnectClient(0x14, "Account Manager is disabled.");
                return false;
            }

            if(id != 1)
            {
                player->accountManager = MANAGER_ACCOUNT;
                player->managerNumber = id;
            }
            else
                player->accountManager = MANAGER_NEW;
        }

        if(gamemaster && !player->hasCustomFlag(PlayerCustomFlag_GamemasterPrivileges))
        {
            disconnectClient(0x14, "You are not a gamemaster! Turn off the gamemaster mode in your IP changer.");
            return false;
        }

        if(!player->hasFlag(PlayerFlag_CanAlwaysLogin))
        {
            if(g_game.getGameState() == GAMESTATE_CLOSING)
            {
                disconnectClient(0x14, "Gameworld is just going down, please come back later.");
                return false;
            }

            if(g_game.getGameState() == GAMESTATE_CLOSED)
            {
                disconnectClient(0x14, "Gameworld is currently closed, please come back later.");
                return false;
            }
        }

        if(g_config.getBool(ConfigManager::ONE_PLAYER_ON_ACCOUNT) && !player->isAccountManager() &&
            !IOLoginData::getInstance()->hasCustomFlag(id, PlayerCustomFlag_CanLoginMultipleCharacters))
        {
            bool found = false;
            PlayerVector tmp = g_game.getPlayersByAccount(id);
            for(PlayerVector::iterator it = tmp.begin(); it != tmp.end(); ++it)
            {
                if((*it)->getName() != name)
                    continue;

                found = true;
                break;
            }

            if(tmp.size() > 0 && !found)
            {
                disconnectClient(0x14, "You may only login with one character\nof your account at the same time.");
                return false;
            }
        }

        if(!WaitingList::getInstance()->login(player))
        {
            if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
            {
                std::stringstream ss;
                ss << "Too many players online.\n" << "You are ";

                int32_t slot = WaitingList::getInstance()->getSlot(player);
                if(slot)
                {
                    ss << "at ";
                    if(slot > 0)
                        ss << slot;
                    else
                        ss << "unknown";

                    ss << " place on the waiting list.";
                }
                else
                    ss << "awaiting connection...";

                output->addByte(0x16);
                output->addString(ss.str());
                output->addByte(WaitingList::getTime(slot));
                OutputMessagePool::getInstance()->send(output);
            }

            getConnection()->close();
            return false;
        }

        if(!IOLoginData::getInstance()->loadPlayer(player, name))
        {
            disconnectClient(0x14, "Your character could not be loaded.");
            return false;
        }

        player->setClientVersion(version);
        player->setOperatingSystem(operatingSystem);
        if(!g_game.placeCreature(player, player->getLoginPosition()) && !g_game.placeCreature(player, player->getMasterPosition(), false, true))
        {
            disconnectClient(0x14, "Temple position is wrong. Contact with the administration.");
            return false;
        }

        player->lastIP = player->getIP();
        player->lastLoad = OTSYS_TIME();
        player->lastLogin = std::max(time(NULL), player->lastLogin + 1);

        m_acceptPackets = true;
        return true;
    }
    else if(_player->getBot()){

        disconnectClient(0x14, "Your character could not be loaded.");
        g_game.removeCreature(_player);

        return false;
    }
    else if(_player->client)
    {
        if(m_eventConnect || !g_config.getBool(ConfigManager::REPLACE_KICK_ON_LOGIN))
        {
            //A task has already been scheduled just bail out (should not be overriden)
            disconnectClient(0x14, "You are already logged in.");
            return false;
        }

        g_chat.removeUserFromAllChannels(_player);
        _player->disconnect();
        _player->isConnecting = true;

        addRef();
        m_eventConnect = g_scheduler.addEvent(createSchedulerTask(
            1000, boost::bind(&ProtocolGame::connect, this, _player->getID(), operatingSystem, version)));
        return true;
    }

    addRef();
    return connect(_player->getID(), operatingSystem, version);
}

bool ProtocolGame::logout(bool displayEffect, bool forceLogout)
{
    //dispatcher thread
    if(!player)
        return false;

    if(!player->isRemoved())
    {
        if(!forceLogout)
        {
            if(!IOLoginData::getInstance()->hasCustomFlag(player->getAccount(), PlayerCustomFlag_CanLogoutAnytime))
            {
                if(player->getTile()->hasFlag(TILESTATE_NOLOGOUT))
                {
                    player->sendCancelMessage(RET_YOUCANNOTLOGOUTHERE);
                    return false;
                }

                if(player->hasCondition(CONDITION_INFIGHT))
                {
                    player->sendCancelMessage(RET_YOUMAYNOTLOGOUTDURINGAFIGHT);
                    return false;
                }

                if(!g_creatureEvents->playerLogout(player, false)) //let the script handle the error message
                    return false;
            }
            else
                g_creatureEvents->playerLogout(player, true);
        }
        else if(!g_creatureEvents->playerLogout(player, true))
            return false;

        if(displayEffect && !player->isGhost())
            g_game.addMagicEffect(player->getPosition(), MAGIC_EFFECT_POFF);
    }

    if(Connection_ptr connection = getConnection())
        connection->close();

    if(player->isRemoved())
        return true;

    return g_game.removeCreature(player);
}

bool ProtocolGame::connect(uint32_t playerId, OperatingSystem_t operatingSystem, uint16_t version)
{
    unRef();
    m_eventConnect = 0;

    Player* _player = g_game.getPlayerByID(playerId);
    if(!_player || _player->isRemoved() || _player->client)
    {
        disconnectClient(0x14, "You are already logged in.");
        return false;
    }

    player = _player;
    player->addRef();
    player->client = this;
    player->isConnecting = false;

    player->sendCreatureAppear(player);

    player->setOperatingSystem(operatingSystem);
    player->setClientVersion(version);

    player->lastIP = player->getIP();
    player->lastLoad = OTSYS_TIME();
    player->lastLogin = std::max(time(NULL), player->lastLogin + 1);

    m_acceptPackets = true;
    return true;
}

void ProtocolGame::disconnect()
{
    if(getConnection())
        getConnection()->close();
}

void ProtocolGame::disconnectClient(uint8_t error, const char* message)
{
    if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
    {
        output->addByte(error);
        output->addString(message);
        OutputMessagePool::getInstance()->send(output);
    }

    disconnect();
}

void ProtocolGame::onConnect()
{
    if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
    {
        enableChecksum();

        output->addByte(0x1F);
        output->add<uint16_t>(random_range(0, 0xFFFF));
        output->add<uint16_t>(0x00);
        output->addByte(random_range(0, 0xFF));

        OutputMessagePool::getInstance()->send(output);
    }
}

void ProtocolGame::onRecvFirstMessage(NetworkMessage& msg)
{
    parseFirstPacket(msg);
}

bool ProtocolGame::parseFirstPacket(NetworkMessage& msg)
{
    if(g_game.getGameState() == GAMESTATE_SHUTDOWN)
    {
        getConnection()->close();
        return false;
    }

    OperatingSystem_t operatingSystem = (OperatingSystem_t)msg.get<uint16_t>();
    uint16_t version = msg.get<uint16_t>();
    if(!RSA_decrypt(msg))
    {
        getConnection()->close();
        return false;
    }

    uint32_t key[4] = {msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>()};
    enableXTEAEncryption();
    setXTEAKey(key);

    bool gamemaster = msg.get<char>();
    std::string name = msg.getString(), character = msg.getString(), password = msg.getString();

    msg.skipBytes(6); //841- wtf?
    if(version < CLIENT_VERSION_MIN || version > CLIENT_VERSION_MAX)
    {
        disconnectClient(0x14, CLIENT_VERSION_STRING);
        return false;
    }

    if(name.empty())
    {
        if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER))
        {
            disconnectClient(0x14, "Invalid account name.");
            return false;
        }

        name = "1";
        password = "1";
    }

    if(g_game.getGameState() < GAMESTATE_NORMAL)
    {
        disconnectClient(0x14, "Gameworld is just starting up, please wait.");
        return false;
    }

    if(g_game.getGameState() == GAMESTATE_MAINTAIN)
    {
        disconnectClient(0x14, "Gameworld is under maintenance, please re-connect in a while.");
        return false;
    }

    if(IOBan::getInstance()->isIpBanished(getIP()))
    {
        disconnectClient(0x14, "Your IP is banished!");
        return false;
    }

    uint32_t id = 1;
    if(!IOLoginData::getInstance()->getAccountId(name, id))
    {
        disconnectClient(0x14, "Invalid account name.");
        return false;
    }

    std::string hash, salt;
    if(!IOLoginData::getInstance()->getPassword(id, hash, salt, character) || !encryptTest(salt + password, hash))
    {
        disconnectClient(0x14, "Invalid password.");
        return false;
    }

    Ban ban;
    ban.value = id;

    ban.type = BAN_ACCOUNT;
    if(IOBan::getInstance()->getData(ban) && !IOLoginData::getInstance()->hasFlag(id, PlayerFlag_CannotBeBanned))
    {
        bool deletion = ban.expires < 0;
        std::string name_ = "Automatic ";
        if(!ban.adminId)
            name_ += (deletion ? "deletion" : "banishment");
        else
            IOLoginData::getInstance()->getNameByGuid(ban.adminId, name_, true);

        std::stringstream ss;
        ss << "Your account has been " << (deletion ? "deleted" : "banished") << " at:\n"
            << formatDateEx(ban.added, "%d %b %Y").c_str() << " by: " << name_.c_str() << ",\n"
            << "for the following reason:\n"
            << getReason(ban.reason).c_str() << ".\n"
            << "The action taken was:\n"
            << getAction(ban.action, false).c_str() << ".\nThe comment given was:\n"
            << ban.comment.c_str() << ".\n"
            << "Your " << (deletion ? "account won't be undeleted" : "banishment will be lifted at:\n") << (deletion ? "." : formatDateEx(ban.expires).c_str());

        disconnectClient(0x14, ss.str().c_str());
        return false;
    }

    g_dispatcher.addTask(createTask(boost::bind(
        &ProtocolGame::login, this, character, id, password, operatingSystem, version, gamemaster)));
    return true;
}

void ProtocolGame::writeToOutputBuffer(const NetworkMessage& msg)
{
    OutputMessage_ptr out = getOutputBuffer(msg.getLength());
    if (out) {
        out->append(msg);
    }
}

void ProtocolGame::doAction(RecordAction* action){
    if (!player) {
        return;
    }

    NetworkMessage msg;
    msg.addBytes(action->msg, action->msgSize);
    msg.setBufferPosition(8);

    //a dead player can not performs actions
    if (player->isRemoved() && action->action != 0x14)
        return;

    switch(action->action)
    {
        case 0x14: // logout
            parseLogout(msg);
            break;

        case 0x1E: // keep alive / ping response
            parseReceivePing(msg);
            break;

        case 0x64: // move with steps
            parseAutoWalk(msg);
            break;

        case 0x65: // move north
        case 0x66: // move east
        case 0x67: // move south
        case 0x68: // move west
            parseMove(msg, (Direction)(action->action - 0x65));
            break;

        case 0x69: // stop-autowalk
            addGameTask(&Game::playerStopAutoWalk, player->getID());
            break;

        case 0x6A:
            parseMove(msg, NORTHEAST);
            break;

        case 0x6B:
            parseMove(msg, SOUTHEAST);
            break;

        case 0x6C:
            parseMove(msg, SOUTHWEST);
            break;

        case 0x6D:
            parseMove(msg, NORTHWEST);
            break;

        case 0x6F: // turn north
        case 0x70: // turn east
        case 0x71: // turn south
        case 0x72: // turn west
            parseTurn(msg, (Direction)(action->action - 0x6F));
            break;

        case 0x78: // throw item
            parseThrow(msg);
            break;

        case 0x79: // description in shop window
            parseLookInShop(msg);
            break;

        case 0x7A: // player bought from shop
            parsePlayerPurchase(msg);
            break;

        case 0x7B: // player sold to shop
            parsePlayerSale(msg);
            break;

        case 0x7C: // player closed shop window
            parseCloseShop(msg);
            break;

        case 0x7D: // Request trade
            parseRequestTrade(msg);
            break;

        case 0x7E: // Look at an item in trade
            parseLookInTrade(msg);
            break;

        case 0x7F: // Accept trade
            parseAcceptTrade(msg);
            break;

        case 0x80: // close/cancel trade
            parseCloseTrade();
            break;

        case 0x82: // use item
            parseUseItem(msg);
            break;

        case 0x83: // use item
            parseUseItemEx(msg);
            break;

        case 0x84: // battle window
            parseBattleWindow(msg);
            break;

        case 0x85: //rotate item
            parseRotateItem(msg);
            break;

        case 0x87: // close container
            parseCloseContainer(msg);
            break;

        case 0x88: //"up-arrow" - container
            parseUpArrowContainer(msg);
            break;

        case 0x89:
            parseTextWindow(msg);
            break;

        case 0x8A:
            parseHouseWindow(msg);
            break;

        case 0x8C: // throw item
            parseLookAt(msg);
            break;

        case 0x96: // say something
            parseSay(msg);
            break;

        case 0x97: // request channels
            parseGetChannels(msg);
            break;

        case 0x98: // open channel
            parseOpenChannel(msg);
            break;

        case 0x99: // close channel
            parseCloseChannel(msg);
            break;

        case 0x9A: // open priv
            parseOpenPriv(msg);
            break;

        case 0x9B: //process report
            parseProcessRuleViolation(msg);
            break;

        case 0x9C: //gm closes report
            parseCloseRuleViolation(msg);
            break;

        case 0x9D: //player cancels report
            parseCancelRuleViolation(msg);
            break;

        case 0x9E: // close NPC
            parseCloseNpc(msg);
            break;

        case 0xA0: // set attack and follow mode
            parseFightModes(msg);
            break;

        case 0xA1: // attack
            parseAttack(msg);
            break;

        case 0xA2: //follow
            parseFollow(msg);
            break;

        case 0xA3: // invite party
            parseInviteToParty(msg);
            break;

        case 0xA4: // join party
            parseJoinParty(msg);
            break;

        case 0xA5: // revoke party
            parseRevokePartyInvite(msg);
            break;

        case 0xA6: // pass leadership
            parsePassPartyLeadership(msg);
            break;

        case 0xA7: // leave party
            parseLeaveParty(msg);
            break;

        case 0xA8: // share exp
            parseSharePartyExperience(msg);
            break;

        case 0xAA:
            parseCreatePrivateChannel(msg);
            break;

        case 0xAB:
            parseChannelInvite(msg);
            break;

        case 0xAC:
            parseChannelExclude(msg);
            break;

        case 0xBE: // cancel move
            parseCancelMove(msg);
            break;

        case 0xC9: //client request to resend the tile
            parseUpdateTile(msg);
            break;

        case 0xCA: //client request to resend the container (happens when you store more than container maxsize)
            parseUpdateContainer(msg);
            break;

        case 0xD2: // request outfit
            if((!player->hasCustomFlag(PlayerCustomFlag_GamemasterPrivileges) || !g_config.getBool(
                ConfigManager::DISABLE_OUTFITS_PRIVILEGED)) && (g_config.getBool(ConfigManager::ALLOW_CHANGEOUTFIT)
                || g_config.getBool(ConfigManager::ALLOW_CHANGECOLORS) || g_config.getBool(ConfigManager::ALLOW_CHANGEADDONS)))
                parseRequestOutfit(msg);
            break;

        case 0xD3: // set outfit
            if((!player->hasCustomFlag(PlayerCustomFlag_GamemasterPrivileges) || !g_config.getBool(ConfigManager::DISABLE_OUTFITS_PRIVILEGED))
                && (g_config.getBool(ConfigManager::ALLOW_CHANGECOLORS) || g_config.getBool(ConfigManager::ALLOW_CHANGEOUTFIT)))
                parseSetOutfit(msg);
            break;

        case 0xDC:
            parseAddVip(msg);
            break;

        case 0xDD:
            parseRemoveVip(msg);
            break;

        case 0xE6:
            parseBugReport(msg);
            break;

        case 0xE7:
            parseViolationWindow(msg);
            break;

        case 0xE8:
            parseDebugAssert(msg);
            break;

        case 0xF0:
            parseQuests(msg);
            break;

        case 0xF1:
            parseQuestInfo(msg);
            break;

        case 0xF2:
            parseViolationReport(msg);
            break;

        default:
            break;
    }
}

void ProtocolGame::parsePacket(NetworkMessage &msg)
{
    if(!player || !m_acceptPackets || g_game.getGameState() == GAMESTATE_SHUTDOWN || msg.getLength() <= 0)
        return;

    uint8_t recvbyte = msg.get<char>();

    if (!player) {
        if (recvbyte == 0x0F) {
            disconnect();
        }
        return;
    }

    //a dead player cannot performs actions
    if((player->isRemoved() || player->getHealth() <= 0) && recvbyte != 0x14){
        disconnect();
        return;
    }

#ifdef __DARGHOS_CUSTOM__
    if(player->isPause())
        return;
#endif

    if(player->isAccountManager())
    {
        switch(recvbyte)
        {
            case 0x14:
                parseLogout(msg);
                break;

            case 0x96:
                parseSay(msg);
                break;

            case 0x1E:
                parseReceivePing(msg);
                break;

            default:
                sendCancelWalk();
                break;
        }
    }
    else
    {
        //if(player->m_record != nullptr && !player->getBot())
            //g_dispatcher.addTask(createTask(boost::bind(&PlayerRecord::onDoAction, player->m_record, recvbyte, msg)));

#ifdef __DARGHOS_CUSTOM_SPELLS__
        bool hasPerfomedAction = false;
#endif

        switch(recvbyte)
        {
            case 0x14: // logout
                parseLogout(msg);
                break;

            case 0x1E: // keep alive / ping response
                parseReceivePing(msg);
                break;

            case 0x64: // move with steps
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseAutoWalk(msg);
                break;

            case 0x65: // move north
            case 0x66: // move east
            case 0x67: // move south
            case 0x68: // move west
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseMove(msg, (Direction)(recvbyte - 0x65));
                break;

            case 0x69: // stop-autowalk
                addGameTask(&Game::playerStopAutoWalk, player->getID());
                break;

            case 0x6A:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseMove(msg, NORTHEAST);
                break;

            case 0x6B:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseMove(msg, SOUTHEAST);
                break;

            case 0x6C:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseMove(msg, SOUTHWEST);
                break;

            case 0x6D:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseMove(msg, NORTHWEST);
                break;

            case 0x6F: // turn north
            case 0x70: // turn east
            case 0x71: // turn south
            case 0x72: // turn west
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseTurn(msg, (Direction)(recvbyte - 0x6F));
                break;

            case 0x78: // throw item
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseThrow(msg);
                break;

            case 0x79: // description in shop window
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseLookInShop(msg);
                break;

            case 0x7A: // player bought from shop
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parsePlayerPurchase(msg);
                break;

            case 0x7B: // player sold to shop
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parsePlayerSale(msg);
                break;

            case 0x7C: // player closed shop window
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCloseShop(msg);
                break;

            case 0x7D: // Request trade
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseRequestTrade(msg);
                break;

            case 0x7E: // Look at an item in trade
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseLookInTrade(msg);
                break;

            case 0x7F: // Accept trade
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseAcceptTrade(msg);
                break;

            case 0x80: // close/cancel trade
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCloseTrade();
                break;

            case 0x82: // use item
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseUseItem(msg);
                break;

            case 0x83: // use item
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseUseItemEx(msg);
                break;

            case 0x84: // battle window
                parseBattleWindow(msg);
                break;

            case 0x85: //rotate item
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseRotateItem(msg);
                break;

            case 0x87: // close container
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCloseContainer(msg);
                break;

            case 0x88: //"up-arrow" - container
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseUpArrowContainer(msg);
                break;

            case 0x89:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseTextWindow(msg);
                break;

            case 0x8A:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseHouseWindow(msg);
                break;

            case 0x8C: // throw item
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseLookAt(msg);
                break;

            case 0x96: // say something
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseSay(msg);
                break;

            case 0x97: // request channels
                parseGetChannels(msg);
                break;

            case 0x98: // open channel
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseOpenChannel(msg);
                break;

            case 0x99: // close channel
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCloseChannel(msg);
                break;

            case 0x9A: // open priv
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseOpenPriv(msg);
                break;

            case 0x9B: //process report
                parseProcessRuleViolation(msg);
                break;

            case 0x9C: //gm closes report
                parseCloseRuleViolation(msg);
                break;

            case 0x9D: //player cancels report
                parseCancelRuleViolation(msg);
                break;

            case 0x9E: // close NPC
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCloseNpc(msg);
                break;

            case 0xA0: // set attack and follow mode
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseFightModes(msg);
                break;

            case 0xA1: // attack
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseAttack(msg);
                break;

            case 0xA2: //follow
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseFollow(msg);
                break;

            case 0xA3: // invite party
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseInviteToParty(msg);
                break;

            case 0xA4: // join party
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseJoinParty(msg);
                break;

            case 0xA5: // revoke party
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseRevokePartyInvite(msg);
                break;

            case 0xA6: // pass leadership
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parsePassPartyLeadership(msg);
                break;

            case 0xA7: // leave party
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseLeaveParty(msg);
                break;

            case 0xA8: // share exp
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseSharePartyExperience(msg);
                break;

            case 0xAA:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCreatePrivateChannel(msg);
                break;

            case 0xAB:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseChannelInvite(msg);
                break;

            case 0xAC:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseChannelExclude(msg);
                break;

            case 0xBE: // cancel move
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseCancelMove(msg);
                break;

            case 0xC9: //client request to resend the tile
                parseUpdateTile(msg);
                break;

            case 0xCA: //client request to resend the container (happens when you store more than container maxsize)
                parseUpdateContainer(msg);
                break;

            case 0xD2: // request outfit
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                if((!player->hasCustomFlag(PlayerCustomFlag_GamemasterPrivileges) || !g_config.getBool(
                    ConfigManager::DISABLE_OUTFITS_PRIVILEGED)) && (g_config.getBool(ConfigManager::ALLOW_CHANGEOUTFIT)
                    || g_config.getBool(ConfigManager::ALLOW_CHANGECOLORS) || g_config.getBool(ConfigManager::ALLOW_CHANGEADDONS)))
                    parseRequestOutfit(msg);
                break;

            case 0xD3: // set outfit
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                if((!player->hasCustomFlag(PlayerCustomFlag_GamemasterPrivileges) || !g_config.getBool(ConfigManager::DISABLE_OUTFITS_PRIVILEGED))
                    && (g_config.getBool(ConfigManager::ALLOW_CHANGECOLORS) || g_config.getBool(ConfigManager::ALLOW_CHANGEOUTFIT)))
                    parseSetOutfit(msg);
                break;

            case 0xDC:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseAddVip(msg);
                break;

            case 0xDD:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseRemoveVip(msg);
                break;

            case 0xE6:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseBugReport(msg);
                break;

            case 0xE7:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseViolationWindow(msg);
                break;

            case 0xE8:
                parseDebugAssert(msg);
                break;

            case 0xF0:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseQuests(msg);
                break;

            case 0xF1:
#ifdef __DARGHOS_CUSTOM_SPELLS__
                hasPerfomedAction = true;
#endif
                parseQuestInfo(msg);
                break;

            case 0xF2:
                parseViolationReport(msg);
                break;

            default:
            {
                if(g_config.getBool(ConfigManager::BAN_UNKNOWN_BYTES))
                {
                    int64_t banTime = -1;
                    ViolationAction_t action = ACTION_BANISHMENT;
                    Account tmp = IOLoginData::getInstance()->loadAccount(player->getAccount(), true);

                    tmp.warnings++;
                    if(tmp.warnings >= g_config.getNumber(ConfigManager::WARNINGS_TO_DELETION))
                        action = ACTION_DELETION;
                    else if(tmp.warnings >= g_config.getNumber(ConfigManager::WARNINGS_TO_FINALBAN))
                    {
                        banTime = time(NULL) + g_config.getNumber(ConfigManager::FINALBAN_LENGTH);
                        action = ACTION_BANFINAL;
                    }
                    else
                        banTime = time(NULL) + g_config.getNumber(ConfigManager::BAN_LENGTH);

                    if(IOBan::getInstance()->addAccountBanishment(tmp.number, banTime, 13, action,
                        "Sending unknown packets to the server.", 0, player->getGUID()))
                    {
                        IOLoginData::getInstance()->saveAccount(tmp);
                        player->sendTextMessage(MSG_INFO_DESCR, "You have been banished.");

                        g_game.addMagicEffect(player->getPosition(), MAGIC_EFFECT_WRAPS_GREEN);
                        g_scheduler.addEvent(createSchedulerTask(1000, boost::bind(
                            &Game::kickPlayer, &g_game, player->getID(), false)));
                    }
                }

                std::stringstream hex;
                hex << "0x" << std::hex << (int16_t)recvbyte << std::dec;
                Logger::getInstance()->eFile(getFilePath(FILE_TYPE_LOG, "bots/" + player->getName() + ".log").c_str(),
                    "[" + formatDate() + "] Received byte " + hex.str(), false);
                break;
            }
        }

#ifdef __DARGHOS_CUSTOM_SPELLS__
        if(hasPerfomedAction)
            player->onPerformAction();
#endif
    }
}

void ProtocolGame::GetTileDescription(const Tile* tile, NetworkMessage& msg)
{
    if(!tile)
        return;

    int32_t count = 0;
    if(tile->ground)
    {
        msg.addItem(tile->ground);
        count++;
    }

    const TileItemVector* items = tile->getItemList();
    const CreatureVector* creatures = tile->getCreatures();

    ItemVector::const_iterator it;
    if(items)
    {
        for(it = items->getBeginTopItem(); (it != items->getEndTopItem() && count < 10); ++it, ++count)
            msg.addItem(*it);
    }

    if(creatures)
    {
        for(CreatureVector::const_reverse_iterator cit = creatures->rbegin(); (cit != creatures->rend() && count < 10); ++cit)
        {
            if(!player->canSeeCreature(*cit))
                continue;

            bool known;
            uint32_t removedKnown;

            checkCreatureAsKnown((*cit)->getID(), known, removedKnown);
            AddCreature(msg, (*cit), known, removedKnown);
            count++;
        }
    }

    if(items)
    {
        for(it = items->getBeginDownItem(); (it != items->getEndDownItem() && count < 10); ++it, ++count)
            msg.addItem(*it);
    }
}

void ProtocolGame::GetMapDescription(int32_t x, int32_t y, int32_t z,
    int32_t width, int32_t height, NetworkMessage& msg)
{
    int32_t skip = -1, startz, endz, zstep = 0;
    if(z > 7)
    {
        startz = z - 2;
        endz = std::min((int32_t)MAP_MAX_LAYERS - 1, z + 2);
        zstep = 1;
    }
    else
    {
        startz = 7;
        endz = 0;
        zstep = -1;
    }

    for(int32_t nz = startz; nz != endz + zstep; nz += zstep)
        GetFloorDescription(msg, x, y, nz, width, height, z - nz, skip);

    if(skip >= 0)
    {
        msg.add<uint8_t>(skip);
        msg.add<uint8_t>(0xFF);
        //cc += skip;
    }
}

void ProtocolGame::GetFloorDescription(NetworkMessage& msg, int32_t x, int32_t y, int32_t z,
        int32_t width, int32_t height, int32_t offset, int32_t& skip)
{
    Tile* tile = NULL;
    for(int32_t nx = 0; nx < width; nx++)
    {
        for(int32_t ny = 0; ny < height; ny++)
        {
            if((tile = g_game.getTile(Position(x + nx + offset, y + ny + offset, z))))
            {
                if(skip >= 0)
                {
                    msg.add<uint8_t>(skip);
                    msg.add<uint8_t>(0xFF);
                }

                skip = 0;
                GetTileDescription(tile, msg);
            }
            else
            {
                ++skip;
                if(skip == 0xFF)
                {
                    msg.add<uint8_t>(0xFF);
                    msg.add<uint8_t>(0xFF);
                    skip = -1;
                }
            }
        }
    }
}

void ProtocolGame::checkCreatureAsKnown(uint32_t id, bool& known, uint32_t& removedKnown)
{
    auto result = knownCreatureSet.insert(id);
    if (!result.second) {
        known = true;
        return;
    }

    known = false;

    if (knownCreatureSet.size() > 250) {
        // Look for a creature to remove
        for (std::unordered_set<uint32_t>::iterator it = knownCreatureSet.begin(); it != knownCreatureSet.end(); ++it) {
            Creature* creature = g_game.getCreatureByID(*it);
            if (creature == nullptr) {
                removedKnown = *it;
                knownCreatureSet.erase(it);
                return;
            }
            else if(!canSee(creature)){
                removedKnown = *it;
                knownCreatureSet.erase(it);
                return;
            }
        }

        // Bad situation. Let's just remove anyone.
        std::unordered_set<uint32_t>::iterator it = knownCreatureSet.begin();
        if (*it == id) {
            ++it;
        }

        removedKnown = *it;
        knownCreatureSet.erase(it);
    } else {
        removedKnown = 0;
    }
}

bool ProtocolGame::canSee(const Creature* c) const
{
    return !c->isRemoved() && player->canSeeCreature(c) && canSee(c->getPosition());
}

bool ProtocolGame::canSee(const Position& pos) const
{
    return canSee(pos.x, pos.y, pos.z);
}

bool ProtocolGame::canSee(uint16_t x, uint16_t y, uint16_t z) const
{
#ifdef __DEBUG__
    if(z >= MAP_MAX_LAYERS)
        std::clog << "[Warning - ProtocolGame::canSee] Z-value is out of range!" << std::endl;
#endif

    const Position& myPos = player->getPosition();
    if(myPos.z <= 7)
    {
        //we are on ground level or above (7 -> 0), view is from 7 -> 0
        if(z > 7)
            return false;
    }
    else if(myPos.z >= 8 && std::abs(myPos.z - z) > 2) //we are underground (8 -> 15), view is +/- 2 from the floor we stand on
        return false;

    //negative offset means that the action taken place is on a lower floor than ourself
    int32_t offsetz = myPos.z - z;
    return ((x >= myPos.x - 8 + offsetz) && (x <= myPos.x + 9 + offsetz) &&
        (y >= myPos.y - 6 + offsetz) && (y <= myPos.y + 7 + offsetz));
}

//********************** Parse methods *******************************//
void ProtocolGame::parseLogout(NetworkMessage&)
{
    g_dispatcher.addTask(createTask(boost::bind(&ProtocolGame::logout, this, true, false)));
}

void ProtocolGame::parseCreatePrivateChannel(NetworkMessage&)
{
    addGameTask(&Game::playerCreatePrivateChannel, player->getID());
}

void ProtocolGame::parseChannelInvite(NetworkMessage& msg)
{
    const std::string name = msg.getString();
    addGameTask(&Game::playerChannelInvite, player->getID(), name);
}

void ProtocolGame::parseChannelExclude(NetworkMessage& msg)
{
    const std::string name = msg.getString();
    addGameTask(&Game::playerChannelExclude, player->getID(), name);
}

void ProtocolGame::parseGetChannels(NetworkMessage&)
{
    addGameTask(&Game::playerRequestChannels, player->getID());
}

void ProtocolGame::parseOpenChannel(NetworkMessage& msg)
{
    uint16_t channelId = msg.get<uint16_t>();
    addGameTask(&Game::playerOpenChannel, player->getID(), channelId);
}

void ProtocolGame::parseCloseChannel(NetworkMessage& msg)
{
    uint16_t channelId = msg.get<uint16_t>();
    addGameTask(&Game::playerCloseChannel, player->getID(), channelId);
}

void ProtocolGame::parseOpenPriv(NetworkMessage& msg)
{
    const std::string receiver = msg.getString();
    addGameTask(&Game::playerOpenPrivateChannel, player->getID(), receiver);
}

void ProtocolGame::parseProcessRuleViolation(NetworkMessage& msg)
{
    const std::string reporter = msg.getString();
    addGameTask(&Game::playerProcessRuleViolation, player->getID(), reporter);
}

void ProtocolGame::parseCloseRuleViolation(NetworkMessage& msg)
{
    const std::string reporter = msg.getString();
    addGameTask(&Game::playerCloseRuleViolation, player->getID(), reporter);
}

void ProtocolGame::parseCancelRuleViolation(NetworkMessage&)
{
    addGameTask(&Game::playerCancelRuleViolation, player->getID());
}

void ProtocolGame::parseCloseNpc(NetworkMessage&)
{
    addGameTask(&Game::playerCloseNpcChannel, player->getID());
}

void ProtocolGame::parseCancelMove(NetworkMessage&)
{
    addGameTask(&Game::playerCancelAttackAndFollow, player->getID());
}

void ProtocolGame::parseReceivePing(NetworkMessage&)
{
    addGameTask(&Game::playerReceivePing, player->getID());
}

void ProtocolGame::parseAutoWalk(NetworkMessage& msg)
{
    // first we get all directions...
    std::list<Direction> path;
    size_t dirCount = msg.get<char>();
    for(size_t i = 0; i < dirCount; ++i)
    {
        uint8_t rawDir = msg.get<char>();
        Direction dir = SOUTH;
        switch(rawDir)
        {
            case 1:
                dir = EAST;
                break;
            case 2:
                dir = NORTHEAST;
                break;
            case 3:
                dir = NORTH;
                break;
            case 4:
                dir = NORTHWEST;
                break;
            case 5:
                dir = WEST;
                break;
            case 6:
                dir = SOUTHWEST;
                break;
            case 7:
                dir = SOUTH;
                break;
            case 8:
                dir = SOUTHEAST;
                break;
            default:
                continue;
        }

        path.push_back(dir);
    }

    addGameTask(&Game::playerAutoWalk, player->getID(), path);
}

void ProtocolGame::parseMove(NetworkMessage&, Direction dir)
{
    addGameTask(&Game::playerMove, player->getID(), dir);
}

void ProtocolGame::parseTurn(NetworkMessage&, Direction dir)
{
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerTurn, player->getID(), dir);
}

void ProtocolGame::parseRequestOutfit(NetworkMessage&)
{
    addGameTask(&Game::playerRequestOutfit, player->getID());
}

void ProtocolGame::parseSetOutfit(NetworkMessage& msg)
{
    Outfit_t newOutfit = player->defaultOutfit;
    if(g_config.getBool(ConfigManager::ALLOW_CHANGEOUTFIT))
        newOutfit.lookType = msg.get<uint16_t>();
    else
        msg.skipBytes(2);

    if(g_config.getBool(ConfigManager::ALLOW_CHANGECOLORS))
    {
        newOutfit.lookHead = msg.get<char>();
        newOutfit.lookBody = msg.get<char>();
        newOutfit.lookLegs = msg.get<char>();
        newOutfit.lookFeet = msg.get<char>();
    }
    else
        msg.skipBytes(4);

    if(g_config.getBool(ConfigManager::ALLOW_CHANGEADDONS))
        newOutfit.lookAddons = msg.get<char>();
    else
        msg.skipBytes(1);

    addGameTask(&Game::playerChangeOutfit, player->getID(), newOutfit);
}

void ProtocolGame::parseUseItem(NetworkMessage& msg)
{
    Position pos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t stackpos = msg.get<char>();
    uint8_t index = msg.get<char>();
    bool isHotkey = (pos.x == 0xFFFF && !pos.y && !pos.z);
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerUseItem, player->getID(), pos, stackpos, index, spriteId, isHotkey);
}

void ProtocolGame::parseUseItemEx(NetworkMessage& msg)
{
    Position fromPos = msg.getPosition();
    uint16_t fromSpriteId = msg.get<uint16_t>();
    int16_t fromStackpos = msg.get<char>();
    Position toPos = msg.getPosition();
    uint16_t toSpriteId = msg.get<uint16_t>();
    int16_t toStackpos = msg.get<char>();
    bool isHotkey = (fromPos.x == 0xFFFF && !fromPos.y && !fromPos.z);
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerUseItemEx, player->getID(),
        fromPos, fromStackpos, fromSpriteId, toPos, toStackpos, toSpriteId, isHotkey);
}

void ProtocolGame::parseBattleWindow(NetworkMessage& msg)
{
    Position fromPos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t fromStackpos = msg.get<char>();
    uint32_t creatureId = msg.get<uint32_t>();
    bool isHotkey = (fromPos.x == 0xFFFF && !fromPos.y && !fromPos.z);
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerUseBattleWindow, player->getID(), fromPos, fromStackpos, creatureId, spriteId, isHotkey);
}

void ProtocolGame::parseCloseContainer(NetworkMessage& msg)
{
    uint8_t cid = msg.get<char>();
    addGameTask(&Game::playerCloseContainer, player->getID(), cid);
}

void ProtocolGame::parseUpArrowContainer(NetworkMessage& msg)
{
    uint8_t cid = msg.get<char>();
    addGameTask(&Game::playerMoveUpContainer, player->getID(), cid);
}

void ProtocolGame::parseUpdateTile(NetworkMessage& msg)
{
    Position pos = msg.getPosition();
    //addGameTask(&Game::playerUpdateTile, player->getID(), pos);
}

void ProtocolGame::parseUpdateContainer(NetworkMessage& msg)
{
    uint8_t cid = msg.get<char>();
    addGameTask(&Game::playerUpdateContainer, player->getID(), cid);
}

void ProtocolGame::parseThrow(NetworkMessage& msg)
{
    Position fromPos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t fromStackpos = msg.get<char>();
    Position toPos = msg.getPosition();
    uint8_t count = msg.get<char>();
    if(toPos != fromPos)
        addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerMoveThing,
            player->getID(), fromPos, spriteId, fromStackpos, toPos, count);
}

void ProtocolGame::parseLookAt(NetworkMessage& msg)
{
    Position pos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t stackpos = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerLookAt, player->getID(), pos, spriteId, stackpos);
}

void ProtocolGame::parseSay(NetworkMessage& msg)
{
    std::string receiver;
    uint16_t channelId = 0;

    SpeakClasses type = (SpeakClasses)msg.get<char>();
    switch(type)
    {
        case SPEAK_PRIVATE:
        case SPEAK_PRIVATE_RED:
        case SPEAK_RVR_ANSWER:
            receiver = msg.getString();
            break;

        case SPEAK_CHANNEL_Y:
        case SPEAK_CHANNEL_RN:
        case SPEAK_CHANNEL_RA:
            channelId = msg.get<uint16_t>();
            break;

        default:
            break;
    }

    const std::string text = msg.getString();
    if(text.length() > 255) //client limit
    {
        std::stringstream s;
        s << text.length();

        Logger::getInstance()->eFile("bots/" + player->getName() + ".log", "Attempt to send message with size " + s.str() + " - client is limited to 255 characters.", true);
        return;
    }

    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerSay, player->getID(), channelId, type, receiver, text);
}

void ProtocolGame::parseFightModes(NetworkMessage& msg)
{
    uint8_t rawFightMode = msg.get<char>(); //1 - offensive, 2 - balanced, 3 - defensive
    uint8_t rawChaseMode = msg.get<char>(); //0 - stand while fightning, 1 - chase opponent
    uint8_t rawSecureMode = msg.get<char>(); //0 - can't attack unmarked, 1 - can attack unmarked

    chaseMode_t chaseMode = CHASEMODE_STANDSTILL;
    if(rawChaseMode == 1)
        chaseMode = CHASEMODE_FOLLOW;

    fightMode_t fightMode = FIGHTMODE_ATTACK;
    if(rawFightMode == 2)
        fightMode = FIGHTMODE_BALANCED;
    else if(rawFightMode == 3)
        fightMode = FIGHTMODE_DEFENSE;

    secureMode_t secureMode = SECUREMODE_OFF;
    if(rawSecureMode == 1)
        secureMode = SECUREMODE_ON;

    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerSetFightModes, player->getID(), fightMode, chaseMode, secureMode);
}

void ProtocolGame::parseAttack(NetworkMessage& msg)
{
    uint32_t creatureId = msg.get<uint32_t>();
    msg.get<uint32_t>();
    msg.get<uint32_t>();

    addGameTask(&Game::playerSetAttackedCreature, player->getID(), creatureId);
}

void ProtocolGame::parseFollow(NetworkMessage& msg)
{
    uint32_t creatureId = msg.get<uint32_t>();
    addGameTask(&Game::playerFollowCreature, player->getID(), creatureId);
}

void ProtocolGame::parseTextWindow(NetworkMessage& msg)
{
    uint32_t windowTextId = msg.get<uint32_t>();
    const std::string newText = msg.getString();
    addGameTask(&Game::playerWriteItem, player->getID(), windowTextId, newText);
}

void ProtocolGame::parseHouseWindow(NetworkMessage &msg)
{
    uint8_t doorId = msg.get<char>();
    uint32_t id = msg.get<uint32_t>();
    const std::string text = msg.getString();
    addGameTask(&Game::playerUpdateHouseWindow, player->getID(), doorId, id, text);
}

void ProtocolGame::parseLookInShop(NetworkMessage &msg)
{
    uint16_t id = msg.get<uint16_t>();
    uint16_t count = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerLookInShop, player->getID(), id, count);
}

void ProtocolGame::parsePlayerPurchase(NetworkMessage &msg)
{
    uint16_t id = msg.get<uint16_t>();
    uint16_t count = msg.get<char>();
    uint16_t amount = msg.get<char>();
    bool ignoreCap = msg.get<char>();
    bool inBackpacks = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerPurchaseItem, player->getID(), id, count, amount, ignoreCap, inBackpacks);
}

void ProtocolGame::parsePlayerSale(NetworkMessage &msg)
{
    uint16_t id = msg.get<uint16_t>();
    uint16_t count = msg.get<char>();
    uint16_t amount = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerSellItem, player->getID(), id, count, amount);
}

void ProtocolGame::parseCloseShop(NetworkMessage&)
{
    addGameTask(&Game::playerCloseShop, player->getID());
}

void ProtocolGame::parseRequestTrade(NetworkMessage& msg)
{
    Position pos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t stackpos = msg.get<char>();
    uint32_t playerId = msg.get<uint32_t>();
    addGameTask(&Game::playerRequestTrade, player->getID(), pos, stackpos, playerId, spriteId);
}

void ProtocolGame::parseAcceptTrade(NetworkMessage&)
{
    addGameTask(&Game::playerAcceptTrade, player->getID());
}

void ProtocolGame::parseLookInTrade(NetworkMessage& msg)
{
    bool counter = msg.get<char>();
    int32_t index = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerLookInTrade, player->getID(), counter, index);
}

void ProtocolGame::parseCloseTrade()
{
    addGameTask(&Game::playerCloseTrade, player->getID());
}

void ProtocolGame::parseAddVip(NetworkMessage& msg)
{
    const std::string name = msg.getString();
    if(name.size() > 32)
        return;

    addGameTask(&Game::playerRequestAddVip, player->getID(), name);
}

void ProtocolGame::parseRemoveVip(NetworkMessage& msg)
{
    uint32_t guid = msg.get<uint32_t>();
    addGameTask(&Game::playerRequestRemoveVip, player->getID(), guid);
}

void ProtocolGame::parseRotateItem(NetworkMessage& msg)
{
    Position pos = msg.getPosition();
    uint16_t spriteId = msg.get<uint16_t>();
    int16_t stackpos = msg.get<char>();
    addGameTaskTimed(DISPATCHER_TASK_EXPIRATION, &Game::playerRotateItem, player->getID(), pos, stackpos, spriteId);
}

void ProtocolGame::parseDebugAssert(NetworkMessage& msg)
{
    if(m_debugAssertSent)
        return;

    std::stringstream s;
    s << "----- " << formatDate() << " - " << player->getName() << " (" << convertIPAddress(getIP())
        << ") -----" << std::endl << msg.getString() << std::endl << msg.getString()
        << std::endl << msg.getString() << std::endl << msg.getString()
        << std::endl << std::endl;

    m_debugAssertSent = true;
    Logger::getInstance()->iFile(LOGFILE_ASSERTIONS, s.str(), false);
}

void ProtocolGame::parseBugReport(NetworkMessage& msg)
{
    std::string comment = msg.getString();
    addGameTask(&Game::playerReportBug, player->getID(), comment);
}

void ProtocolGame::parseInviteToParty(NetworkMessage& msg)
{
    uint32_t targetId = msg.get<uint32_t>();
    addGameTask(&Game::playerInviteToParty, player->getID(), targetId);
}

void ProtocolGame::parseJoinParty(NetworkMessage& msg)
{
    uint32_t targetId = msg.get<uint32_t>();
    addGameTask(&Game::playerJoinParty, player->getID(), targetId);
}

void ProtocolGame::parseRevokePartyInvite(NetworkMessage& msg)
{
    uint32_t targetId = msg.get<uint32_t>();
    addGameTask(&Game::playerRevokePartyInvitation, player->getID(), targetId);
}

void ProtocolGame::parsePassPartyLeadership(NetworkMessage& msg)
{
    uint32_t targetId = msg.get<uint32_t>();
    addGameTask(&Game::playerPassPartyLeadership, player->getID(), targetId);
}

void ProtocolGame::parseLeaveParty(NetworkMessage&)
{
    addGameTask(&Game::playerLeaveParty, player->getID(), false);
}

void ProtocolGame::parseSharePartyExperience(NetworkMessage& msg)
{
    bool activate = msg.get<char>();
    uint8_t unknown = msg.get<char>(); //TODO: find out what is this byte
    addGameTask(&Game::playerSharePartyExperience, player->getID(), activate, unknown);
}

void ProtocolGame::parseQuests(NetworkMessage&)
{
    addGameTask(&Game::playerQuests, player->getID());
}

void ProtocolGame::parseQuestInfo(NetworkMessage& msg)
{
    uint16_t questId = msg.get<uint16_t>();
    addGameTask(&Game::playerQuestInfo, player->getID(), questId);
}

void ProtocolGame::parseViolationWindow(NetworkMessage& msg)
{
    std::string target = msg.getString();
    uint8_t reason = msg.get<char>();
    ViolationAction_t action = (ViolationAction_t)msg.get<char>();
    std::string comment = msg.getString();
    std::string statement = msg.getString();
    uint32_t statementId = (uint32_t)msg.get<uint16_t>();
    bool ipBanishment = msg.get<char>();
    addGameTask(&Game::playerViolationWindow, player->getID(), target,
        reason, action, comment, statement, statementId, ipBanishment);
}

void ProtocolGame::parseViolationReport(NetworkMessage& msg)
{
    msg.skipBytes(msg.getLength() - msg.getBufferPosition());
    // addGameTask(&Game::playerViolationReport, player->getID(), ...);
}

//********************** Send methods *******************************//
void ProtocolGame::sendOpenPrivateChannel(const std::string& receiver)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xAD);
    msg.addString(receiver);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureOutfit(const Creature* creature, const Outfit_t& outfit)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x8E);
    msg.add<uint32_t>(creature->getID());
    AddCreatureOutfit(msg, creature, outfit);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureLight(const Creature* creature)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    AddCreatureLight(msg, creature);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendWorldLight(const LightInfo& lightInfo)
{
    NetworkMessage msg;
    AddWorldLight(msg, lightInfo);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureEmblem(const Creature* creature)
{
    if(!canSee(creature))
        return;

    // we are cheating the client in here!
    uint32_t stackpos = creature->getTile()->getClientIndexOfThing(player, creature);
    if(stackpos >= 10)
        return;

    NetworkMessage msg;
    bool found = false;
    for (std::unordered_set<uint32_t>::iterator it = knownCreatureSet.begin(); it != knownCreatureSet.end(); ++it) {
        if(creature->getID() == (*it)){
            found = true;
            break;
        }
    }

    if(found)
    {
        RemoveTileItem(msg, creature->getPosition(), stackpos);
        msg.add<uint8_t>(0x6A);

        msg.addPosition(creature->getPosition());
        msg.add<uint8_t>(stackpos);
        AddCreature(msg, creature, false, creature->getID());
    }
    else
        AddTileCreature(msg, creature->getPosition(), stackpos, creature);

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureWalkthrough(const Creature* creature, bool walkthrough)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x92);
    msg.add<uint32_t>(creature->getID());
    msg.add<uint8_t>(!walkthrough);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureShield(const Creature* creature)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x91);
    msg.add<uint32_t>(creature->getID());
    msg.add<uint8_t>(player->getPartyShield(creature));
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureSkull(const Creature* creature)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x90);
    msg.add<uint32_t>(creature->getID());
    msg.add<uint8_t>(player->getSkullType(creature));
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureSquare(const Creature* creature, uint8_t color)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x86);
    msg.add<uint32_t>(creature->getID());
    msg.add<uint8_t>(color);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendTutorial(uint8_t tutorialId)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xDC);
    msg.add<uint8_t>(tutorialId);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendAddMarker(const Position& pos, MapMarks_t markType, const std::string& desc)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xDD);
    msg.addPosition(pos);
    msg.add<uint8_t>(markType);
    msg.addString(desc);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendReLoginWindow()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x28);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendStats()
{
    NetworkMessage msg;
    AddPlayerStats(msg);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendTextMessage(MessageClasses mClass, const std::string& message)
{
    NetworkMessage msg;
    AddTextMessage(msg, mClass, message);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendClosePrivate(uint16_t channelId)
{
    NetworkMessage msg;

    if(channelId == CHANNEL_GUILD || channelId == CHANNEL_PARTY)
            g_chat.removeUserFromChannel(player, channelId);

    msg.add<uint8_t>(0xB3);
    msg.add<uint16_t>(channelId);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatePrivateChannel(uint16_t channelId, const std::string& channelName)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xB2);
    msg.add<uint16_t>(channelId);
    msg.addString(channelName);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendChannelsDialog()
{
    NetworkMessage msg;

    msg.add<uint8_t>(0xAB);
    ChannelList list = g_chat.getChannelList(player);
    msg.add<uint8_t>(list.size());
    for(ChannelList::iterator it = list.begin(); it != list.end(); ++it)
    {
        if(ChatChannel* channel = (*it))
        {
            msg.add<uint16_t>(channel->getId());
            msg.addString(channel->getName());
        }
    }
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendChannel(uint16_t channelId, const std::string& channelName)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xAC);
    msg.add<uint16_t>(channelId);
    msg.addString(channelName);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRuleViolationsChannel(uint16_t channelId)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xAE);
    msg.add<uint16_t>(channelId);
    for(RuleViolationsMap::const_iterator it = g_game.getRuleViolations().begin(); it != g_game.getRuleViolations().end(); ++it)
    {
        RuleViolation& rvr = *it->second;
        if(rvr.isOpen && rvr.reporter)
            AddCreatureSpeak(msg, rvr.reporter, SPEAK_RVR_CHANNEL, rvr.text, channelId, rvr.time);
    }
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRemoveReport(const std::string& name)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xAF);
    msg.addString(name);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRuleViolationCancel(const std::string& name)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xB0);
    msg.addString(name);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendLockRuleViolation()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xB1);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendIcons(int32_t icons)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xA2);
    msg.add<uint16_t>(icons);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendContainer(uint32_t cid, const Container* container, bool hasParent)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x6E);
    msg.add<uint8_t>(cid);

    msg.addItem(container);
    msg.addString(container->getName());
    msg.add<uint8_t>(container->capacity());

    msg.add<uint8_t>(hasParent ? 0x01 : 0x00);
    msg.add<uint8_t>(std::min(container->size(), (uint32_t)255));

    ItemList::const_iterator cit = container->getItems();
    for(uint32_t i = 0; cit != container->getEnd() && i < 255; ++cit, ++i)
        msg.addItem(*cit);

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendShop(const ShopInfoList& shop)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x7A);
    msg.add<uint8_t>(std::min(shop.size(), (size_t)255));

    ShopInfoList::const_iterator it = shop.begin();
    for(uint32_t i = 0; it != shop.end() && i < 255; ++it, ++i)
        AddShopItem(msg, (*it));

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCloseShop()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x7C);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendGoods(const ShopInfoList& shop)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x7B);
    msg.add<uint32_t>((uint32_t)g_game.getMoney(player));

    std::map<uint32_t, uint32_t> goodsMap;
    if(shop.size() >= 5)
    {
        for(ShopInfoList::const_iterator sit = shop.begin(); sit != shop.end(); ++sit)
        {
            if(sit->sellPrice < 0)
                continue;

            int8_t subType = -1;
            if(sit->subType)
            {
                const ItemType& it = Item::items[sit->itemId];
                if(it.hasSubType() && !it.stackable)
                    subType = sit->subType;
            }

            uint32_t count = player->__getItemTypeCount(sit->itemId, subType);
            if(count > 0)
                goodsMap[sit->itemId] = count;
        }
    }
    else
    {
        std::map<uint32_t, uint32_t> tmpMap;
        player->__getAllItemTypeCount(tmpMap);
        for(ShopInfoList::const_iterator sit = shop.begin(); sit != shop.end(); ++sit)
        {
            if(sit->sellPrice < 0)
                continue;

            int8_t subType = -1;
            const ItemType& it = Item::items[sit->itemId];
            if(sit->subType && it.hasSubType() && !it.stackable)
                subType = sit->subType;

            if(subType != -1)
            {
                uint32_t count = subType;
                if(!it.isFluidContainer() && !it.isSplash())
                    count = player->__getItemTypeCount(sit->itemId, subType);

                if(count > 0)
                    goodsMap[sit->itemId] = count;
                else
                    goodsMap[sit->itemId] = 0;
            }
            else
                goodsMap[sit->itemId] = tmpMap[sit->itemId];
        }
    }

    msg.add<uint8_t>(std::min(goodsMap.size(), (size_t)255));
    std::map<uint32_t, uint32_t>::const_iterator it = goodsMap.begin();
    for(uint32_t i = 0; it != goodsMap.end() && i < 255; ++it, ++i)
    {
        msg.addItemId(it->first);
        msg.add<uint8_t>(std::min(it->second, (uint32_t)255));
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendTradeItemRequest(const Player* player, const Item* item, bool ack)
{
    NetworkMessage msg;
    if(ack)
        msg.add<uint8_t>(0x7D);
    else
        msg.add<uint8_t>(0x7E);

    msg.addString(player->getName());
    if(const Container* container = item->getContainer())
    {
        msg.add<uint8_t>(container->getItemHoldingCount() + 1);
        msg.addItem(item);
        for(ContainerIterator it = container->begin(); it != container->end(); ++it)
            msg.addItem(*it);
    }
    else
    {
        msg.add<uint8_t>(1);
        msg.addItem(item);
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCloseTrade()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x7F);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCloseContainer(uint32_t cid)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x6F);
    msg.add<uint8_t>(cid);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureTurn(const Creature* creature, int16_t stackpos)
{
    if(stackpos >= 10 || !canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x6B);
    msg.addPosition(creature->getPosition());
    msg.add<uint8_t>(stackpos);
    msg.add<uint16_t>(0x63); /*99*/
    msg.add<uint32_t>(creature->getID());
    msg.add<uint8_t>(creature->getDirection());
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureSay(const Creature* creature, SpeakClasses type, const std::string& text, Position* pos/* = NULL*/)
{
    NetworkMessage msg;
    AddCreatureSpeak(msg, creature, type, text, 0, 0, pos);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendToChannel(const Creature* creature, SpeakClasses type, const std::string& text, uint16_t channelId, uint32_t time /*= 0*/)
{
    NetworkMessage msg;
    AddCreatureSpeak(msg, creature, type, text, channelId, time);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCancel(const std::string& message)
{
    NetworkMessage msg;
    AddTextMessage(msg, MSG_STATUS_SMALL, message);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCancelTarget()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xA3);
    msg.add<uint32_t>(0);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendChangeSpeed(const Creature* creature, uint32_t speed)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x8F);
    msg.add<uint32_t>(creature->getID());
    msg.add<uint16_t>(speed);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCancelWalk()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xB5);
    msg.add<uint8_t>(player->getDirection());
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendSkills()
{
    NetworkMessage msg;
    AddPlayerSkills(msg);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendPing()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x1E);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendDistanceShoot(const Position& from, const Position& to, uint8_t type)
{
    if(type > SHOOT_EFFECT_LAST || (!canSee(from) && !canSee(to)))
        return;

    NetworkMessage msg;
    AddDistanceShoot(msg, from, to, type);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendMagicEffect(const Position& pos, uint8_t type)
{
    if(type > MAGIC_EFFECT_LAST || !canSee(pos))
        return;

    NetworkMessage msg;
    AddMagicEffect(msg, pos, type);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendAnimatedText(const Position& pos, uint8_t color, std::string text)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    AddAnimatedText(msg, pos, color, text);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendCreatureHealth(const Creature* creature)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;
    AddCreatureHealth(msg, creature);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendFYIBox(const std::string& message)
{
    if(message.empty() || message.length() > 1018) //Prevent client debug when message is empty or length is > 1018 (not confirmed)
    {
        std::clog << "[Warning - ProtocolGame::sendFYIBox] Trying to send an empty or too huge message." << std::endl;
        return;
    }

    NetworkMessage msg;
    msg.add<uint8_t>(0x15);
    msg.addString(message);
    writeToOutputBuffer(msg);
}

//tile
void ProtocolGame::sendAddTileItem(const Tile*, const Position& pos, uint32_t stackpos, const Item* item)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    AddTileItem(msg, pos, stackpos, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendUpdateTileItem(const Tile*, const Position& pos, uint32_t stackpos, const Item* item)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    UpdateTileItem(msg, pos, stackpos, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRemoveTileItem(const Tile*, const Position& pos, uint32_t stackpos)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    RemoveTileItem(msg, pos, stackpos);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendUpdateTile(const Tile* tile, const Position& pos)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    msg.add<uint8_t>(0x69);
    msg.addPosition(pos);
    if(tile)
    {
        GetTileDescription(tile, msg);
        msg.add<uint8_t>(0x00);
        msg.add<uint8_t>(0xFF);
    }
    else
    {
        msg.add<uint8_t>(0x01);
        msg.add<uint8_t>(0xFF);
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendAddCreature(const Creature* creature, const Position& pos, uint32_t stackpos)
{
    if(!canSee(creature))
        return;

    NetworkMessage msg;

    if(creature != player)
    {
        AddTileCreature(msg, pos, stackpos, creature);
        writeToOutputBuffer(msg);
        return;
    }

    msg.add<uint8_t>(0x0A);
    msg.add<uint32_t>(player->getID());
    msg.add<uint16_t>(0x32);

    msg.add<uint8_t>(player->hasFlag(PlayerFlag_CanReportBugs));
    if(Group* group = player->getGroup())
    {
        int32_t reasons = group->getViolationReasons();
        if(reasons > 1)
        {
            msg.add<uint8_t>(0x0B);
            for(int32_t i = 0; i < 20; ++i)
            {
                if(i < 4)
                    msg.add<uint8_t>(group->getNameViolationFlags());
                else if(i < reasons)
                    msg.add<uint8_t>(group->getStatementViolationFlags());
                else
                    msg.add<uint8_t>(0x00);
            }
        }
    }

    AddMapDescription(msg, pos);
    for(int32_t i = SLOT_FIRST; i < SLOT_LAST; ++i)
        AddInventoryItem(msg, (slots_t)i, player->getInventoryItem((slots_t)i));

    AddPlayerStats(msg);
    AddPlayerSkills(msg);

    //gameworld light-settings
    LightInfo lightInfo;
    g_game.getWorldLightInfo(lightInfo);

    AddWorldLight(msg, lightInfo);
    //player light level
    AddCreatureLight(msg, creature);

    player->sendIcons();
    for(VIPSet::iterator it = player->VIPList.begin(); it != player->VIPList.end(); it++)
    {
        std::string vipName;
        if(IOLoginData::getInstance()->getNameByGuid((*it), vipName))
        {
            Player* tmpPlayer = g_game.getPlayerByName(vipName);
            sendVIP((*it), vipName, (tmpPlayer && player->canSeeCreature(tmpPlayer)));
        }
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRemoveCreature(const Creature*, const Position& pos, uint32_t stackpos)
{
    if(!canSee(pos))
        return;

    NetworkMessage msg;
    RemoveTileItem(msg, pos, stackpos);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendMoveCreature(const Creature* creature, const Tile*, const Position& newPos,
    uint32_t newStackpos, const Tile*, const Position& oldPos, uint32_t oldStackpos, bool teleport)
{
    if(creature == player)
    {
        NetworkMessage msg;
        if(teleport || oldStackpos >= 10)
        {
            RemoveTileItem(msg, oldPos, oldStackpos);
            AddMapDescription(msg, newPos);
        }
        else
        {
            if(oldPos.z != 7 || newPos.z < 8)
            {
                msg.add<uint8_t>(0x6D);
                msg.addPosition(oldPos);
                msg.add<uint8_t>(oldStackpos);
                msg.addPosition(newPos);
            }
            else
                RemoveTileItem(msg, oldPos, oldStackpos);

            if(newPos.z > oldPos.z)
                MoveDownCreature(msg, creature, newPos, oldPos, oldStackpos);
            else if(newPos.z < oldPos.z)
                MoveUpCreature(msg, creature, newPos, oldPos, oldStackpos);

            if(oldPos.y > newPos.y) // north, for old x
            {
                msg.add<uint8_t>(0x65);
                GetMapDescription(oldPos.x - 8, newPos.y - 6, newPos.z, 18, 1, msg);
            }
            else if(oldPos.y < newPos.y) // south, for old x
            {
                msg.add<uint8_t>(0x67);
                GetMapDescription(oldPos.x - 8, newPos.y + 7, newPos.z, 18, 1, msg);
            }

            if(oldPos.x < newPos.x) // east, [with new y]
            {
                msg.add<uint8_t>(0x66);
                GetMapDescription(newPos.x + 9, newPos.y - 6, newPos.z, 1, 14, msg);
            }
            else if(oldPos.x > newPos.x) // west, [with new y]
            {
                msg.add<uint8_t>(0x68);
                GetMapDescription(newPos.x - 8, newPos.y - 6, newPos.z, 1, 14, msg);
            }
        }

        writeToOutputBuffer(msg);
    }
    else if(canSee(oldPos) && canSee(newPos))
    {
        if(!player->canSeeCreature(creature))
            return;

        NetworkMessage msg;
        if(!teleport && (oldPos.z != 7 || newPos.z < 8) && oldStackpos < 10)
        {
            msg.add<uint8_t>(0x6D);
            msg.addPosition(oldPos);
            msg.add<uint8_t>(oldStackpos);
            msg.addPosition(newPos);
        }
        else
        {
            RemoveTileItem(msg, oldPos, oldStackpos);
            AddTileCreature(msg, newPos, newStackpos, creature);
        }

        writeToOutputBuffer(msg);
    }
    else if(canSee(oldPos))
    {
        if(!player->canSeeCreature(creature))
            return;

        NetworkMessage msg;
        RemoveTileItem(msg, oldPos, oldStackpos);
        writeToOutputBuffer(msg);
    }
    else if(canSee(newPos) && player->canSeeCreature(creature))
    {
        NetworkMessage msg;
        AddTileCreature(msg, newPos, newStackpos, creature);
        writeToOutputBuffer(msg);
    }
}

//inventory
void ProtocolGame::sendAddInventoryItem(slots_t slot, const Item* item)
{
    NetworkMessage msg;
    AddInventoryItem(msg, slot, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendUpdateInventoryItem(slots_t slot, const Item* item)
{
    NetworkMessage msg;
    UpdateInventoryItem(msg, slot, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRemoveInventoryItem(slots_t slot)
{
    NetworkMessage msg;
    RemoveInventoryItem(msg, slot);
    writeToOutputBuffer(msg);
}

//containers
void ProtocolGame::sendAddContainerItem(uint8_t cid, const Item* item)
{
    NetworkMessage msg;
    AddContainerItem(msg, cid, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendUpdateContainerItem(uint8_t cid, uint8_t slot, const Item* item)
{
    NetworkMessage msg;
    UpdateContainerItem(msg, cid, slot, item);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendRemoveContainerItem(uint8_t cid, uint8_t slot)
{
    NetworkMessage msg;
    RemoveContainerItem(msg, cid, slot);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendTextWindow(uint32_t windowTextId, Item* item, uint16_t maxLen, bool canWrite)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x96);
    msg.add<uint32_t>(windowTextId);
    msg.addItem(item);
    if(canWrite)
    {
        msg.add<uint16_t>(maxLen);
        msg.addString(item->getText());
    }
    else
    {
        msg.add<uint16_t>(item->getText().size());
        msg.addString(item->getText());
    }

    const std::string& writer = item->getWriter();
    if(writer.size())
        msg.addString(writer);
    else
        msg.addString("");

    time_t writtenDate = item->getDate();
    if(writtenDate > 0)
        msg.addString(formatDate(writtenDate));
    else
        msg.addString("");

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendTextWindow(uint32_t windowTextId, uint32_t itemId, const std::string& text)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x96);
    msg.add<uint32_t>(windowTextId);
    msg.addItemId(itemId);

    msg.add<uint16_t>(text.size());
    msg.addString(text);

    msg.addString("");
    msg.addString("");
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendHouseWindow(uint32_t windowTextId, House*,
    uint32_t, const std::string& text)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0x97);
    msg.add<uint8_t>(0x00);
    msg.add<uint32_t>(windowTextId);
    msg.addString(text);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendOutfitWindow()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xC8);
    AddCreatureOutfit(msg, player, player->getDefaultOutfit(), true);

    std::list<Outfit> outfitList;
    for(OutfitMap::iterator it = player->outfits.begin(); it != player->outfits.end(); ++it)
    {
        if(player->canWearOutfit(it->first, it->second.addons))
            outfitList.push_back(it->second);
    }

    if(outfitList.size())
    {
        msg.add<uint8_t>((size_t)std::min((size_t)OUTFITS_MAX_NUMBER, outfitList.size()));
        std::list<Outfit>::iterator it = outfitList.begin();
        for(int32_t i = 0; it != outfitList.end() && i < OUTFITS_MAX_NUMBER; ++it, ++i)
        {
            msg.add<uint16_t>(it->lookType);
            msg.addString(it->name);
            if(player->hasCustomFlag(PlayerCustomFlag_CanWearAllAddons))
                msg.add<uint8_t>(0x03);
            else if(!g_config.getBool(ConfigManager::ADDONS_PREMIUM) || player->isPremium())
                msg.add<uint8_t>(it->addons);
            else
                msg.add<uint8_t>(0x00);
        }
    }
    else
    {
        msg.add<uint8_t>(1);
        msg.add<uint16_t>(player->getDefaultOutfit().lookType);
        msg.addString("Your outfit");
        msg.add<uint8_t>(player->getDefaultOutfit().lookAddons);
    }

    player->hasRequestedOutfit(true);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendQuests()
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xF0);
    msg.add<uint16_t>(Quests::getInstance()->getQuestCount(player));
    for(QuestList::const_iterator it = Quests::getInstance()->getFirstQuest(); it != Quests::getInstance()->getLastQuest(); ++it)
    {
        if(!(*it)->isStarted(player))
            continue;

        msg.add<uint16_t>((*it)->getId());
        msg.addString((*it)->getName());
        msg.add<uint8_t>((*it)->isCompleted(player));
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendQuestInfo(Quest* quest)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xF1);
    msg.add<uint16_t>(quest->getId());

    msg.add<uint8_t>(quest->getMissionCount(player));
    for(MissionList::const_iterator it = quest->getFirstMission(); it != quest->getLastMission(); ++it)
    {
        if(!(*it)->isStarted(player))
            continue;

        msg.addString((*it)->getName(player));
        msg.addString((*it)->getDescription(player));
    }

    writeToOutputBuffer(msg);
}

void ProtocolGame::sendVIPLogIn(uint32_t guid)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xD3);
    msg.add<uint32_t>(guid);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendVIPLogOut(uint32_t guid)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xD4);
    msg.add<uint32_t>(guid);
    writeToOutputBuffer(msg);
}

void ProtocolGame::sendVIP(uint32_t guid, const std::string& name, bool isOnline)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xD2);
    msg.add<uint32_t>(guid);
    msg.addString(name);
    msg.add<uint8_t>(isOnline ? 1 : 0);
    writeToOutputBuffer(msg);
}

void ProtocolGame::AddMapDescription(NetworkMessage& msg, const Position& pos)
{
    msg.add<uint8_t>(0x64);
    msg.addPosition(player->getPosition());
    GetMapDescription(pos.x - 8, pos.y - 6, pos.z, 18, 14, msg);
}

void ProtocolGame::AddTextMessage(NetworkMessage& msg, MessageClasses mclass, const std::string& message)
{
    msg.add<uint8_t>(0xB4);
    msg.add<uint8_t>(mclass);
    msg.addString(message);
}

void ProtocolGame::AddAnimatedText(NetworkMessage& msg, const Position& pos,
    uint8_t color, const std::string& text)
{
    msg.add<uint8_t>(0x84);
    msg.addPosition(pos);
    msg.add<uint8_t>(color);
    msg.addString(text);
}

void ProtocolGame::AddMagicEffect(NetworkMessage& msg,const Position& pos, uint8_t type)
{
    msg.add<uint8_t>(0x83);
    msg.addPosition(pos);
    msg.add<uint8_t>(type + 1);
}

void ProtocolGame::AddDistanceShoot(NetworkMessage& msg, const Position& from, const Position& to,
    uint8_t type)
{
    msg.add<uint8_t>(0x85);
    msg.addPosition(from);
    msg.addPosition(to);
    msg.add<uint8_t>(type + 1);
}

void ProtocolGame::AddCreature(NetworkMessage& msg, const Creature* creature, bool known, uint32_t remove)
{
    if(!known)
    {
        msg.add<uint16_t>(0x61);
        msg.add<uint32_t>(remove);
        msg.add<uint32_t>(creature->getID());
        msg.addString(creature->getHideName() ? "" : creature->getName());
    }
    else
    {
        msg.add<uint16_t>(0x62);
        msg.add<uint32_t>(creature->getID());
    }

    if(!creature->getHideHealth())
        msg.add<uint8_t>((int32_t)std::ceil(((float)creature->getHealth()) * 100 / std::max(creature->getMaxHealth(), (int32_t)1)));
    else
        msg.add<uint8_t>(0x00);

    msg.add<uint8_t>((uint8_t)creature->getDirection());
    AddCreatureOutfit(msg, creature, creature->getCurrentOutfit());

    LightInfo lightInfo;
    if(creature == player && player->hasCustomFlag(PlayerCustomFlag_HasFullLight))
    {
        lightInfo.level = 0xFF;
        lightInfo.color = 215;
    }
    else
        creature->getCreatureLight(lightInfo);

    msg.add<uint8_t>(lightInfo.level);
    msg.add<uint8_t>(lightInfo.color);

    msg.add<uint16_t>(creature->getStepSpeed());
    msg.add<uint8_t>(player->getSkullType(creature));
    msg.add<uint8_t>(player->getPartyShield(creature));
    if(!known)
        msg.add<uint8_t>(player->getGuildEmblem(creature));

    msg.add<uint8_t>(!player->canWalkthrough(creature));
}

void ProtocolGame::AddPlayerStats(NetworkMessage& msg)
{
    msg.add<uint8_t>(0xA0);
    msg.add<uint16_t>(player->getHealth());
    msg.add<uint16_t>(player->getPlayerInfo(PLAYERINFO_MAXHEALTH));
    msg.add<uint32_t>(uint32_t(player->getFreeCapacity() * 100));
    uint64_t experience = player->getExperience();
    if(experience > 0x7FFFFFFF) // client debugs after 2,147,483,647 exp
        msg.add<uint32_t>(0x7FFFFFFF);
    else
        msg.add<uint32_t>(experience);

    msg.add<uint16_t>(player->getPlayerInfo(PLAYERINFO_LEVEL));
    msg.add<uint8_t>(player->getPlayerInfo(PLAYERINFO_LEVELPERCENT));
    msg.add<uint16_t>(player->getPlayerInfo(PLAYERINFO_MANA));
    msg.add<uint16_t>(player->getPlayerInfo(PLAYERINFO_MAXMANA));
    msg.add<uint8_t>(player->getPlayerInfo(PLAYERINFO_MAGICLEVEL));
    msg.add<uint8_t>(player->getPlayerInfo(PLAYERINFO_MAGICLEVELPERCENT));
    msg.add<uint8_t>(player->getPlayerInfo(PLAYERINFO_SOUL));
    msg.add<uint16_t>(player->getStaminaMinutes());
}

void ProtocolGame::AddPlayerSkills(NetworkMessage& msg)
{
    msg.add<uint8_t>(0xA1);
    msg.add<uint8_t>(player->getSkill(SKILL_FIST, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_FIST, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_CLUB, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_CLUB, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_SWORD, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_SWORD, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_AXE, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_AXE, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_DIST, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_DIST, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_SHIELD, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_SHIELD, SKILL_PERCENT));
    msg.add<uint8_t>(player->getSkill(SKILL_FISH, SKILL_LEVEL));
    msg.add<uint8_t>(player->getSkill(SKILL_FISH, SKILL_PERCENT));
}

void ProtocolGame::AddCreatureSpeak(NetworkMessage& msg, const Creature* creature, SpeakClasses type,
    std::string text, uint16_t channelId, uint32_t time/*= 0*/, Position* pos/* = NULL*/)
{
    msg.add<uint8_t>(0xAA);
    if(creature)
    {
        const Player* speaker = creature->getPlayer();
        if(speaker)
        {
            msg.add<uint32_t>(++g_chat.statement);
            g_chat.statementMap[g_chat.statement] = text;
        }
        else
            msg.add<uint32_t>(0x00);

        if(creature->getSpeakType() != SPEAK_CLASS_NONE)
            type = creature->getSpeakType();

        switch(type)
        {
            case SPEAK_CHANNEL_RA:
                msg.addString("");
                break;
            case SPEAK_RVR_ANSWER:
                msg.addString("Gamemaster");
                break;
            default:
                msg.addString(!creature->getHideName() ? creature->getName() : "");
                break;
        }

        if(speaker && type != SPEAK_RVR_ANSWER && !speaker->isAccountManager()
            && !speaker->hasCustomFlag(PlayerCustomFlag_HideLevel)){
#ifdef __DARGHOS_PVP_SYSTEM__
		if(!speaker->isInBattleground())
                    msg.add<uint16_t>(speaker->getPlayerInfo(PLAYERINFO_LEVEL));
		else
            msg.add<uint16_t>(speaker->getBattlegroundRating());
#else
            msg.add<uint16_t>(speaker->getPlayerInfo(PLAYERINFO_LEVEL));
#endif
	}
        else
            msg.add<uint16_t>(0x00);

    }
    else
    {
        msg.add<uint32_t>(0x00);
        msg.addString("");
        msg.add<uint16_t>(0x00);
    }

    msg.add<uint8_t>(type);
    switch(type)
    {
        case SPEAK_SAY:
        case SPEAK_WHISPER:
        case SPEAK_YELL:
        case SPEAK_MONSTER_SAY:
        case SPEAK_MONSTER_YELL:
        case SPEAK_PRIVATE_NP:
        {
            if(pos)
                msg.addPosition(*pos);
            else if(creature)
                msg.addPosition(creature->getPosition());
            else
                msg.addPosition(Position(0,0,7));

            break;
        }

        case SPEAK_CHANNEL_Y:
        case SPEAK_CHANNEL_RN:
        case SPEAK_CHANNEL_RA:
        case SPEAK_CHANNEL_O:
        case SPEAK_CHANNEL_W:
            msg.add<uint16_t>(channelId);
            break;

        case SPEAK_RVR_CHANNEL:
        {
            msg.add<uint32_t>(uint32_t(OTSYS_TIME() / 1000 & 0xFFFFFFFF) - time);
            break;
        }

        default:
            break;
    }

    msg.addString(text);
}

void ProtocolGame::AddCreatureHealth(NetworkMessage& msg,const Creature* creature)
{
    msg.add<uint8_t>(0x8C);
    msg.add<uint32_t>(creature->getID());
    if(!creature->getHideHealth())
        msg.add<uint8_t>((int32_t)std::ceil(((float)creature->getHealth()) * 100 / std::max(creature->getMaxHealth(), (int32_t)1)));
    else
        msg.add<uint8_t>(0x00);
}

void ProtocolGame::AddCreatureOutfit(NetworkMessage& msg, const Creature* creature, const Outfit_t& outfit, bool outfitWindow/* = false*/)
{
    if(outfitWindow || !creature->getPlayer() || (!creature->isInvisible() && (!creature->isGhost()
        || !g_config.getBool(ConfigManager::GHOST_INVISIBLE_EFFECT))))
    {
        msg.add<uint16_t>(outfit.lookType);
        if(outfit.lookType)
        {
            msg.add<uint8_t>(outfit.lookHead);
            msg.add<uint8_t>(outfit.lookBody);
            msg.add<uint8_t>(outfit.lookLegs);
            msg.add<uint8_t>(outfit.lookFeet);
            msg.add<uint8_t>(outfit.lookAddons);
        }
        else if(outfit.lookTypeEx)
            msg.addItemId(outfit.lookTypeEx);
        else
            msg.add<uint16_t>(outfit.lookTypeEx);
    }
    else
        msg.add<uint32_t>(0x00);
}

void ProtocolGame::AddWorldLight(NetworkMessage& msg, const LightInfo& lightInfo)
{
    msg.add<uint8_t>(0x82);
    msg.add<uint8_t>(player->hasCustomFlag(PlayerCustomFlag_HasFullLight) ? 0xFF : lightInfo.level);
    msg.add<uint8_t>(lightInfo.color);
}

void ProtocolGame::AddCreatureLight(NetworkMessage& msg, const Creature* creature)
{
    msg.add<uint8_t>(0x8D);
    msg.add<uint32_t>(creature->getID());

    LightInfo lightInfo;
    if(creature == player && player->hasCustomFlag(PlayerCustomFlag_HasFullLight))
    {
        lightInfo.level = 0xFF;
        lightInfo.color = 215;
    }
    else
        creature->getCreatureLight(lightInfo);

    msg.add<uint8_t>(lightInfo.level);
    msg.add<uint8_t>(lightInfo.color);
}

//tile
void ProtocolGame::AddTileItem(NetworkMessage& msg, const Position& pos, uint32_t stackpos, const Item* item)
{
    if(stackpos >= 10)
        return;

    msg.add<uint8_t>(0x6A);
    msg.addPosition(pos);
    msg.add<uint8_t>(stackpos);
    msg.addItem(item);
}

void ProtocolGame::AddTileCreature(NetworkMessage& msg, const Position& pos, uint32_t stackpos, const Creature* creature)
{
    if(stackpos >= 10)
        return;

    msg.add<uint8_t>(0x6A);
    msg.addPosition(pos);
    msg.add<uint8_t>(stackpos);

    bool known;
    uint32_t removedKnown;
    checkCreatureAsKnown(creature->getID(), known, removedKnown);

    AddCreature(msg, creature, known, removedKnown);
}

void ProtocolGame::UpdateTileItem(NetworkMessage& msg, const Position& pos, uint32_t stackpos, const Item* item)
{
    if(stackpos >= 10)
        return;

    msg.add<uint8_t>(0x6B);
    msg.addPosition(pos);
    msg.add<uint8_t>(stackpos);
    msg.addItem(item);
}

void ProtocolGame::RemoveTileItem(NetworkMessage& msg, const Position& pos, uint32_t stackpos)
{
    if(stackpos >= 10)
        return;

    msg.add<uint8_t>(0x6C);
    msg.addPosition(pos);
    msg.add<uint8_t>(stackpos);
}

void ProtocolGame::MoveUpCreature(NetworkMessage& msg, const Creature* creature,
    const Position& newPos, const Position& oldPos, uint32_t)
{
    if(creature != player)
        return;

    msg.add<uint8_t>(0xBE); //floor change up
    if(newPos.z == 7) //going to surface
    {
        int32_t skip = -1;
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 5, 18, 14, 3, skip); //(floor 7 and 6 already set)
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 4, 18, 14, 4, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 3, 18, 14, 5, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 2, 18, 14, 6, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 1, 18, 14, 7, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, 0, 18, 14, 8, skip);
        if(skip >= 0)
        {
            msg.add<uint8_t>(skip);
            msg.add<uint8_t>(0xFF);
        }
    }
    else if(newPos.z > 7) //underground, going one floor up (still underground)
    {
        int32_t skip = -1;
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, oldPos.z - 3, 18, 14, 3, skip);
        if(skip >= 0)
        {
            msg.add<uint8_t>(skip);
            msg.add<uint8_t>(0xFF);
        }
    }

    //moving up a floor up makes us out of sync
    //west
    msg.add<uint8_t>(0x68);
    GetMapDescription(oldPos.x - 8, oldPos.y + 1 - 6, newPos.z, 1, 14, msg);

    //north
    msg.add<uint8_t>(0x65);
    GetMapDescription(oldPos.x - 8, oldPos.y - 6, newPos.z, 18, 1, msg);
}

void ProtocolGame::MoveDownCreature(NetworkMessage& msg, const Creature* creature,
    const Position& newPos, const Position& oldPos, uint32_t)
{
    if(creature != player)
        return;

    msg.add<uint8_t>(0xBF); //floor change down
    if(newPos.z == 8) //going from surface to underground
    {
        int32_t skip = -1;
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, newPos.z, 18, 14, -1, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, newPos.z + 1, 18, 14, -2, skip);
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, newPos.z + 2, 18, 14, -3, skip);
        if(skip >= 0)
        {
            msg.add<uint8_t>(skip);
            msg.add<uint8_t>(0xFF);
        }
    }
    else if(newPos.z > oldPos.z && newPos.z > 8 && newPos.z < 14) //going further down
    {
        int32_t skip = -1;
        GetFloorDescription(msg, oldPos.x - 8, oldPos.y - 6, newPos.z + 2, 18, 14, -3, skip);
        if(skip >= 0)
        {
            msg.add<uint8_t>(skip);
            msg.add<uint8_t>(0xFF);
        }
    }

    //moving down a floor makes us out of sync
    //east
    msg.add<uint8_t>(0x66);
    GetMapDescription(oldPos.x + 9, oldPos.y - 1 - 6, newPos.z, 1, 14, msg);

    //south
    msg.add<uint8_t>(0x67);
    GetMapDescription(oldPos.x - 8, oldPos.y + 7, newPos.z, 18, 1, msg);
}

//inventory
void ProtocolGame::AddInventoryItem(NetworkMessage& msg, slots_t slot, const Item* item)
{
    if(item)
    {
        msg.add<uint8_t>(0x78);
        msg.add<uint8_t>(slot);
        msg.addItem(item);
    }
    else
        RemoveInventoryItem(msg, slot);
}

void ProtocolGame::RemoveInventoryItem(NetworkMessage& msg, slots_t slot)
{
    msg.add<uint8_t>(0x79);
    msg.add<uint8_t>(slot);
}

void ProtocolGame::UpdateInventoryItem(NetworkMessage& msg, slots_t slot, const Item* item)
{
    AddInventoryItem(msg, slot, item);
}

//containers
void ProtocolGame::AddContainerItem(NetworkMessage& msg, uint8_t cid, const Item* item)
{
    msg.add<uint8_t>(0x70);
    msg.add<uint8_t>(cid);
    msg.addItem(item);
}

void ProtocolGame::UpdateContainerItem(NetworkMessage& msg, uint8_t cid, uint8_t slot, const Item* item)
{
    msg.add<uint8_t>(0x71);
    msg.add<uint8_t>(cid);
    msg.add<uint8_t>(slot);
    msg.addItem(item);
}

void ProtocolGame::RemoveContainerItem(NetworkMessage& msg, uint8_t cid, uint8_t slot)
{
    msg.add<uint8_t>(0x72);
    msg.add<uint8_t>(cid);
    msg.add<uint8_t>(slot);
}

void ProtocolGame::sendChannelMessage(std::string author, std::string text, SpeakClasses type, uint8_t channel)
{
    NetworkMessage msg;
    msg.add<uint8_t>(0xAA);
    msg.add<uint32_t>(0x00);
    msg.addString(author);
    msg.add<uint16_t>(0x00);
    msg.add<uint8_t>(type);
#ifdef __DARGHOS_CUSTOM__
    switch(type)
    {
        case SPEAK_PRIVATE_NP:
        {
            msg.addPosition(player->getPosition());
            break;
        }

        default:
        {
            msg.add<uint16_t>(channel);
            break;
        }
    }
#else
    msg.add<uint16_t>(channel);
#endif
    msg.addString(text);

    writeToOutputBuffer(msg);
}

void ProtocolGame::AddShopItem(NetworkMessage& msg, const ShopInfo& item)
{
    const ItemType& it = Item::items[item.itemId];
    msg.add<uint16_t>(it.clientId);
    if(it.isSplash() || it.isFluidContainer())
        msg.add<uint8_t>(fluidMap[item.subType % 8]);
    else if(it.stackable || it.charges)
        msg.add<uint8_t>(item.subType);
    else
        msg.add<uint8_t>(0x01);

    msg.addString(item.itemName);
    msg.add<uint32_t>(uint32_t(it.weight * 100));
    msg.add<uint32_t>(item.buyPrice);
    msg.add<uint32_t>(item.sellPrice);
}
