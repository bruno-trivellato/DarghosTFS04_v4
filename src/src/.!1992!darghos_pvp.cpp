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
            kickPlayerById(it_players->first, true);
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
