#include "player.h"
#include "enums.h"
#include <unordered_map>
#include <list>

typedef std::list<Player*> PlayerList;
typedef std::unordered_map<uint32_t, PlayerList> PlayersMap;
typedef std::unordered_map<uint32_t, uint32_t> HourMap;

class Spoof
{
    public:
        Spoof();

        bool onStartup();
        void onLogin(Player* player);
        void loginPlayer(Player* player);
        void onLogout(Player* player);
        void logoutPlayer(Player* player, Player* kicker);
        void onExiva(Player* player, Player* target);
        Player* loadPlayer();

    private:
        PlayersMap m_players;
        SpoofList m_spoofList;
        HourMap m_hours;
};
