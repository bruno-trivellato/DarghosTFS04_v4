#include "player.h"
#include "enums.h"
#include <unordered_map>
#include <list>
#include <vector>

typedef std::vector<uint32_t> PlayerIdVec;
typedef std::list<uint32_t> HourMapArgs;
typedef std::unordered_map<uint32_t, HourMapArgs> HourMap;

class Spoof
{
    public:
        Spoof();

        bool onStartup();
        void onThink();
        void loginPlayer(Player* player);
        void unspoof(Player* player);
        void onExiva(Player* player, Player* target);
        Player* loadPlayer();

    private:
        PlayerIdVec m_players;
        SpoofList m_spoofList;
        HourMap m_hours;
};

