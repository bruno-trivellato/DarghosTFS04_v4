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
#include <iomanip>

#include "protocollogin.h"
#include "tools.h"

#include "iologindata.h"
#include "ioban.h"

#include "outputmessage.h"
#include "connection.h"

#include "rsa.h"

#include "configmanager.h"
#include "game.h"

extern ConfigManager g_config;
extern Game g_game;

extern std::list<std::pair<uint32_t, uint32_t> > serverIps;

#ifdef __ENABLE_SERVER_DIAGNOSTIC__
uint32_t ProtocolLogin::protocolLoginCount = 0;
#endif

void ProtocolLogin::deleteProtocolTask()
{
#ifdef __DEBUG_NET_DETAIL__
	std::clog << "Deleting ProtocolLogin" << std::endl;
#endif
	Protocol::deleteProtocolTask();
}

void ProtocolLogin::disconnectClient(uint8_t error, const char* message)
{
	OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false);
	if(output)
	{
        output->addByte(error);
        output->addString(message);
		OutputMessagePool::getInstance()->send(output);
	}

	getConnection()->close();
}

bool ProtocolLogin::parseFirstPacket(NetworkMessage& msg)
{
    if(g_game.getGameState() == GAMESTATE_SHUTDOWN)
	{
		getConnection()->close();
		return false;
	}

	uint32_t clientIp = getConnection()->getIP();
    /*uint16_t operatingSystem = msg.get<uint16_t>();*/msg.skipBytes(2);
	uint16_t version = msg.get<uint16_t>();

    msg.skipBytes(12);
	if(!RSA_decrypt(msg))
	{
		getConnection()->close();
		return false;
	}

	uint32_t key[4] = {msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>()};
	enableXTEAEncryption();
	setXTEAKey(key);

	std::string name = msg.getString(), password = msg.getString();
	if(name.empty())
	{
		if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER))
		{
			disconnectClient(0x0A, "Invalid account name.");
			return false;
		}

		name = "1";
		password = "1";
	}

	if(version < CLIENT_VERSION_MIN || version > CLIENT_VERSION_MAX)
	{
		disconnectClient(0x0A, CLIENT_VERSION_STRING);
		return false;
	}

	if(g_game.getGameState() < GAMESTATE_NORMAL)
	{
		disconnectClient(0x0A, "Server is just starting up, please wait.");
		return false;
	}

	if(g_game.getGameState() == GAMESTATE_MAINTAIN)
	{
		disconnectClient(0x0A, "Server is under maintenance, please re-connect in a while.");
		return false;
	}

	if(IOBan::getInstance()->isIpBanished(clientIp))
	{
		disconnectClient(0x0A, "Your IP is banished!");
		return false;
	}

	uint32_t id = 1;
	if(!IOLoginData::getInstance()->getAccountId(name, id))
	{
		disconnectClient(0x0A, "Invalid account name.");
		return false;
	}

	Account account = IOLoginData::getInstance()->loadAccount(id);
	if(!encryptTest(account.salt + password, account.password))
	{
		disconnectClient(0x0A, "Invalid password.");
		return false;
	}

	Ban ban;
	ban.value = account.number;

	ban.type = BAN_ACCOUNT;
	if(IOBan::getInstance()->getData(ban) && !IOLoginData::getInstance()->hasFlag(account.number, PlayerFlag_CannotBeBanned))
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

		disconnectClient(0x0A, ss.str().c_str());
		return false;
	}

	// remove premium days
	IOLoginData::getInstance()->removePremium(account);
	if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER) && !account.charList.size())
	{
		disconnectClient(0x0A, std::string("This account does not contain any character yet.\nCreate a new character on the "
			+ g_config.getString(ConfigManager::SERVER_NAME) + " website at " + g_config.getString(ConfigManager::URL) + ".").c_str());
		return false;
	}

	if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
	{
        output->addByte(0x14);

        std::ostringstream ss;
        ss << IOLoginData::getInstance()->getMotdId() << "\n" << g_config.getString(ConfigManager::MOTD);
        output->addString(ss.str());

        //Add char list
        output->addByte(0x64);
		#ifndef __DARGHOS_PROXY__
        output->addByte((uint8_t)account.charList.size());
        #else
        output->addByte((uint8_t)account.charList.size() * 2);
        #endif

		for(Characters::iterator it = account.charList.begin(); it != account.charList.end(); it++)
		{
			#ifndef __LOGIN_SERVER__
            output->addString((*it));

			if(g_config.getBool(ConfigManager::ON_OR_OFF_CHARLIST))
			{
				if(g_game.getPlayerByName((*it)))
                    output->addString("Online");
				else
                    output->addString("Offline");
			}
			else
                output->addString(g_config.getString(ConfigManager::SERVER_NAME));

            output->add<uint32_t>(inet_addr(g_config.getString(ConfigManager::IP).c_str()));
            output->add<uint16_t>(g_config.getNumber(ConfigManager::GAME_PORT));
			
			#ifdef __DARGHOS_PROXY__
            output->addString((*it));
            output->addString("Proxy 1 on " + g_config.getString(ConfigManager::SERVER_NAME));
            output->add<uint32_t>(inet_addr("174.37.227.173"));
            output->add<uint16_t>(8686);
			#endif
			
			#else
			if(version < it->second->getVersionMin() || version > it->second->getVersionMax())
				continue;

            output->addString(it->first);
            output->addString(it->second->getName());
            output->add<uint32_t>(it->second->getAddress());
            output->add<uint16_t>(it->second->getPort());
			#endif
		}

		//Add premium days
		if(g_config.getBool(ConfigManager::FREE_PREMIUM))
            output->add<uint16_t>(65535); //client displays free premium
		else        
            output->add<uint16_t>(account.premiumDays);
			

		OutputMessagePool::getInstance()->send(output);
	}

	getConnection()->close();
	return true;
}
