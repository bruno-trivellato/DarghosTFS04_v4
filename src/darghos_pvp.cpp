#include "otpch.h"
#ifdef __DARGHOS_PVP_SYSTEM__

#include "darghos_pvp.h"
#include "luascript.h"
#include "game.h"
#include "creature.h"
#include "globalevent.h"

#define MIN_BATTLEGROUND_TEAM_SIZE 6
#define BATTLEGROUND_WIN_POINTS 50
#define BATTLEGROUND_END 1000 * 60 * 15

extern Game g_game;
extern GlobalEvents* g_globalEvents;

Battleground::Battleground()
{
	open = false;
	type = PVP_SIMPLE_BATTLEGROUND;
}

Battleground::~Battleground()
{

}

void Battleground::onClose()
{
	for(BgTeamsMap::iterator it_teams = teamsMap.begin(); it_teams != teamsMap.end(); it_teams++)
	{
		for(PlayersMap::iterator it_players = it_teams->second.players.begin(); it_players != it_teams->second.players.end(); it_players++)
		{
			Player* player = g_game.getPlayerByID(it_players->first);
			if(!player)
				continue;

			kickPlayer(player, true);
		}
	}

	teamsMap[BATTLEGROUND_TEAM_ONE].points = 0;
	teamsMap[BATTLEGROUND_TEAM_TWO].points = 0;

	teamsMap[BATTLEGROUND_TEAM_ONE].levelSum = 0;
	teamsMap[BATTLEGROUND_TEAM_TWO].levelSum = 0;

	clearStatistics();
	status = BUILDING_TEAMS;
}

void Battleground::onInit()
{
	teamSize = MIN_BATTLEGROUND_TEAM_SIZE;
	winPoints = BATTLEGROUND_WIN_POINTS;
	duration = BATTLEGROUND_END;
    lastTeamScore = BATTLEGROUND_TEAM_NONE;

    Bg_Team_t team_one;

    team_one.flag_debuff_stacks = 0;
    team_one.flag_debuff_ticks = 0;

	team_one.points = 0;
	team_one.levelSum = 0;

    team_one.look.head = 82;
    team_one.look.body = 114;
    team_one.look.legs = 114;
    team_one.look.feet = 91;

	Thing* thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_1_SPAWN);
	if(thing)
		team_one.spawn_pos = thing->getPosition();

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_1_ENTRANCE);
	if(thing)
		team_one.entrance_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_ONE, team_one));

    Bg_Team_t team_two;

    team_two.flag_debuff_stacks = 0;
    team_two.flag_debuff_ticks = 0;
	team_two.points = 0;
	team_two.levelSum = 0;

    team_two.look.head = 77;
    team_two.look.body = 94;
    team_two.look.legs = 94;
    team_two.look.feet = 79;

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_2_SPAWN);
	if(thing)
		team_two.spawn_pos = thing->getPosition();

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_2_ENTRANCE);
	if(thing)
		team_two.entrance_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_TWO, team_two));

    open = true;
	status = BUILDING_TEAMS;
}

void Battleground::removeWaitlistPlayer(Player* player)
{
	Bg_Waitlist_t::iterator it = std::find(waitlist.begin(), waitlist.end(), player);
	if(it != waitlist.end())
		waitlist.erase(it);
}

void Battleground::removeIdleWaitlistPlayer(uint32_t player_id)
{
    Player* player = g_game.getPlayerByID(player_id);
    if(!player)
        return;

    if(playerIsInWaitlist(player)){
        player->sendPvpChannelMessage("Nenhuma partida foi iniciada nas ultimas 2 horas. Você foi removido da fila. Digite novamente \"!bg entrar\" se você deseja voltar a fila!", SPEAK_CHANNEL_O);
        removeWaitlistPlayer(player);
    }
}

bool Battleground::playerIsInWaitlist(Player* player)
{
	for(Bg_Waitlist_t::iterator it = waitlist.begin(); it != waitlist.end(); it++)
	{
        Player* waiting = (*it);
        if(waiting == player || waiting->getIP() == player->getIP())
		{
			return true;
		}
	}

	return false;
}

Bg_PlayerInfo_t* Battleground::findPlayerInfo(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		PlayersMap::iterator pit = it->second.players.find(player->getID());
		if(pit != it->second.players.end())
			return &pit->second;
	}

	return NULL;
}

Bg_Teams_t Battleground::findTeamIdByPlayer(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		PlayersMap::iterator pit = it->second.players.find(player->getID());
		if(pit != it->second.players.end())
			return it->first;
	}

	return BATTLEGROUND_TEAM_NONE;
}

Bg_Team_t* Battleground::findPlayerTeam(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		if(it->first == player->getBattlegroundTeam())
			return &it->second;
	}

	return NULL;
}

void Battleground::finish()
{
	if(teamsMap[BATTLEGROUND_TEAM_ONE].points > teamsMap[BATTLEGROUND_TEAM_TWO].points)
		finish(BATTLEGROUND_TEAM_ONE);
	else if(teamsMap[BATTLEGROUND_TEAM_ONE].points < teamsMap[BATTLEGROUND_TEAM_TWO].points)
		finish(BATTLEGROUND_TEAM_TWO);
    else{
        if(teamsMap[BATTLEGROUND_TEAM_ONE].points == 0)
            finish(BATTLEGROUND_TEAM_NONE); //empate? somente em caso de 0x0
        else{
            //empates em 1x1 e 2x2 será considerado vencedor o time que capturou a ultima bandeira
            finish(lastTeamScore);
        }
    }
}

void Battleground::finish(Bg_Teams_t teamWinner)
{
	status = FINISHED;
    g_scheduler.stopEvent(endEvent);

	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		for(PlayersMap::iterator it_players = it->second.players.begin(); it_players != it->second.players.end(); it_players++)
		{
			bool isWinner = false;

			Player* player = g_game.getPlayerByID(it_players->first);
			if(!player)
				continue;

			if(player->getBattlegroundTeam() == teamWinner)
				isWinner  = true;

			g_game.playerCancelAttackAndFollow(it_players->first);
			player->setPause(true);
			player->sendPvpChannelMessage("Você será levado ao lugar em que estava em 5 segundos...");

            g_scheduler.addEvent(createSchedulerTask(1000 * 5,
				boost::bind(&Battleground::kickPlayer, this, player, true)));

			time_t timeInBg = time(NULL) - it_players->second.join_in;
			time_t bgDuration = time(NULL) - lastInit;

			CreatureEventList bgFragEvents = player->getCreatureEvents(CREATURE_EVENT_BG_END);
			for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
			{
				(*it)->executeBgEnd(player, isWinner, timeInBg, bgDuration, lastInit);
			}
		}
	}

	g_globalEvents->execute(GLOBALEVENT_BATTLEGROUND_END);

	BattlegroundFinishBy finishBy = (teamsMap[teamWinner].points == winPoints) ? BattlegroundFinishByPoints : BattlegroundFinishByTime;
	storeFinish(time(NULL), finishBy, teamsMap[BATTLEGROUND_TEAM_ONE].points, teamsMap[BATTLEGROUND_TEAM_TWO].points);

	clearStatistics();

	teamsMap[BATTLEGROUND_TEAM_ONE].points = 0;
	teamsMap[BATTLEGROUND_TEAM_TWO].points = 0;

	teamsMap[BATTLEGROUND_TEAM_ONE].levelSum = 0;
	teamsMap[BATTLEGROUND_TEAM_TWO].levelSum = 0;

	status = BUILDING_TEAMS;
	buildTeams();
}

bool Battleground::buildTeams()
{
	if(waitlist.size() < teamSize * 2)
		return false;

	if(status == STARTED || status == PREPARING)
		return false;

    //daqui em diante nada pode mudar, a BG irá começar...
    status = PREPARING;

	waitlist.sort(Battleground::orderWaitlistByLevel);

	Bg_Teams_t team;

	uint16_t _rand = random_range(1, 2);
	for(uint16_t i = 1; i <= teamSize * 2; i++)
	{
	    //iremos sempre apagar o primeiro na lista...
	    Bg_Waitlist_t::iterator it = waitlist.begin();

		if(_rand == 1)
			team = ((i & 1) == 1) ? BATTLEGROUND_TEAM_ONE : BATTLEGROUND_TEAM_TWO;
		else
			team = ((i & 1) == 1) ? BATTLEGROUND_TEAM_TWO : BATTLEGROUND_TEAM_ONE;

		putInTeam((*it), team);
        g_scheduler.addEvent(createSchedulerTask(1000 * 4,
			boost::bind(&Battleground::callPlayer, this, (*it)->getID())));

        waitlist.erase(it);
	}

	g_globalEvents->execute(GLOBALEVENT_BATTLEGROUND_PREPARE);

    g_scheduler.addEvent(createSchedulerTask((1000 * 60 * 2) + (1000 * 5),
		boost::bind(&Battleground::start, this)));
	return true;
}

void Battleground::callPlayer(uint32_t player_id)
{
    Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return;

    player->sendPvpChannelMessage("A battleground está pronta para iniciar! Você tem 2 minutos para digitar o comando \"!bg entrar\" para ser enviado a batalha! Boa sorte bravo guerreiro!", SPEAK_CHANNEL_O);
	player->sendFYIBox("A battleground está pronta para iniciar!\n Você tem 2 minutos para digitar o comando \n\"!bg entrar\" para ser enviado a batalha!\n\n Boa sorte bravo guerreiro!");
}

void Battleground::start()
{
    uint32_t notJoin = 0;

	lastInit = time(NULL);
	storeNew();

	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
        for(PlayersMap::iterator it_players = it->second.players.begin(); it_players != it->second.players.end(); it_players++)
		{
			Player* player = g_game.getPlayerByID(it_players->first);
			if(!it_players->second.areInside)
			{
				if(player)
					player->sendPvpChannelMessage("Você não apareceu na battleground no tempo esperado... Você ainda pode participar da batalha digitando \"!bg entrar\" novamente.");

				it->second.players.erase(it_players->first);
				notJoin++;
				continue;
			}

			it_players->second.join_in = time(NULL);
		}
	}

	status = STARTED;
	GlobalEventMap events = g_globalEvents->getEventMap(GLOBALEVENT_BATTLEGROUND_START);
	for(GlobalEventMap::iterator it = events.begin(); it != events.end(); ++it)
		it->second->executeOnBattlegroundStart(notJoin);

    endEvent = g_scheduler.addEvent(createSchedulerTask(duration,
		boost::bind(&Battleground::finish, this)));
}

Bg_Teams_t Battleground::sortTeam()
{
	if(teamsMap[BATTLEGROUND_TEAM_ONE].players.size() <  teamsMap[BATTLEGROUND_TEAM_TWO].players.size())
		return BATTLEGROUND_TEAM_ONE;
	else if(teamsMap[BATTLEGROUND_TEAM_TWO].players.size() < teamsMap[BATTLEGROUND_TEAM_ONE].players.size())
		return BATTLEGROUND_TEAM_TWO;
	else
		return (Bg_Teams_t)random_range((uint32_t)BATTLEGROUND_TEAM_ONE, (uint32_t)BATTLEGROUND_TEAM_TWO);
}

void Battleground::putInTeam(Player* player, Bg_Teams_t team_id)
{
	Bg_Team_t* team = &teamsMap[team_id];

	Bg_PlayerInfo_t playerInfo;
	playerInfo.areInside = false;

	team->players.insert(std::make_pair(player->getID(), playerInfo));
}

void Battleground::putInside(Player* player)
{
	Bg_Teams_t team_id = findTeamIdByPlayer(player);

	if(!team_id || team_id == BATTLEGROUND_TEAM_NONE)
		return;

	Bg_PlayerInfo_t* playerInfo = findPlayerInfo(player);

	if(!playerInfo)
		return;

	Bg_Team_t* team = &teamsMap[team_id];
	team->levelSum += player->getLevel();

	player->setBattlegroundTeam(team_id);

	Outfit_t player_outfit = player->getCreature()->getCurrentOutfit();
	playerInfo->default_outfit = player_outfit;

	player_outfit.lookHead = team->look.head;
	player_outfit.lookBody = team->look.body;
	player_outfit.lookLegs = team->look.legs;
	player_outfit.lookFeet = team->look.feet;

	player->changeOutfit(player_outfit, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), player_outfit);

	playerInfo->masterPosition = player->getMasterPosition();
	player->setMasterPosition(team->spawn_pos);

	const Position& oldPos = player->getPosition();
	playerInfo->oldPosition = oldPos;
	playerInfo->join_in = time(NULL);

	if(playerIsInWaitlist(player))
		removeWaitlistPlayer(player);

	g_game.internalTeleport(player, team->entrance_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	Bg_Statistic_t* statistic = new Bg_Statistic_t;
	statistic->player_id = player->getID();
	playerInfo->statistics = statistic;
	statisticsList.push_back(playerInfo->statistics);

	player->onEnterBattleground();

	playerInfo->areInside = true;
}

BattlegrondRetValue Battleground::onPlayerJoin(Player* player)
{
    if(!isOpen()) return BATTLEGROUND_CLOSED;

	if(player->isBattlegroundDeserter())
		return BATTLEGROUND_CAN_NOT_JOIN;

	if(status == BUILDING_TEAMS)
	{
		if(playerIsInWaitlist(player))
			return BATTLEGROUND_ALREADY_IN_WAITLIST;

		waitlist.push_back(player);
		buildTeams();

        g_scheduler.addEvent(createSchedulerTask(1000 * 60 * 60 * 2,
            boost::bind(&Battleground::removeIdleWaitlistPlayer, this, player->getID())));

		return BATTLEGROUND_PUT_IN_WAITLIST;
	}
	else if(status == STARTED || status == PREPARING)
	{
		if(!player->isInBattleground())
		{
			Bg_Teams_t team_id = findTeamIdByPlayer(player);

			if(!team_id)
			{
				//se a bg já estiver cheia ele é colocado na fila para a proxima bg
				if(teamsMap[BATTLEGROUND_TEAM_ONE].players.size() >= teamSize && teamsMap[BATTLEGROUND_TEAM_TWO].players.size() >= teamSize)
				{
					if(playerIsInWaitlist(player))
						return BATTLEGROUND_ALREADY_IN_WAITLIST;

					waitlist.push_back(player);
					return BATTLEGROUND_PUT_IN_WAITLIST;
				}

				//senão, (alguem saiu) ele é colocado na bg
				if(player->hasCondition(CONDITION_INFIGHT))
				{
					return BATTLEGROUND_INFIGHT;
				}

				team_id = sortTeam();

				putInTeam(player, team_id);
				putInside(player);
				return BATTLEGROUND_PUT_DIRECTLY;
			}
			//o jogador estava na fila, portanto já esta em um time, somente necessario o teleportar para dentro...
			else
			{
				if(player->hasCondition(CONDITION_INFIGHT))
				{
					return BATTLEGROUND_INFIGHT;
				}

				putInside(player);
				return BATTLEGROUND_PUT_INSIDE;
			}
		}
		else
		{
            player->sendPvpChannelMessage("Você já está dentro da battleground!");
		}
	}

    return BATTLEGROUND_NO_ERROR;
}

BattlegrondRetValue Battleground::kickPlayer(Player* player, bool force)
{
	if(!player || player->isRemoved())
	{
		return BATTLEGROUND_NO_ERROR;
	}

	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_Team_t* team = &teamsMap[team_id];
	PlayersMap::iterator it = team->players.find(player->getID());

	if(it != team->players.end())
	{
		Bg_PlayerInfo_t playerInfo = it->second;

		if(status == STARTED && !force)
		{
			std::stringstream ss;
			ss << (time(NULL) + BATTLEGROUND_DESERTOR_TIME);
			player->setStorage(DARGHOS_STORAGE_BATTLEGROUND_DESERTER_UNTIL, ss.str());
		}

		player->setBattlegroundTeam(BATTLEGROUND_TEAM_NONE);

		Outfit_t outfit_default = playerInfo.default_outfit;

		player->changeOutfit(outfit_default, false);
		g_game.internalCreatureChangeOutfit(player->getCreature(), outfit_default);

		player->setMasterPosition(playerInfo.masterPosition);

		Position pos = g_game.getClosestFreeTile(player, playerInfo.oldPosition, false, false, false);

		if(pos.x == 0 && pos.y == 0 && pos.z == 0)
			pos = player->getMasterPosition();

		if(g_game.internalTeleport(player, pos, true) != RET_NOERROR)
			std::clog << "[Battleground Warning] Can not teleport player " << player->getName() << " out of the battleground." << std::endl;

		g_game.addMagicEffect(playerInfo.oldPosition, MAGIC_EFFECT_TELEPORT);

		statisticsList.remove(playerInfo.statistics);
		delete playerInfo.statistics;

		team->players.erase(player->getID());
		team->levelSum = std::max((int32_t)(team->levelSum - player->getLevel()), 0);
	}
	else
	{
		g_game.internalTeleport(player, player->getMasterPosition(), true);
		g_game.addMagicEffect(player->getMasterPosition(), MAGIC_EFFECT_TELEPORT);

		std::clog << "[Possible Crash] Player " << player->getName() << " leaving from battleground that are not inside." << std::endl;
	}

	if(player->isPause())
		player->setPause(false);

	player->onLeaveBattleground();

	CreatureEventList bgFragEvents = player->getCreatureEvents(CREATURE_EVENT_BG_LEAVE);
	for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
	{
		(*it)->executeBgLeave(player);
	}

	return BATTLEGROUND_NO_ERROR;
}

void Battleground::onPlayerDeath(Player* player, DeathList deathList)
{
	if(status != STARTED)
		return;

	Bg_Teams_t team_id = player->getBattlegroundTeam();

	Bg_DeathEntry_t* deathEntry = new Bg_DeathEntry_t;
	deathEntry->date = time(NULL);

	bool success = true;

	Player* lastDmg = NULL;
	Player* tmp = NULL;

    std::list<uint32_t> tempList;

	for(DeathList::iterator it = deathList.begin(); it != deathList.end(); ++it)
	{
        if(it->isNameKill())
            continue;

		if(it->getKillerCreature()->getPlayer())
			tmp = it->getKillerCreature()->getPlayer();
		else if(it->getKillerCreature()->getPlayerMaster())
			tmp = it->getKillerCreature()->getMaster()->getPlayer();

        if(tmp)
        {
            if(tmp->getBattlegroundTeam() == team_id)
                continue;

            Bg_PlayerInfo_t* playerInfo = findPlayerInfo(tmp);

            if(!playerInfo || tmp->getBattlegroundTeam() == BATTLEGROUND_TEAM_NONE)
            {
                std::clog << "Player " << tmp->getName() << " killing player " << player->getName() << " in Battleground but are not in any team?" << std::endl;
                continue;
            }

            if(it == deathList.begin())
            {
                if(!isValidFrag(playerInfo, findPlayerInfo(player)))
                {
                    success = false;
                    break;
                }

                deathEntry->lasthit = tmp->getID();
                lastDmg = tmp;

                incrementPlayerKill(playerInfo, deathEntry, true);
            }
            else
            {
                if(!lastDmg)
                    lastDmg = tmp;

                incrementPlayerKill(playerInfo, deathEntry);
                deathEntry->assists.push_back(tmp->getID());

                tempList.push_back(tmp->getID());
            }
        }
	}

	if(lastDmg)
	{
		//Bg_Team_t* team = findPlayerTeam(lastDmg);

		Bg_PlayerInfo_t* playerInfo = findPlayerInfo(player);

		incrementPlayerDeaths(playerInfo, deathEntry);

		CreatureEventList bgDeathEvents = lastDmg->getCreatureEvents(CREATURE_EVENT_BG_DEATH);
		for(CreatureEventList::iterator it = bgDeathEvents.begin(); it != bgDeathEvents.end(); ++it)
		{
			(*it)->executeBgDeath(player, lastDmg, tempList);
		}

		/*if(team->points >= winPoints && status == STARTED)
		{
			status = FINISHED;

            g_scheduler.addEvent(createSchedulerTask(1000,
				boost::bind(&Battleground::finish, this, lastDmg->getBattlegroundTeam())));
		}*/
	}

	if(!success || !lastDmg)
	{
		delete deathEntry;
	}

	player->lastBattlegroundDeath = OTSYS_TIME();
}

bool Battleground::isValidFrag(Bg_PlayerInfo_t* killer_info, Bg_PlayerInfo_t* target_info)
{
	time_t timeLimit = time(NULL) - LIMIT_TARGET_FRAGS_INTERVAL;
	DeathsEntryList list = target_info->statistics->deaths;

	DeathsEntryList temp_list;

	/* vamos pegar as mortes recentes */
	for(DeathsEntryList::const_iterator it = list.begin(); it != list.end(); it++)
	{
		Bg_DeathEntry_t* deathEntry = (*it);
		if(deathEntry->date > timeLimit)
		{
			temp_list.push_back(deathEntry);
		}
	}

	/* se morreu pouco, entao nao há necessidade de prosseguir*/
	if(temp_list.size() < 3)
		return true;

	/* vamos pegar as assists recentes*/
	list = target_info->statistics->assists;
	for(DeathsEntryList::const_iterator it = list.begin(); it != list.end(); it++)
	{
		Bg_DeathEntry_t* deathEntry = (*it);
		if(deathEntry->date > timeLimit)
		{
			temp_list.push_back(deathEntry);
		}
	}

	/* vamos pegar as kills recentes*/
	list = target_info->statistics->kills;
	for(DeathsEntryList::const_iterator it = list.begin(); it != list.end(); it++)
	{
		Bg_DeathEntry_t* deathEntry = (*it);
		if(deathEntry->date > timeLimit)
		{
			temp_list.push_back(deathEntry);
		}
	}

	temp_list.sort(Battleground::orderDeathListByDate);

	/* Finalmente vamos tentar descobrir se o jogador está dando 'free frag'...
		Se as 3 ultimas coisas que o jogador fez foi morrer então esta frag
		será negada, caso exista algum assist ou kill, então é validado
	*/

	uint8_t i = 1;
	for(DeathsEntryList::const_iterator it = temp_list.begin(); it != temp_list.end(); it++, i++)
	{
		Bg_DeathEntry_t* deathEntry = (*it);
		if(deathEntry->lasthit == target_info->statistics->player_id)
		{
			/* Se o jogador matou alguem em suas ultimas 3 ações entao a frag é valida*/
			return true;
		}

		for(AssistsList::iterator ait = deathEntry->assists.begin(); ait != deathEntry->assists.end(); ait++)
		{
			if((*ait) == target_info->statistics->player_id)
			{
				/* Se o jogador também causou uma assistencia, entao a frag é valida*/
				return true;
			}
		}

		if(i == 3)
		{
			/* Chegamo na 3a ação e não foi encontrado nada além de mortes, então paramos por aqui... a frag não é validada */
			return false;
		}
	}

	/*
	Haviam menos de 3 ações, provavelmente inicio de bg ou algo assim... então validaremos a frag mesmo sem kills/assists.
	hipoteticamente	este ponto do codigo nunca será acessado, mas vamos previnir ne...
	*/
	return true;
}

void Battleground::incrementPlayerKill(Bg_PlayerInfo_t* playerInfo, Bg_DeathEntry_t* entry, bool lasthit /* = false*/)
{
	playerInfo->statistics->assists.push_back(entry);

	if(lasthit)
		playerInfo->statistics->kills.push_back(entry);

	storePlayerKill(playerInfo->statistics->player_id, lasthit);
}

void Battleground::incrementPlayerDeaths(Bg_PlayerInfo_t* playerInfo, Bg_DeathEntry_t* entry)
{
	playerInfo->statistics->deaths.push_back(entry);
	storePlayerDeath(playerInfo->statistics->player_id);
}

bool Battleground::storePlayerKill(uint32_t player_id, bool lasthit)
{
	Database* db = Database::getInstance();
	DBQuery query;

	Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return false;

	query << "INSERT INTO `custom_pvp_kills` (`player_id`, `is_frag`, `date`, `type`, `ref_id`) VALUES (" << player->getGUID() << ", " << ((lasthit) ? 1 : 0) << ", " << time(NULL) << ", " << type << ", " << lastID << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storePlayerDeath(uint32_t player_id)
{
	Database* db = Database::getInstance();
	DBQuery query;

	Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return false;

	query << "INSERT INTO `custom_pvp_deaths` (`player_id`, `date`, `type`, `ref_id`) VALUES (" << player->getGUID() << ", " << time(NULL) << ", " << type << ", " << lastID << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storeNew()
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "INSERT INTO `battlegrounds` (`begin`) VALUES (" << lastInit << ")";
	if(!db->query(query.str()))
		return false;

	lastID = db->getLastInsertId();

	return true;
}

bool Battleground::storeFinish(time_t end, uint32_t finishBy, uint32_t team1_points, uint32_t team2_points)
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "UPDATE `battlegrounds` SET `end` = " << end << ", `finishBy` = " << finishBy << ", `team1_points` = " << team1_points << ", team2_points = " << team2_points << " WHERE `id` = " << lastID;
	if(!db->query(query.str()))
		return false;

	return true;
}

void Battleground::incrementTeamPoints(Bg_Teams_t team_id, uint32_t points)
{
    teamsMap[team_id].points += points;
    lastTeamScore = team_id;

    BgTeamsMap::iterator it = teamsMap.find(BATTLEGROUND_TEAM_ONE);
    if(it != teamsMap.end()){
        it->second.flag_player = 0;
        it->second.flag_debuff_stacks = 0;
        it->second.flag_debuff_ticks = 0;
    }

    it = teamsMap.find(BATTLEGROUND_TEAM_TWO);
    if(it != teamsMap.end()){
        it->second.flag_player = 0;
        it->second.flag_debuff_stacks = 0;
        it->second.flag_debuff_ticks = 0;
    }

    if(teamsMap[team_id].points >= winPoints && status == STARTED)
    {
		finish(team_id);
    }
}

void Battleground::setTeamPoints(Bg_Teams_t team_id, uint32_t points)
{
    teamsMap[team_id].points = points;
    lastTeamScore = team_id;

    BgTeamsMap::iterator it = teamsMap.find(BATTLEGROUND_TEAM_ONE);
    if(it != teamsMap.end()){
        it->second.flag_player = 0;
        it->second.flag_debuff_stacks = 0;
    }

    it = teamsMap.find(BATTLEGROUND_TEAM_TWO);
    if(it != teamsMap.end()){
        it->second.flag_player = 0;
        it->second.flag_debuff_stacks = 0;
    }

    if(teamsMap[team_id].points >= winPoints && status == STARTED)
    {
		finish(team_id);
    }
    else{

    }
}

StatisticsList Battleground::getStatistics()
{
	statisticsList.sort(Battleground::orderStatisticsListByPerformance);
	return statisticsList;
}

PlayersMap Battleground::listPlayersOfTeam(Bg_Teams_t team)
{
	BgTeamsMap::iterator it = teamsMap.find(team);

	PlayersMap playersMap;
	if(it == teamsMap.end())
		return playersMap;

	playersMap = it->second.players;
	return playersMap;
}

bool Battleground::orderWaitlistByLevel(Player* first, Player* second)
{
	return first->getLevel() > second->getLevel();
}

bool Battleground::orderWaitlistByRating(Player* first, Player* second)
{
    return first->getBattlegroundRating() > second->getBattlegroundRating();
}

#endif
