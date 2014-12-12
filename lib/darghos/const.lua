--[[
 * Contem todas constantes referentes ao Darghos, podem estar divididas por Arrays!
]]--

	ACCESS_PLAYER				= 0
	ACCESS_TUTOR				= 1
	ACCESS_GAME_MASTER			= 3
	ACCESS_COMMUNITY_MANAGER	= 4
	ACCESS_ADMIN				= 5
	ACCESS_SADMIN				= 6
	
	GROUP_PLAYER				= 1
	GROUP_PLAYER_NON_PVP		= 2
	GROUP_PLAYER_TUTOR			= 3
	
	DISTROS_OPENTIBIA			= "opentibia"
	DISTROS_TFS					= "tfs"
	
	WORLD_UNITERIAN = 0
	WORLD_TENERIAN = 1

	T_LOG_ALL = "ALL"
	T_LOG_NOTIFY = "NOTIFY"
	T_LOG_WARNING = "WARNING"
	T_LOG_FAIL = "FAIL"
	T_LOG_ERROR = "ERROR"
	T_LOG_FATAL_ERROR = "FATAL ERROR"
	
	STORAGE_NULL = -1
	
	LIGHT_FULL = 1
	LIGHT_NONE = -1
	
	ANTI_IDLE_INTERVAL = 1000 * 60
	ANTI_IDLE_NONE = 0
	
	BOAT_DESTINY_QUENDOR = 				{x=1926, y=1867, z=6}
	BOAT_DESTINY_ARACURA = 				{x=3401, y=1991, z=6}
	BOAT_DESTINY_AARAGON = 				{x=3005, y=1119, z=6}
	BOAT_DESTINY_SALAZART = 			{x=2140, y=2662, z=6}
	BOAT_DESTINY_NORTHREND = 			{x=2025, y=1235, z=6}
	BOAT_DESTINY_KASHMIR = 				{x=1167, y=1124, z=7}
	BOAT_DESTINY_THAUN = 				{x=2267, y=2058, z=6}
	BOAT_DESTINY_TRAINERS =				{x=2160, y=1486, z=6}
	BOAT_DESTINY_ISLAND_OF_PEACE = 		{x=1204, y=2186, z=6}
	BOAT_DESTINY_SEA_SERPENT_AREA = 	{x=2089, y=1141, z=8}
	
	CARPET_DESTINY_AARAGON = 	{x=2941, y=1207, z=6}
	CARPET_DESTINY_HILLS = 		{x=2167, y=1978, z=3}
	CARPET_DESTINY_SALAZART = 	{x=2311, y=2393, z=5}
	
	TRAIN_DESTINY_QUENDOR = 	{x=1980, y=1829, z=8}
	TRAIN_DESTINY_THORN = 		{x=2411, y=1827, z=8}
	
	EVENT_STATE_NONE	= -1
	EVENT_STATE_INIT	= 0
	EVENT_STATE_END		= 1

	access =
	{
		PLAYER = 0,
		TUTOR = 0,
		SENIOR_TUTOR = 2,
		GAME_MASTER = 3,
		COMMUNITY_MANAGER = 4,
		GOD = 5
	}
	
	GROUPS_PLAYER = 1
	GROUPS_PLAYER_NONPVP = 2 -- old, island of peace hack, now deprecated
	GROUPS_TUTOR = 3
	GROUPS_SENIOR_TUTOR = 4
	GROUPS_GAMEMASTER = 5
	GROUPS_COMMUNITY_MANAGER = 6
	GROUPS_ADMINISTRATOR = 7
	GROUPS_PLAYER_BOT = 8

	vocations =
	{
		NONE = 0,
		SORCERER = 1,
		DRUID = 2,
		PALADIN = 3,
		KNIGHT = 4,
		MASTER_SORCERER = 5,
		ELDER_DRUID = 6,
		ROYAL_PALADIN = 7,
		ELITE_KNIGHT = 8
	}

	outfits =
	{
		CITIZEN = {female = 136, male = 128},
		HUNTER = {female = 137, male = 129},
		MAGE = {female = 138, male = 130},
		KNIGHT = {female = 139, male = 131},
		NOBLE = {female = 140, male = 132},
		SUMMONER = {female = 141, male = 133},
		WARRIOR = {female = 142, male = 134},
		BARBARIAN = {female = 147, male = 143},
		DRUID = {female = 148, male = 144},
		WIZARD = {female = 149, male = 145},
		ORIENTAL = {female = 150, male = 146},
		PIRATE = {female = 155, male = 151},
		ASSASSIN = {female = 156, male = 152},
		BEGGAR = {female = 157, male = 153},
		SHAMAN = {female = 158, male = 154},
		NORSE = {female = 252, male = 251},
		NIGHTMARE = {female = 269, male = 268},
		JESTER = {female = 270, male = 273},
		BROTHERHOOD = {female = 279, male = 278},
		DEMONHUNTER = {female = 288, male = 289},
		YALAHARIAN = {female = 324, male = 325},
		WARMASTER = {female = 336, male = 335},
		WEEDING = {female = 329, male = 328},
		GAMEMASTER = {female = 75, male = 75},
		OLD_CM = {female = 266, male = 266},
		CM = {female = 302, male = 302}
	}
	
	OUTFIT_ID_CITIZEN = 1
	OUTFIT_ID_HUNTER = 2
	OUTFIT_ID_MAGE_SUMMONER_HAT = 3
	OUTFIT_ID_KNIGHT = 4
	OUTFIT_ID_NOBLE = 5
	OUTFIT_ID_MAGE_SUMMONER = 6
	OUTFIT_ID_WARRIOR = 7
	OUTFIT_ID_BARBARIAN = 8
	OUTFIT_ID_DRUID = 9
	OUTFIT_ID_WIZARD = 10
	OUTFIT_ID_ORIENTAL = 11
	OUTFIT_ID_PIRATE = 12
	OUTFIT_ID_ASSASSIN = 13
	OUTFIT_ID_BEGGAR = 14
	OUTFIT_ID_SHAMAN = 15
	OUTFIT_ID_NORSE = 16
	OUTFIT_ID_NIGHTMARE = 17
	OUTFIT_ID_JESTER = 18
	OUTFIT_ID_BROTHERHOOD = 19
	OUTFIT_ID_DEMON_HUNTER = 20
	OUTFIT_ID_YALAHARIAN = 21
	OUTFIT_ID_WARMASTER = 22
	OUTFIT_ID_WAYFARER = 23

	-->> Posiï¿½ï¿½es de area para checagem ao login {creaturescripts/login.lua} (expulsa jogadores free de area premium)
	areaCheck = 
	{
		ARACURA_START = {x=2627 ,y=1043 ,z=7},
		ARACURA_END = {x=3097 ,y=1411 ,z=7},

		NORTHREND_START = {x=1677 ,y=1026 ,z=7},
		NORTHREND_END = {x=2103 ,y=1526 ,z=7},

		SALAZART_START = {x=1952 ,y=2299 ,z=7},
		SALAZART_END = {x=2773 ,y=2660 ,z=7}
	}
	
	towns =
	{
		QUENDOR = 1,
		AARAGON = 2,
		SALAZART = 5,	
		ISLAND_OF_PEACE = 6,
		NORTHREND = 7,
		KASHMIR = 9,
		ARACURA = 10
	}
	
	-->> Posiï¿½ï¿½es dos templos

		QUENDOR = {x=2020 ,y=1903, z=7}
		THORN = {x=2383 ,y=1856, z=7}
		SALAZART = {x=2271 ,y=2686, z=7}
		ARACURA = {x=2897 ,y=1185, z=7}
		ISLAND_PEACE = {x=1234 ,y=2234 ,z=7}
	
	ACTION_ID_RANGES = {
	
		MIN_FIELD_DAMAGE = 8300,
		MAX_FIELD_DAMAGE = 8499
	}
	
	WEEKDAY = {
		SUNDAY 		= 1,
		MONDAY 		= 2,
		TUESDAY 	= 3,
		WEDNESDAY 	= 4,
		THURSDAY 	= 5,
		FRIDAY 		= 6,
		SATURDAY 	= 7
	}
	
	WEEKDAY_STRING = {
		[WEEKDAY.SUNDAY] = "domingo"
		,[WEEKDAY.MONDAY] = "segunda-feira"
		,[WEEKDAY.TUESDAY] = "terça-feira"
		,[WEEKDAY.WEDNESDAY] = "quarta-feira"
		,[WEEKDAY.THURSDAY] = "quinta-feira"
		,[WEEKDAY.FRIDAY] = "sexta-feira"
		,[WEEKDAY.SATURDAY] = "sabado"
	}
	
	CUSTOM_ITEMS = {
	
		DURIN_HELMET			= 11736,
		DURIN_ARMOR				= 11737,
		DURIN_LEGS				= 11738,
		DURIN_SHIELD			= 11739,
		
		TASHI_AHARON_HELMET		= 11740,
		TASHI_AHARON_ARMOR		= 11741,
		TASHI_AHARON_LEGS		= 11742,
		TASHI_AHARON_BOOTS		= 11743,
		
		WARDEN_HELMET			= 11744,
		WARDEN_ARMOR			= 11745,
		WARDEN_LEGS				= 11746,
		WARDEN_BOOTS			= 11747,
		
		DEATHFACE_HELMET		= 11748,
		DEATHFACE_ARMOR			= 11749,
		DEATHFACE_LEGS			= 11750,
		DEATHFACE_BOOTS			= 11751,
		
		DARK_DUST				= 12669,
		UNHOLY_SWORD			= 12670,
		TELEPORT_RUNE			= 12671,
		PREMIUM_SCROLL_MONTLY		= 12690,
		PREMIUM_SCROLL_WEEKLY		= 12696,
		OUTFIT_TICKET			= 12691,
		
		GREEN_CHRISTMAS_PRESENT = 12692,
		RED_CHRISTMAS_PRESENT = 12693,
		BLUE_CHRISTMAS_PRESENT = 12694,
		BIG_CHRISTMAS_PRESENT = 12695,
		
		ORDON_DESTRUCTION_AMULET = 12698,
		
		PETRIFIED_STONEHEARTH = 12701,
		VENGEANCE_SEAL_RING = 12704,
		CROOKED_EYE_RING = 12707,
		
		FLASK_OF_MAGIC_PRODUCTIVITY = 12710
	}
	
	-- Pacific & Agresives Configuration
	
	-- Nesta configuração o jogador poderá começar como pacifico porem será restrito a Island of Peace, e após certo level a sua rate sera de 1x
	-- o obrigando a sair da ilha virando agressivo, não podendo retornar a ela, semelhante a Rookgaard do Tibia Global.
	WORLD_CONF_AGRESSIVE_ONLY = 0
	
	-- Nesta configuração o jogador poderá modificar entre pacifico e agressivo em intervalos de tempo, jogadore pacificos não podem entrar em Aracura
	-- e agressivos não podem entrar em Island of Peace, em outros lugares há a convivencia de ambos modos de pvp
	WORLD_CONF_CHANGE_ALLOWED = 1
	
	-- Nesta configuração quase nunca havera a convivencia no mesmo lugar de pacificos e agressivos, a mudança é permitida em um determinado dia da semana 
	-- porem os jogadores somente poderão acessar lugares permitidos pelo seu pvp, paficicos somente Island of Peace, e agressivos o restante.
	WORLD_CONF_WEECLY_CHANGE = 2
	
	-- Custom Exhausteds
	EXHAUSTED_COMBAT_AREA = 3
	EXHAUSTED_ESPECIAL = 4
	EXHAUSTED_GLOBAL = 5
	EXHAUSTED_PARALYZE = 6
	
	-- Custom Flags
	PLAYERCUSTOMFLAG_CONTINUEONLINEWHENEXIT = 26
	
	-- Custom Conditions
	CONDITION_IGNORE_DEATH_LOSS = 16777216 -- 1 << 24
	
	-- Constantes para o OpenTibia, nao envolvem coisas do Darghos mas nao existem no projeto original
	HOUSE_ACCESS_NOT_INVITED = 0
	HOUSE_ACCESS_GUEST = 1
	HOUSE_ACCESS_SUBOWNER = 2
	HOUSE_ACCESS_OWNER = 3
	
	-- Custom Return Values
	FIRST_CUSTOM_RETURNVALUE = 65
	RETURNVALUE_YOUINTERRUPTYOURCAST = FIRST_CUSTOM_RETURNVALUE
	RETURNVALUE_YOUCANNOTUSETHISITEMINFIGHT = RETURNVALUE_YOUINTERRUPTYOURCAST + 1
	
	-- Return values to Talkaction parameters parser
	TALK_PARAMS_WRONG_EXPECTED_VALUE = 0
	TALK_PARAMS_WRONG_PARAMETER = 1
	TALK_PARAMS_CALL_HELP = 2
	TALK_PARAMS_DONE = 3
	
	ITEM_RARITY_NONE = 0
	ITEM_RARITY_COMMON = 1
	ITEM_RARITY_RARE = 2
	ITEM_RARITY_EPIC = 3
	ITEM_RARITY_LEGENDARY = 4
	
	------------------------------
	----[[ by Bruno | Storm ]]----
	------------------------------
	
	-- Kashmir Quest
	KASHMIR_TP_IN_SELF_POSITION		= { x=1118, y=1155, z=9 }
	KASHMIR_TP_IN_DESTINATION		= { x=1118, y=1152, z=10 }
	KASHMIR_TP_OUT_SELF_POSITION		= { x=1117, y=1153, z=10 }
	KASHMIR_TP_OUT_DESTINATION		= { x=1116, y=1157, z=9 }
	KASHMIR_GLOBE_POSITION			= { x=1117, y=1144, z=10 }
	KASHMIR_ROOM_TOP_LEFT_POSITION		= { x=1110, y=1136, z=10 }
	KASHMIR_ROOM_BOTTOM_RIGHT_POSITION	= { x=1124, y=1153, z=10 }
	KASHMIR_ROOM_BLIND_FIELD_POSITION	= { x=1115, y=1135, z=10, stackpos=1 }
	KASHMIR_TTIME				= { 10, 30 }
	KASHMIR_LAST_TILE_POSITION		= { x=1077, y=1132, z=11, stackpos=253 }
	
	DEMONA_TP_DESTINATION			= { x=1439, y=1536, z=8 }
	
	------------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	