#ifdef __DARGHOS_PVP_SYSTEM__
#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#define BATTLEGROUND_MAX_LEVEL 200

#define BATTLEGROUND_MAX_MAGE_HEALTH 1145
#define BATTLEGROUND_MAX_PALADIN_HEALTH 2105
#define BATTLEGROUND_MAX_KNIGHT_HEALTH 3065

#define BATTLEGROUND_MAX_MAGE_MANA 5795
#define BATTLEGROUND_MAX_PALADIN_MANA 2915
#define BATTLEGROUND_MAX_KNIGHT_MANA 995

#include "player.h"
#include "darghos_const.h"

#define BATTLEGROUND_DESERTOR_TIME 60 * 25
#define LIMIT_TARGET_FRAGS_INTERVAL 60 * 3
#define PVP_CHANNEL_ID 10

typedef std::list<Player*> Bg_Waitlist_t;
typedef std::list<uint32_t> AssistsList;

struct Bg_DeathEntry_t
{
	uint32_t lasthit;
	time_t date;
	AssistsList assists;
};

typedef std::list<Bg_DeathEntry_t*> DeathsEntryList;

struct Bg_Statistic_t
{
	uint32_t player_id;
	DeathsEntryList kills, assists, deaths;
};

typedef std::list<Bg_Statistic_t*> StatisticsList;
typedef std::list<uint32_t> AssistList;

struct Bg_PlayerInfo_t
{
	time_t join_in;
	Outfit_t default_outfit;
	Position masterPosition;
	Position oldPosition;
	bool areInside;
	Bg_Statistic_t* statistics;
};

struct Bg_TeamLook_t
{
    uint8_t head, body, legs, feet;
};

typedef std::map<uint32_t, Bg_PlayerInfo_t> PlayersMap;

struct Bg_Team_t {
    PlayersMap players;
    Bg_TeamLook_t look;
	Position entrance_pos;
    Position spawn_pos;
    uint32_t flag_player;
    uint32_t flag_debuff_ticks;
    uint32_t flag_debuff_stacks;
	uint32_t points;
	uint32_t levelSum;
};

typedef std::map<Bg_Teams_t, Bg_Team_t> BgTeamsMap;

class Game;

class Battleground
{
    public:
        Battleground();
		virtual ~Battleground();

		void onInit();

		void setOpen(){ open = true; }
		void setClosed() { open = false; onClose(); }
        bool isOpen(){ return open; }
		void onClose();

		bool buildTeams();
		Bg_Teams_t sortTeam();

		BgTeamsMap getTeams() const { return teamsMap; }
        void finishByWinner(Bg_Teams_t teamWinner);
		void finish();

        uint32_t getLastId() { return lastID; }
		uint32_t getWaitlistSize(){ return waitlist.size(); }
		BattlegroundStatus getStatus() { return status; }

        BattlegrondRetValue onPlayerJoin(Player* player);
		BattlegrondRetValue kickPlayer(Player* player, bool force = false);
		void onPlayerDeath(Player* killer, DeathList deathList);
		PlayersMap listPlayersOfTeam(Bg_Teams_t team);
		Bg_PlayerInfo_t* findPlayerInfo(Player* player);
		Bg_Teams_t findTeamIdByPlayer(Player* player);
		Bg_Team_t* findPlayerTeam(Player* player);
		void putInTeam(Player* player, Bg_Teams_t team_id);
		void putInside(Player* player);
		void start();
		bool playerIsInWaitlist(Player* player);
		void removeWaitlistPlayer(Player* player);
        void removeIdleWaitlistPlayer(uint32_t player_id);
		uint32_t getTeamSize() { return teamSize; }

		void incrementTeamPoints(Bg_Teams_t team_id, uint32_t points = 1);
		void setTeamPoints(Bg_Teams_t team_id, uint32_t points);

		void setTeamSize(uint32_t size){ teamSize = size; }
		void setWinPoints(uint32_t points){ winPoints = points; }
		void setDuration(uint32_t seconds){ duration = (seconds * 1000); }

		StatisticsList getStatistics();
		void clearStatistics(){
			statisticsList.clear();

			for(DeathsEntryList::iterator it = deathsList.begin(); it != deathsList.end(); it++)
			{
				delete (*it);
			}

			deathsList.clear();
		}

		static bool orderStatisticsListByPerformance(Bg_Statistic_t* first, Bg_Statistic_t* second) {
			if(first->kills.size() == second->kills.size()) return (first->deaths.size() < second->deaths.size()) ? true : false;
			else return (first->kills.size() > second->kills.size()) ? true : false;
		}

		static bool orderDeathListByDate(Bg_DeathEntry_t* first, Bg_DeathEntry_t* second) {
			return (first->date > second->date) ? true : false;
		}

		static bool orderWaitlistByLevel(Player* first, Player* second);
		static bool orderWaitlistByRating(Player* first, Player* second);

    private:
        bool open;
		DarghosPvpTypes type;
		BattlegroundStatus status;
        BgTeamsMap teamsMap;
		DeathsEntryList deathsList;
		StatisticsList statisticsList;
		time_t lastInit;
		Bg_Waitlist_t waitlist;
		uint32_t lastID;
		uint32_t teamSize;
		uint32_t winPoints;
		uint32_t duration;
        Bg_Teams_t lastTeamScore;

		uint32_t endEvent;

		void callPlayer(uint32_t player_id);

		bool isValidFrag(Bg_PlayerInfo_t* killer_info, Bg_PlayerInfo_t* target_info);

		void incrementPlayerKill(Bg_PlayerInfo_t* playerInfo, Bg_DeathEntry_t* entry, bool lasthit = false);
		void incrementPlayerDeaths(Bg_PlayerInfo_t* playerInfo, Bg_DeathEntry_t* entry);

		bool storeNew();
		bool storeFinish(time_t end, uint32_t finishBy, uint32_t team1_points, uint32_t team2_points);

		bool storePlayerKill(uint32_t player_id, bool lasthit);
		bool storePlayerDeath(uint32_t player_id);
};

#endif
#endif
