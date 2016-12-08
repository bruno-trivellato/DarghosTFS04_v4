BG_ENABLED = true
BG_ENABLED_GAINS = true

BG_EXP_BUFF = 25 -- percent
BG_EXP_BUFF_DURATION = 60 * 60 * 2 -- two hours

FREE_GAINS_PERCENT = 30
BG_EXP_RATE = 1
BG_EACH_BONUS_PERCENT = 50
BG_BONUS_INTERVAL = 60 * 60

BG_GIVE_MONEY = true
BG_MONEY_WIN = 20000
BG_MONEY_LOST = 10000
BG_EXPGAIN_LOST_PERCENT = 30

BG_CONFIG_TEAMSIZE = 5
BG_CONFIG_WINPOINTS = 3
BG_CONFIG_DURATION = 60 * 20

BG_AFK_TIME_LIMIT = 60 * 2
BG_WINNER_INPZ_PUNISH_INTERVAL = 60

BG_LASTPLAYERS_BROADCAST_INTERVAL = 60 * 3
BG_LEAVE_SPAWN_INTERVAL = 10

BG_RET_NO_ERROR = 0
BG_RET_CLOSED = 1
BG_RET_CAN_NOT_JOIN = 2
BG_RET_PUT_IN_WAITLIST = 3
BG_RET_PUT_INSIDE = 4
BG_RET_PUT_DIRECTLY = 5
BG_RET_ALREADY_IN_WAITLIST = 6
BG_RET_INFIGHT = 7

PVPCHANNEL_MSGMODE_BROADCAST = 0
PVPCHANNEL_MSGMODE_INBATTLE = 1
PVPCHANNEL_MSGMODE_OUTBATTLE = 2

BATTLEGROUND_TEAM_NONE = 0
BATTLEGROUND_TEAM_ONE = 1
BATTLEGROUND_TEAM_TWO = 2

BATTLEGROUND_STATUS_BUILDING_TEAMS = 0
BATTLEGROUND_STATUS_PREPARING = 1
BATTLEGROUND_STATUS_STARTED = 2
BATTLEGROUND_STATUS_FINISHED = 3

BATTLEGROUND_MIN_LEVEL = 60
	
BATTLEGROUND_CAN_NON_PVP = true

BATTLEGROUND_FLAG_BONUS_POINTS = 30

BATTLEGROUND_HONOR_LIMIT = 8000
BATTLEGROUND_DEATH_HONOR_GIVE = 20
BATTLEGROUND_FRAGGER_HONOR_PERCENT = 50
BATTLEGROUND_HONOR_BASE = 80
BATTLEGROUND_HONOR_WIN = 100
BATTLEGROUND_HONOR_CAPTURE_FLAG = 50

BG_FLAG_STATE_NONE = 1
BG_FLAG_STATE_DROP = 2
BG_FLAG_STATE_CAPTURED = 3
BG_FLAG_STATE_CARRYING = 4
BG_FLAG_STATE_RETURNED = 5

BG_GAIN_EVERYHOUR_DAYS = { WEEKDAY.SATURDAY, WEEKDAY.SUNDAY }
BG_GAIN_START_HOUR = 11
BG_GAIN_END_HOUR = 1

-- BANS CONSTS
BATTLEGROUND_BAN_TYPE_PLAYER = 0
BATTLEGROUND_BAN_TYPE_ACCOUNT = 1

BATTLEGROUND_BAN_ENDS_NEVER = -1

pvpBattleground = {
	lastJoinBroadcastMassage = 0
}

BATTLEGROUND_RATING = 3
BATTLEGROUND_HIGH_RATE = 1601
BATTLEGROUND_LOW_RATE = 501

BATTLEGROUND_STONE_SPAWN_ID = 1285

-- team misc
BATTLEGROUND_TEAM = {
	[BATTLEGROUND_TEAM_ONE] = { 
		flag = uid.BATTLEGROUND_TEAM_ONE_FLAG
		, uid = uid.BATTLEGROUND_TEAM_ONE_FLAG_SPAWN
		, item_id = 11293
		, lastKiller = gid.BG_LAST_FLAG_KILLER_TEAM_ONE
		, lastDeathDate = gid.BG_LAST_DEATH_TEAM_ONE 
	}
	,[BATTLEGROUND_TEAM_TWO] = { 
		flag = uid.BATTLEGROUND_TEAM_TWO_FLAG
		, uid = uid.BATTLEGROUND_TEAM_TWO_FLAG_SPAWN
		, item_id = 10952
		, lastKiller = gid.BG_LAST_FLAG_KILLER_TEAM_TWO
		, lastDeathDate = gid.BG_LAST_DEATH_TEAM_TWO 
	}
}
--[[
	RATING & EXP AREA
]]--

battlegroundExpToLevelGain = {
	{to = 124, multipler = 10.00},
	{from = 125, to = 149, multipler = 6.00},
    {from = 150, to = 199, multipler = 4.00},
    {from = 200, to = 299, multipler = 3.00},
    {from = 300, to = 399, multipler = 2.00},
    {from = 400, to = 499, multipler = 1.50},
    {from = 500, multipler = 1.00},
}

battlegrondRatingTable = {

	{to = 400, multipler = 35},
	{from = 401, to = 800, multipler = 25},
	{from = 801, to = 1000, multipler = 10},
	{from = 1001, to = 1200, multipler = 8},
	{from = 1201, to = 1400, multipler = 6},
	{from = 1401, to = 1600, multipler = 5},
	{from = 1601, to = 2000, multipler = 4},
	{from = 2001, to = 2400, multipler = 3},
	{from = 2401, to = 2800, multipler = 2},
	{from = 2801, multipler = 1}
}

function pvpBattleground.getRatingMultipler(cid, rating)

	for k,v in pairs(battlegrondRatingTable) do
		local from = v.from or 0	
		local isLast = (v.to == nil) and true or false
		
		if(not isLast) then
			if(rating >= from and rating <= v.to) then
				return v.multipler
			end
		else
			return v.multipler
		end
	end
	
	return nil
end

function pvpBattleground.removePlayerRating(cid, timeIn, bgDuration, deserting)

	deserting = deserting or false

	local currentRating = getPlayerBattlegroundRating(cid)
	local changeRating = pvpBattleground.getChangeRating(cid, timeIn, bgDuration)
	
	if(not deserting) then
		if(currentRating >= BATTLEGROUND_HIGH_RATE) then
			changeRating = math.floor(changeRating)
		elseif(currentRating < BATTLEGROUND_LOW_RATE) then
			changeRating = math.floor(changeRating * 0.25)
		else
			changeRating = math.floor(changeRating * 0.75)
		end
	else
		changeRating = math.floor(changeRating)
	end
	
	local newRating = math.max(currentRating - changeRating, 0)		
	
	doPlayerSetBattlegroundRating(cid, newRating)
	
	return math.min(changeRating, currentRating)
end

function pvpBattleground.getChangeRating(cid, timeIn, bgDuration)

	local currentRating = getPlayerBattlegroundRating(cid)
	local ratingMultipler = pvpBattleground.getRatingMultipler(cid, currentRating)
	local changeRating = ratingMultipler * BATTLEGROUND_RATING
	
	return math.floor(changeRating * (timeIn / bgDuration))	
end

--[[
	GAIN EXP AREA
]]--

function pvpBattleground.getExpMultipler(level)

	for k,v in pairs(battlegroundExpToLevelGain) do
		local from = v.from or 0	
		local isLast = (v.to == nil) and true or false
		
		if(not isLast) then
			if(level >= from and level <= v.to) then
				return v.multipler
			end
		else
			return v.multipler
		end
	end
	
	return nil
end

function pvpBattleground.getExperienceGain(cid)
	local multipler = pvpBattleground.getExpMultipler(getPlayerLevel(cid, false))
	local rate = pvpBattleground.getExpGainRate(cid)
	local nextLevelExp = getExperienceForLevel(getPlayerLevel(cid, false) + 1) - getExperienceForLevel(getPlayerLevel(cid, false))
	
	return math.floor((nextLevelExp * multipler) * rate)
end

function pvpBattleground.getExpGainRate(cid)

	local rate = BG_EXP_RATE * darghos_exp_multipler
	local bonus = pvpBattleground.getBonus()
	if(bonus > 0) then
		rate = rate + (bonus * (BG_EACH_BONUS_PERCENT / 100))
		pvpBattleground.setBonus(0)
	end
	
	if(not isPremium(cid)) then
		rate = rate * (FREE_GAINS_PERCENT / 100)
	else
		local staminaMinutes = getPlayerStamina(cid)
		local bonusStamina = 40 * 60
		
		if(staminaMinutes > bonusStamina) then
			rate = rate + 0.5
		end
	end

	return rate
end

function pvpBattleground.getBonus()
	return math.max(0, getGlobalStorageValue(gid.BATTLEGROUND_BONUS))
end

function pvpBattleground.setBonus(bonus)
	return setGlobalStorageValue(gid.BATTLEGROUND_BONUS, bonus)
end

--[[
	GAIN HONOR AREA
]]--

function pvpBattleground.onGainHonor(cid, honorGain, showEffect)
	showEffect = showEffect or false

	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_TEMP_HONOR)
	local current = (storage >= 0) and storage or 0
	current = current + honorGain
	
	if(not isPremium(cid)) then
		current = math.ceil(current * (FREE_GAINS_PERCENT / 100))
	end
	
	setPlayerStorageValue(cid, sid.BATTLEGROUND_TEMP_HONOR, current)
	
	if(showEffect) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Você garantiu " .. honorGain .. " pontos de honra!")
	end
end

function getPlayerBattlegroundHonor(cid)
	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_HONOR_POINTS)
	return (storage >= 0) and storage or 0	
end

function setPlayerBattlegroundHonor(cid, honor)
	setPlayerStorageValue(cid, sid.BATTLEGROUND_HONOR_POINTS, honor)
end

function changePlayerBattlegroundHonor(cid, honorChange)
	local newHonor = getPlayerBattlegroundHonor(cid) + honorChange
	
	if(newHonor < 0) then
		setPlayerBattlegroundHonor(cid, 0)
	elseif(newHonor > BATTLEGROUND_HONOR_LIMIT) then
		setPlayerBattlegroundHonor(cid, BATTLEGROUND_HONOR_LIMIT)
	else
		setPlayerBattlegroundHonor(cid, newHonor)
	end
end

function pvpBattleground.doUpdateHonor(cid)

	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_TEMP_HONOR)
	local gainHonor = (storage >= 0) and storage * getConfigValue('rateLoot') or 0
	changePlayerBattlegroundHonor(cid, gainHonor)
	return gainHonor
end

--[[
	COMBAT STATS AREA
]]--

function pvpBattleground.getDamageDone(cid)
	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_DAMAGE_DONE)
	return (storage >= 0) and storage or 0
end

function pvpBattleground.getHealDone(cid)
	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_HEALING_DONE)
	return (storage >= 0) and storage or 0
end

function pvpBattleground.damageDone2Honor(cid)
	local damageDone = pvpBattleground.getDamageDone(cid)
	pvpBattleground.onGainHonor(cid, math.ceil(damageDone * 0.0005))
end

function pvpBattleground.healDone2Honor(cid)
	local healingDone = pvpBattleground.getHealDone(cid)
	pvpBattleground.onGainHonor(cid, math.ceil(healingDone * 0.00075))
end

--[[
	CORE AREA
]]--

function pvpBattleground.onInit()
	
	local configs = {
		teamSize = BG_CONFIG_TEAMSIZE,
		winPoints = BG_CONFIG_WINPOINTS,
		duration = BG_CONFIG_DURATION,
	}
	
	setBattlegroundConfigs(configs)
	pvpBattleground.setBonus(0)
	
	if(not BG_ENABLED) then
		pvpBattleground.close()
	end
end

function pvpBattleground.reload()
	pvpBattleground.close(false)
	pvpBattleground.setConfigs()
	battlegroundOpen()
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] Battleground recarregada. Use o !bg entrar para entrar!", TALKTYPE_TYPES["channel-red"])
end

function pvpBattleground.setConfigs()
	local configs = {
		teamSize = BG_CONFIG_TEAMSIZE,
		winPoints = BG_CONFIG_WINPOINTS,
		duration = BG_CONFIG_DURATION,
	}
	
	setBattlegroundConfigs(configs)
end

function pvpBattleground.close(message)
	message = message or true
	battlegroundClose()
	
	if(message) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] Battleground temporareamente fechada. Voltarão em alguns instantes.", TALKTYPE_TYPES["channel-red"])
	end
end

function pvpBattleground.hasGain(time)

	time = time or os.time()

	if(not BG_ENABLED_GAINS) then
		return false
	end

	local date = os.date("*t", time)
	return ((date.hour >= BG_GAIN_START_HOUR and date.hour <= 23)
		or (date.hour >= 0 and date.hour < BG_GAIN_END_HOUR)
		or isInArray(BG_GAIN_EVERYHOUR_DAYS, date.wday))
end

function pvpBattleground.getTeamFragPoints(team_id)

	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	
	local totalFrags = 0
	
	for _,cid in pairs(playersTeam) do
		if(isCreature(cid) and isPlayer(cid) and doPlayerIsInBattleground(cid)) then
			local playerInfo = getPlayerBattlegroundInfo(cid)
			totalFrags = totalFrags + playerInfo.kills
		end
	end
	
	return totalFrags
end

function pvpBattleground.getTeamHealDone(team_id)
	
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	
	local healDone = 0
	
	for _,cid in pairs(playersTeam) do
		if(isCreature(cid)) then
			healDone = healDone + pvpBattleground.getHealDone(cid)
		end
	end
	
	return healDone	
end

function pvpBattleground.drawRank()

	local msg = ""
	local teams = { "Time A", "Time B" }
	local data = getBattlegroundStatistics()
	
	--msg = msg .. "*B => Destruiu a bandeira\n"
	msg = msg .. "Informações personagem:\nFrags / Mortes / [Assists] | Danos | Cura\n\n"
	
	local vocStr = {
		"S"
		,"D"
		,"P"
		,"K"
		,"MS"
		,"ED"
		,"RP"
		,"EK"
		,"WS"
		,"WD"
		,"HP"
		,"BK"	
	}
	
	if(data and #data > 0) then
		local i = 1
		for k,v in pairs(data) do
			
			local _cid = v.player_id
			if(_cid ~= nil and isPlayer(_cid)) then
				
				local team = "Fora"
				
				if(getPlayerBattlegroundTeam(_cid) ~= BATTLEGROUND_TEAM_NONE) then
					team = teams[getPlayerBattlegroundTeam(_cid)]
				end	
				
				local spaces_c = 5	
				local spaces = ""	
				for i=1, spaces_c do spaces = spaces .. " " end
				
				local _vocStr = vocStr[getPlayerVocation(_cid)] or "??"
						
				msg = msg .. i .. "# " .. getPlayerName(_cid) .. " (" .. _vocStr .. ", lv " .. getPlayerLevel(_cid) .. ", " .. team .. ")\n " 
				msg = msg .. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] | " .. pvpBattleground.getDamageDone(_cid) .. " | " .. pvpBattleground.getHealDone(_cid) .. " \n"	
				i = i + 1
			end
		end
	end	
	
	return msg
end

function pvpBattleground.showStatistics(cid)

	local teams = { "Time A", "Time B" }
	
	local points = getBattlegroundTeamsPoints()	
	
	local msg = "Estatisticas da Partida:\n\n"
	
	msg = msg .. "(" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")\n\n"
	
	msg = msg .. pvpBattleground.drawRank()
	doShowTextDialog(cid, 2390, msg)
end

function pvpBattleground.showResult(cid, winnner)

	clear = clear or true

	local teams = { "Time A", "Time B" }
	
	local msg = "Não houve vencedor, declarado EMPATE!\n\n"
	
	if(winnner ~= BATTLEGROUND_TEAM_NONE) then
		msg = "O " .. teams[winnner] .. " é o VENCEDOR!\n\n"
	end
	
	msg = msg .. pvpBattleground.drawRank()
	doShowTextDialog(cid, 2390, msg)
end

function pvpBattleground.getInformations()
	local msg = "INSTRUÇÕES BASICAS:\n\n"
	msg = msg .. "Este é um sistema de PvP do Darghos baseado no classico Capture the Flag, e o objetivo é seu time capturar a bandeira adversária e entregar-la em sua base 3 vezes. A partida tem duração de até 15 minutos "
	msg = msg .. "se ao final do tempo nenhum time tiver capturado 3 vezes a bandeira adversaria a vitória é concedida ao com maior numero de bandeiras capturadas, e empate no caso de igualdade de bandeiras\n\n"
	msg = msg .. "Aos participantes do time vencedor é concedido uma quantidade de pontos de experiencia, dinheiro, rating e honra que você poderá usar para trocar por itens uteis com alguns NPCs!\n\n"
	msg = msg .. "Ao morrer você não perderá nada e nascera na base de seu time e logo poderá voltar para o combate!\n\n"
	msg = msg .. "Use o PvP Channel para se comunicar com seus companheiros, somente eles poderão ler suas mensagens.\n\n"
	msg = msg .. "Isto é um resumo muito curto, o sistema é muito maior! Você poderá encontrar informações mais detalhadas no link:\n"
	msg = msg .. "http://pt-br.darghos.wikia.com/wiki/Battlegrounds\n\nBoa Sorte!"

	return msg
end

function pvpBattleground.getSpellsInfo(cid)

	local newSpells = {
		{
			nil
		},
		{
			{words = "utura sio [nick]", name = "Friend Rejuvenation", mana = "340", desc = "Magia de turno. Recupera boa quantidade de vida do alvo a cada 1 segundo por 10 segundos."}
		},
		{
			{words = "exori con mort", name = "Focused Shot", mana = "720", cast = "3 seg", desc = "Principal magia de ataque, muito eficiente para finalização de um oponente imovel, causando um grande dano."}
		},
		{
			{words = "exana gran mort", name = "Intense Wound Cleasing", mana = "240", desc = "Recupera 40% da vida, sendo 10% instantaneamente e 30% em turnos de 1 segundo durante 15 segundos."},
			{words = "exana vita", name = "Life Scream", mana = "50%", desc = "Recupera 90% da vida."},
			{words = "exori hur san", name = "Divine Whirlwind Throw", desc = "Dano semelhante ao exori hur, porem recupera de 50 a 100 de mana, mas so pode ser usada a 1 quadrado de distancia."}
		}
	}

	local voc = (getPlayerPromotionLevel(cid) == 1) and getPlayerVocation(cid) - 4 or getPlayerVocation(cid)
	
	local str = ""
	
	if(newSpells[voc]) then
		for k,v in pairs(newSpells[voc]) do
			str = str .. v.words .. " (" .. v.name .. "):\n"
			
			if(v.mana) then
				str = str .. "Consome " .. v.mana .. " mana.\n"
			end
			
			if(v.cast) then
				str = str .. "Requer " .. v.cast .. " para lançar.\n"
			end			
			
			str = str .. "Descrição: " .. v.desc .. "\n\n"		
		end
	else
		str = "Nenhuma nova magia disponivel na Battleground para sua vocação"		
	end

	return str
end

function pvpBattleground.getPlayersTeamString(team_id)
	team_id = tonumber(team_id)
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	local teams = {[1] = "Time A", [2] = "Time B"}
	local msg = "Membros do " .. teams[team_id] .. " (comando \"!bg team\"):\n"
	
	if(playersTeam == nil or #playersTeam == 0) then return msg .. "Nenhum" end
	
	local islast = false
	for k,v in pairs(playersTeam) do
		
		if(#playersTeam == k) then
			islast = true
		end
		
		local player = v
		if(player) then
			local tmp_msg = "{PLAYER} ({PLAYER_LEVEL}{FLAG})"
			
			tmp_msg = string.gsub(tmp_msg, "{PLAYER}", getPlayerName(player))
			tmp_msg = string.gsub(tmp_msg, "{PLAYER_LEVEL}", getPlayerLevel(player))
			
			local withFlag = doPlayerIsFlagCarrier(player) and " | Bandeira" or ""
			tmp_msg = string.gsub(tmp_msg, "{FLAG}", withFlag)
			
			msg = msg .. tmp_msg
			msg = msg .. ((islast) and ".\n" or ", ")
		end
	end
	
	return msg
end

function pvpBattleground.sendPlayerChannelMessage(cid, msg, type)

	type = (type ~= nil) and type or TALKTYPE_TYPES["channel-white"]
	doPlayerSendChannelMessage(cid, "", msg, type, CUSTOM_CHANNEL_PVP)
end

function pvpBattleground.playerSpeakTeam(cid, message)
	
	local team_id = getPlayerBattlegroundTeam(cid)
	
	if(team_id == BATTLEGROUND_TEAM_NONE) then
		return false
	end
	
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	
	for k,v in pairs(playersTeam) do
		local target = v
		doPlayerSendChannelMessage(target, getPlayerName(cid) .. " [" .. getPlayerLevel(cid) .. " | " .. getPlayerBattlegroundRating(cid) .. "]", message, TALKTYPE_TYPES["channel-yellow"], CUSTOM_CHANNEL_BG_CHAT)		
	end
	
	return true
end

function pvpBattleground.sendPvpChannelMessage(message, mode, talktype)

	mode = mode or PVP_CHANNEL_BROADCAST

	if(mode == PVPCHANNEL_MSGMODE_BROADCAST) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, message)
	elseif(mode == PVPCHANNEL_MSGMODE_INBATTLE) then
		local users = getChannelUsers(CUSTOM_CHANNEL_PVP)
		talktype = talktype or TALKTYPE_TYPES["channel-white"]
		
		for k,v in pairs(users) do		
			if(getPlayerBattlegroundTeam(v) ~= BATTLEGROUND_TEAM_NONE) then
				doPlayerSendChannelMessage(v, "", message, talktype, CUSTOM_CHANNEL_PVP)
			end				
		end		
	elseif(mode == PVPCHANNEL_MSGMODE_OUTBATTLE) then
		local users = getChannelUsers(CUSTOM_CHANNEL_PVP)
		talktype = talktype or TALKTYPE_TYPES["channel-white"]
		
		for k,v in pairs(users) do		
			if(getPlayerBattlegroundTeam(v) == BATTLEGROUND_TEAM_NONE) then
				doPlayerSendChannelMessage(v, "", message, talktype, CUSTOM_CHANNEL_PVP)
			end				
		end	
	end
end

function pvpBattleground.broadcastLeftOnePlayer()

	if(pvpBattleground.lastJoinBroadcastMassage > 0 and pvpBattleground.lastJoinBroadcastMassage + BG_LASTPLAYERS_BROADCAST_INTERVAL > os.time()) then
		return
	end

	local messages = {
		"Quer ganhar bonus de experiencia, dinheiro e outras recompensas se divertindo com PvP no classico Capture The Flag? Participe da proxima battleground! Restam apénas mais um para fechar os times " .. BG_CONFIG_TEAMSIZE .. "x" .. BG_CONFIG_TEAMSIZE .. "! -> !bg entrar",
		"Restam apénas mais um jogador para fechar os times " .. BG_CONFIG_TEAMSIZE .. "x" .. BG_CONFIG_TEAMSIZE .. " para a proxima partida de Battleground! Ganhe recompensas! Ao morrer nada é perdido! Divirta-se! -> !bg entrar",
		"Gosta de PvP misturado com objetivos como o classico Capture The Flag? Prove seu valor! Restam apénas mais um jogadore para fechar os times " .. BG_CONFIG_TEAMSIZE .. "x" .. BG_CONFIG_TEAMSIZE .. " para a proxima Battleground! -> !bg entrar",
		"Não conhece o sistema de Battlegrounds? Conheça agora! Falta apénas você para o proxima batalha 6x6! Não há perdas nas mortes, ajude o time na busca a bandeira adversária rumo a vitoria e ganhe recompensas! -> !bg entrar",
	}
	
	local rand = math.random(1, #messages)
	doBroadcastMessage(messages[rand], MESSAGE_INFO_DESCR)
	pvpBattleground.lastJoinBroadcastMassage = os.time()
end

function pvpBattleground.onDealDamage(cid, damage)
	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_DAMAGE_DONE)
	local currDamage = (storage >= 0) and storage or 0
	setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_DAMAGE_DONE, currDamage + damage)
end

function pvpBattleground.onDealHeal(cid, heal)
	local storage = getPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_HEALING_DONE)
	local currHeal = (storage >= 0) and storage or 0
	setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_HEALING_DONE, currHeal + heal)
end

function pvpBattleground.storePlayerParticipation(cid, team, deserting, expGain, ratingChange, honorGain, highStamina)
	
	expGain = expGain or 0
	ratingChange = ratingChange or 0
	honorGain = honorGain or 0
	highStamina = highStamina or false
	
	local params = {}
	
	params["damage"] = pvpBattleground.getDamageDone(cid)
	params["heal"] = pvpBattleground.getHealDone(cid)
	params["expGain"] = expGain
	params["ratingChange"] = ratingChange
	params["honorGain"] = honorGain
	params["highStamina"] = (highStamina and 1 or 0)
	
	local json = require("json")
	
	local query = "INSERT INTO `battleground_teamplayers` "
	query = query .. "(`player_id`, `battleground_id`, `team_id`, `deserter`, `ip_address`, `params`) VALUES " 
	query = query .. "(" .. getPlayerGUID(cid)  .. ", "
	query = query .. getBattlegroundId() .. ", "
	query = query .. team .. ", "
	query = query .. (deserting and 1 or 0) .. ", "
	query = query .. getPlayerIp(cid) .. ", "
	query = query .. "'" .. json.encode(params) .. "');"
	
	db.executeQuery(query)
end

function pvpBattleground.onEnter(cid)

	if(not isPlayer(cid)) then
		return false
	end

	local isBanned, banData = pvpBattleground.doPlayerIsBanned(cid)
	if(isBanned) then
		local endsStr = "Permanente (deletado)"
		if(banData.ends ~= BATTLEGROUND_BAN_ENDS_NEVER) then
			endsStr = os.date("%d/%m/%y %X", banData.ends)
		end

		local typeStr = (banData.type == BATTLEGROUND_BAN_TYPE_PLAYER) and "Apénas este personagem" or "Toda a conta"
		
		local str = ""
		str = str .. "ATENÇÃO:\n\n"
		str = str .. "Você está banido de participar de partidas na Battleground pela seguinte razão:\n\n"
		str = str .. banData.reason .. "\n\n"
		str = str .. "Esta punição afeta: " .. typeStr .. ".\n"
		str = str .. "Está punição durará até: " .. endsStr .. "."
		
		doPlayerPopupFYI(cid, str)
		return false
	end
	
	if(doPlayerIsInArena(cid)) then
		doPlayerSendCancel(cid, "Você não pode entrar na battleground enquanto estiver dentro de uma Arena.")
		return false		
	end
	
	if(getCreatureCondition(cid, CONDITION_OUTFIT) or getCreatureCondition(cid, CONDITION_INVISIBLE)) then
		doPlayerSendCancel(cid, "Você não pode entrar na battleground enquanto estiver sob certos efeitos magicos.")
		return false
	end
	
	if(getPlayerLevel(cid) < BATTLEGROUND_MIN_LEVEL) then
		doPlayerSendCancel(cid, "So é permitido jogadores com level " .. BATTLEGROUND_MIN_LEVEL .. " ou superior a participarem de uma battleground.")
		return false	
	end
	
	if(not BATTLEGROUND_CAN_NON_PVP and not doPlayerIsPvpEnable(cid)) then
		doPlayerSendCancel(cid, "So é permitido a jogadores Agressivos a participarem de Battlegrounds.")
		return false
	end	
        
        local ring = getPlayerSlotItem(cid, CONST_SLOT_RING)
        if(ring.uid ~= 0) then
                doPlayerSendCancel(cid, "Para entrar em uma Battleground você não pode estar com nenhum anel equipado. Remova qualquer anel equipado e tente novamente.")
                return false
        end
	
	local closeTeam = getBattlegroundWaitlistSize() == (BG_CONFIG_TEAMSIZE * 2) - 1
	local ret = doPlayerJoinBattleground(cid)

	if(ret == BG_RET_CLOSED) then
		doPlayerSendCancel(cid, "A battleground está temporareamente fechada.")	
		return false
	end

	if(ret == BG_RET_CAN_NOT_JOIN) then
		doPlayerSendCancel(cid, "Você abandonou uma battleground e foi marcado como desertor, e não poderá entrar em outra durante 25 minutos.")
		return false
	end	
	
	if(ret == BG_RET_ALREADY_IN_WAITLIST) then
		doPlayerSendCancel(cid, "Você já se encontra na fila para a battleground!")
		return false	
	end
	
	if(ret == BG_RET_INFIGHT) then
		doPlayerSendCancel(cid, "Você está em condição de combate, aguarde sair e tente novamente.")
		return false
	end
		
	if(ret == BG_RET_PUT_IN_WAITLIST) then
		
		local leftStr = ""
		
		if(getBattlegroundWaitlistSize() == 1) then
			leftStr = "Um jogador "
		else
			leftStr = "Mais um jogador "
		end
		
		leftStr = leftStr .. "deseja participar de uma Battleground. "
		
		if(getBattlegroundWaitlistSize() < BG_CONFIG_TEAMSIZE * 2) then
		
			local playersLeft = (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize()
			
			leftStr = leftStr .. "Restam "
			
			if(playersLeft <= 2) then
				leftStr = leftStr .. "apénas "
			end
			
			if(playersLeft == 1) then
				pvpBattleground.broadcastLeftOnePlayer()
			end
			
			leftStr = leftStr .. "mais " .. (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize() .. " jogadores para iniciar a proxima partida! Quer participar também? Digite '!bg entrar'" 
		else
			closeTeam = false
			leftStr = leftStr .. " Quer participar também? Digite '!bg entrar'"
		end
	
		if(not closeTeam) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. leftStr, PVPCHANNEL_MSGMODE_OUTBATTLE)
		else
			pvpBattleground.sendPvpChannelMessage("[Battleground] Os times para a proxima battleground estão completos! A nova partida começara em instantes, assim que a Battleground estiver vazia...", PVPCHANNEL_MSGMODE_OUTBATTLE)
		end
		
		return true
	elseif(ret == BG_RET_PUT_INSIDE or ret == BG_RET_PUT_DIRECTLY) then
		lockTeleportScroll(cid)
		registerCreatureEvent(cid, "OnChangeOutfit")
		registerCreatureEvent(cid, "onStateChange")
		
		setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_DAMAGE_DONE, 0)
		setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_HEALING_DONE, 0)
		setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_FLAGS_CAPTURED, 0)
		setPlayerStorageValue(cid, sid.BATTLEGROUND_TEMP_HONOR, 0)

		local teams = { [1] = "Time A", [2] = "Time B" }
		local team = teams[getPlayerBattlegroundTeam(cid)]
		
		registerCreatureEvent(cid, "onBattlegroundDeath")
		registerCreatureEvent(cid, "onBattlegroundEnd")
		registerCreatureEvent(cid, "onBattlegroundThink")
		registerCreatureEvent(cid, "onBattlegroundLeave")
                registerCreatureEvent(cid, "onReceiveFlagStacks")
		
		doPlayerSetIdleTime(cid, 0)
		
		local msg = "Bem vindo ao sistema de Battleground do Darghos!\nComandos úteis: !bg stats, !bg afk [nick], !bg spells. Leia as regras em !bg regras.\n"
		
		local isFirstBattleground = getPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND)		
		if(isFirstBattleground == -1) then
			setPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND, 1)	
			doShowTextDialog(cid, 2390, pvpBattleground.getInformations())
		end
		
		msg = msg .. pvpBattleground.getPlayersTeamString(getPlayerBattlegroundTeam(cid))
		msg = msg .. "\nDivirta-se!"
		
		pvpBattleground.sendPlayerChannelMessage(cid, msg)
		
		if(ret == BG_RET_PUT_DIRECTLY) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") apresentou-se para recompor o " .. team .. ".", PVPCHANNEL_MSGMODE_INBATTLE)
		end
		
		doPlayerOpenChannel(cid, CUSTOM_CHANNEL_BG_CHAT)
		return true
	end
	
	return false
end

function pvpBattleground.addObjects()

	clearBattlegroundStatistics()
	local ITEM_GATE = 1514
	
	-- creature walls
	--[[
	local gid_creatures = {
		[uid.BATTLEGROUND_WALL_CREATURE_TEAM_ONE] = gid.WALL_CID_TEAM_ONE,
		[uid.BATTLEGROUND_WALL_CREATURE_TEAM_TWO] = gid.WALL_CID_TEAM_TWO
	}
	
	for i = uid.BATTLEGROUND_WALL_CREATURE_TEAM_ONE, uid.BATTLEGROUND_WALL_CREATURE_TEAM_TWO do
		local pos = getThingPos(i)
		local creature = getTopCreature(pos)
		if(creature and isMonster(creature.uid) and getCreatureName(creature.uid) == "bg_wall") then
			-- o wall já está lá... so iremos "topar" a sua vida
			doCreatureAddHealth(creature.uid, getCreatureMaxHealth(creature.uid) - getCreatureHealth(creature.uid))
		else
			doCleanTile(pos)
			local temp_monster = doSummonCreature("bg_wall", pos)
			doSetStorage(gid_creatures[i], temp_monster)
			registerCreatureEvent(temp_monster, "onStateChange")
		end
	end
	]]
	
	-- static items walls
	for i = uid.BATTLEGROUND_WALLS_START, uid.BATTLEGROUND_WALLS_END do
		local pos = getThingPos(i)
		doCleanTile(pos)
		doCreateItem(ITEM_GATE, pos)
	end	
	
	for _,v in pairs(BATTLEGROUND_TEAM) do
		
		local thing = getThing(v.flag, false)
		if(thing.uid ~= 0) then
			doRemoveItem(thing.uid)
		end
		
		local pos = getThingPos(v.uid)
		pvpBattleground.putFlag(_, pos, false)
	end
end

function pvpBattleground.setLastFlagKiller(cid)
	local enemy = getPlayerBattlegroundEnemies(cid)
	doSetStorage(BATTLEGROUND_TEAM[enemy].lastKiller, getPlayerGUID(cid))
end

function pvpBattleground.getLastFlagKiller(team)
	return getStorage(BATTLEGROUND_TEAM[team].lastKiller)
end

function pvpBattleground.returnFlag(team_id)
	local pos = getThingPos(BATTLEGROUND_TEAM[team_id].uid)
	pvpBattleground.putFlag(team_id, pos, false)
end

function pvpBattleground.autoReturnFlag(team_id)
    
    local thing = getThing(BATTLEGROUND_TEAM[team_id].flag)
    if(thing.uid ~= 0) then
        local pos = getThingPos(thing.uid)
        local posex = getThingPos(BATTLEGROUND_TEAM[team_id].uid)
        
        if(not doComparePositions(pos, posex)) then
      
            local msg = "[Battleground | A bandeira do |TEAM| ira reaparecer a base em 5 segundos..."
            local teams = { "Time A", "Time B" }                            
            msg = string.gsub(msg, "|TEAM|", teams[team_id])

            pvpBattleground.sendPvpChannelMessage(msg, PVPCHANNEL_MSGMODE_INBATTLE)    
            
            addEvent(pvpBattleground.returnFlag, 1000 * 5, team_id)
            
            doSendMagicEffect(pos, CONST_ME_POFF)
            doRemoveItem(thing.uid)
        end
    end
end

function pvpBattleground.putFlag(team_id, pos, dropping)
	local thing = getTileItemById(pos, 1386)
        local ground = getThingFromPos(pos)
	
	-- não iremos deixar colocar a flag no mesmo tile q estiver uma escada ou nos spawns das bandeiras...
	if(thing.uid ~= 0 or (isInArray({uid.BATTLEGROUND_TEAM_ONE_FLAG_SPAWN, uid.BATTLEGROUND_TEAM_TWO_FLAG_SPAWN}, ground.uid) and dropping)) then
		local alternativePositions = {
			{ x = pos.x, y = pos.y - 1, z = pos.z }
			,{ x = pos.x + 1, y = pos.y - 1, z = pos.z }
			,{ x = pos.x + 1, y = pos.y, z = pos.z }
			,{ x = pos.x + 1, y = pos.y + 1, z = pos.z }
			,{ x = pos.x, y = pos.y + 1, z = pos.z }
			,{ x = pos.x - 1, y = pos.y + 1, z = pos.z }
			,{ x = pos.x - 1, y = pos.y, z = pos.z }
			,{ x = pos.x - 1, y = pos.y - 1, z = pos.z }
		}
		
		local foundPos = false
		
		for _, _pos in pairs(alternativePositions) do
			thing = getTileItemById(_pos, 1386)
			if(thing.uid == 0) then
				pos = _pos
				foundPos = true
				
				break
			end
		end
		
		if(not foundPos) then
			error("[Battleground Warning | pvpBattleground.putFlag] Valid free tile to drop flag not found!")
			return
		end
	end
	
	local stone = getTileItemById(pos, BATTLEGROUND_STONE_SPAWN_ID)
        if(stone.uid ~= 0) then
            doRemoveItem(stone.uid)
        end

    doCleanTile(pos)

	local uid = doCreateItem(BATTLEGROUND_TEAM[team_id].item_id, pos)
	doItemSetAttribute(uid, "uid", BATTLEGROUND_TEAM[team_id].flag)
        
        if(dropping) then
            addEvent(pvpBattleground.autoReturnFlag, 1000 * 8, team_id)
        end
end

function pvpBattleground.setPlayerCarryingFlagState(cid, flagState)
	
	local enemy = getPlayerBattlegroundEnemies(cid)
	
	if(flagState == BG_FLAG_STATE_CARRYING) then
			
		doRemoveCondition(cid, CONDITION_HASTE)
		
		local condition = createConditionObject(CONDITION_OUTFIT)
		setConditionParam(condition, CONDITION_PARAM_TICKS, 1000 * BG_CONFIG_DURATION)
		addOutfitCondition(condition, { lookTypeEx = BATTLEGROUND_TEAM[enemy].item_id})
		doAddCondition(cid, condition)
		
		condition = createConditionObject(CONDITION_INFIGHT)
		setConditionParam(condition, CONDITION_PARAM_TICKS, 1000 * BG_CONFIG_DURATION)
		doAddCondition(cid, condition)
		
		doPlayerSetPzLocked(cid, true)
		
		--doChangeSpeed(cid, -240)
		
		--condition = createConditionObject(CONDITION_PARALYZE)
		--setConditionParam(condition, CONDITION_PARAM_TICKS, 1000 * BG_CONFIG_DURATION)
		--setConditionFormula(condition, -0.5, 0, -0.5, 0)
		--doAddCondition(cid, condition)
		
	elseif(isInArray({BG_FLAG_STATE_DROP, BG_FLAG_STATE_CAPTURED, BG_FLAG_STATE_NONE}, flagState)) then
		
		doRemoveCondition(cid, CONDITION_OUTFIT)
		doRemoveCondition(cid, CONDITION_INFIGHT)
		--doRemoveCondition(cid, CONDITION_PARALYZE)
		--doChangeSpeed(cid, 240)	
	end
	
	if(flagState == BG_FLAG_STATE_DROP) then
		playerHistory.logBattlegroundFlagDroped(cid)
	end
	
	if(flagState == BG_FLAG_STATE_CAPTURED) then
		pvpBattleground.onGainHonor(cid, BATTLEGROUND_HONOR_CAPTURE_FLAG, true)
		
		local flagsCaptured = tonumber(getPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_FLAGS_CAPTURED)) + 1
		setPlayerStorageValue(cid, sid.BATTLEGROUND_MATCH_FLAGS_CAPTURED, flagsCaptured)
		
		if(flagsCaptured == 3 and not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_FLAG_CATCHER)) then
			playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_FLAG_CATCHER)
		end
		
		if(not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_FLAG_CAPTURED)) then
			playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_FLAG_CAPTURED)
		end
		
		playerHistory.logBattlegroundFlagCaptured(cid)
		
		if(playerHistory.logBattlegroundFlagCapturedCount(cid) == 50 and not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_MANY_FLAGS_CAPTURED)) then
			playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_MANY_FLAGS_CAPTURED)
		end
		
		local points = getBattlegroundTeamsPoints()
		local team = getPlayerBattlegroundTeam(cid)
		
		if(points[team] == 2 and points[enemy] == 0) then
			doSetStorage(gid.BG_WINNING_BY_TWO_POINTS, team)
		end
		
		if(points[team] == 3 and points[enemy] == 2) then
			
			if(getStorage(gid.BG_WINNING_BY_TWO_POINTS) == enemy and not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_EPIC_MATCH)) then
				playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_EPIC_MATCH)
			end
			
			if(pvpBattleground.getLastFlagKiller(enemy) == getPlayerGUID(cid) and not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_SAVE_THE_DAY)) then
				playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_SAVE_THE_DAY)
			end
		end
	end
	
	if(flagState == BG_FLAG_STATE_RETURNED) then
		playerHistory.logBattlegroundFlagReturned(cid)
		
		if(playerHistory.logBattlegroundFlagReturnedCount(cid) == 50 and not playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_MANY_FLAGS_RETURNED)) then
			playerHistory.onAchiev(cid, PH_ACH_BATTLEGROUND_MANY_FLAGS_RETURNED)
		end
	end
end

function pvpBattleground.removeWall(team)
	local teamWalls = {
		[BATTLEGROUND_TEAM_ONE] = {uid.BATTLEGROUND_WALLS_START, uid.BATTLEGROUND_WALLS_START + 1, uid.BATTLEGROUND_WALLS_START + 2},
		[BATTLEGROUND_TEAM_TWO] = {uid.BATTLEGROUND_WALLS_END, uid.BATTLEGROUND_WALLS_END - 1, uid.BATTLEGROUND_WALLS_END - 2}
	}
	
	local ITEM_GATE = 1514
	
	for k,v in pairs(teamWalls[team]) do
		local pos = getThingPos(v)
		local item = getTileItemById(pos, ITEM_GATE)
		if(item.uid ~= 0) then
			doRemoveItem(item.uid)
		end
	end
end

function pvpBattleground.updateLastTeamDeath(team_id)
	doSetStorage(BATTLEGROUND_TEAM[team_id].lastDeathDate, os.time())
end

function pvpBattleground.getLastTeamDeath(team_id)
	return getStorage(BATTLEGROUND_TEAM[team_id].lastDeathDate)
end

function pvpBattleground.onLeaveSpawnArea(cid)

	local lastTeamDeath = pvpBattleground.getLastTeamDeath(getPlayerBattlegroundTeam(cid))
	
	if(lastTeamDeath ~= -1 and lastTeamDeath + BG_LEAVE_SPAWN_INTERVAL > os.time()) then
		local leftSeconds = (lastTeamDeath + BG_LEAVE_SPAWN_INTERVAL) - os.time()
		doPlayerSendCancel(cid, "Você podera sair em " .. leftSeconds .. " segundos.")
		return false	
	end
	
	return true
end

function pvpBattleground.onExit(cid, idle)

	idle = idle or false

	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		doPlayerSendCancel(cid, "Aguarde o inicio da partida para abandonar a Battleground.")
		return false
	end

	local team = getPlayerBattlegroundTeam(cid)
	local ret = doPlayerLeaveBattleground(cid)

	if(ret == BG_RET_NO_ERROR) then
		if(not idle) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") desertou a batalha!", PVPCHANNEL_MSGMODE_INBATTLE)		
		else
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") foi expulso por inatividade!", PVPCHANNEL_MSGMODE_INBATTLE)	
		end
		
		pvpBattleground.sendPvpChannelMessage("[Battleground] Um jogador desertou a batalha! Quer substituir-lo imediatamente? Digite '!bg entrar'!", PVPCHANNEL_MSGMODE_OUTBATTLE)
		
		local removedRating = pvpBattleground.removePlayerRating(cid, BG_CONFIG_DURATION, BG_CONFIG_DURATION, true)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você piorou a sua classificação (rating) em " .. removedRating .. " pontos por seu abandono da Battleground.")
		
		pvpBattleground.storePlayerParticipation(cid, team, true, 0, -removedRating, 0)
		
		return true
	end
	
	return false	
end

--[[
	IDLE REPORT AREA
]]--

function pvpBattleground.onReportIdle(cid, idle_player)

	if(not doPlayerIsInBattleground(idle_player) or 
		(getPlayerBattlegroundTeam(cid) ~= getPlayerBattlegroundTeam(idle_player))
		) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Este jogador não pertence a seu time ou não está na Battleground.")
		return
	end
	
	if(hasCondition(idle_player, CONDITION_INFIGHT)) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Este jogador está em combate portanto não pode estar inativo.")
		return		
	end
	
	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Somente é permitido fazer denuncias após a Battleground ter iniciado.")
		return
	end	
	
	local report_block = getPlayerStorageValue(cid, sid.BATTLEGROUND_INVALID_REPORT_BLOCK)
	if(report_block ~= 0 and os.time() <= report_block) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Você esta impossibilitado de efetuar denuncias de jogadores inativos momentaneamente por uma denuncia invalida recente.")
		return
	end
	
	setPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_REPORT, os.time())
	
	pvpBattleground.sendPlayerChannelMessage(cid, "Você denunciou o jogador " .. getPlayerName(idle_player) .. " como inativo com! Ele será expulso da Battleground se continuar inativo no proximo minuto.")
	doPlayerPopupFYI(idle_player, "ATENÇÃO: \n\nVocê foi acusado de estar inativo dentro da Battleground, o que é proibido!\nVocê tem " .. BG_AFK_TIME_LIMIT .. " segundos para entrar em combate com um oponente ou será expulso da batalha e marcado como desertor!")
	addEvent(pvpBattleground.validateReport, 1000 * BG_AFK_TIME_LIMIT, cid, idle_player)
end

function pvpBattleground.validateReport(cid, idle_player)

	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		return
	end

	if(not isPlayer(idle_player) or not isPlayer(cid)) then
		return
	end
	
	if(not doPlayerIsInBattleground(idle_player)) then
		return
	end

	local lastDmg = getPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_DAMAGE) 
	local reportIn = getPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_REPORT)
	if(lastDmg == 0 or lastDmg <= reportIn) then		
		pvpBattleground.onExit(idle_player, true)
	else
		setPlayerStorageValue(cid, sid.BATTLEGROUND_INVALID_REPORT_BLOCK, os.time() + (60 * 3))
		pvpBattleground.sendPlayerChannelMessage(cid, "Não foi constatado que o jogador que você reportou estava inativo. Pela denuncia invalida você nao poderá denunciar outros jogadores por 3 minutos.")
	end
end

--[[
	BANS AREA
]]--

function pvpBattleground.doPlayerIsBanned(cid)
	local result = db.getResult("SELECT `id`, `type`, `value`, `added`, `ends`, `reason`, `by` FROM `battleground_bans` WHERE ((`value` = " .. getPlayerGUID(cid) .. ") OR (`account_id` = " .. getPlayerAccountId(cid) .. " AND `type` = " .. BATTLEGROUND_BAN_TYPE_ACCOUNT .. ")) AND (`ends` = -1 OR `ends` >= " .. os.time() .. ") AND `active` = 1 ORDER BY `added` DESC LIMIT 1;")
	
	local banned, data = false, {}
	
	if(result:getID() ~= -1) then
		banned = true
		
		data["type"] = result:getDataInt("type")
		data["added"] = result:getDataInt("added")
		data["ends"] = result:getDataInt("ends")
		data["reason"] = result:getDataString("reason")
		data["by"] = result:getDataInt("by")
	end
	
	return banned, data
end

function pvpBattleground.getAccountBans(account_id)
	local result = db.getResult("SELECT `id`, `type`, `value`, `added`, `ends`, `reason`, `by` FROM `battleground_bans` WHERE `account_id` = " .. account_id .. " AND `active` = 1 ORDER BY `added` DESC;")
	
	local bans = {}
	
	if(result:getID() ~= -1) then
		repeat
			table.insert(bans, {id = result:getDataInt("id"), type = result:getDataInt("type"), value = result:getDataInt("value"), added = result:getDataInt("added"), ends = result:getDataInt("ends"), reason = result:getDataString("reason"), by = result:getDataInt("by")})
		until not(result:next())
		
		result:free()
	end
	
	return bans
end

function pvpBattleground.addPlayerBan(account_id, value, type, reason, by)
	
	local bans = pvpBattleground.getAccountBans(account_id)
	
	local BAN_RULES = {
		{count = 1, period = 60 * 60 * 24 * 7, resetRating = false}
		,{count = 2, period = 60 * 60 * 24 * 15, resetRating = true}
		,{count = 3, period = 60 * 60 * 24 * 30, resetRating = true}
		,{period = -1, resetRating = true}
	}
	
	local playerbans = 1
	if(#bans > 0) then
		playerbans = playerbans + #bans
	end
	
	local banArgs = nil
	
	for k,v in ipairs(BAN_RULES) do
		if(not v.count or v.count >= playerbans) then
			banArgs = v
			break
		end
	end
	
	local ends = BATTLEGROUND_BAN_ENDS_NEVER
	if(banArgs.period ~= BATTLEGROUND_BAN_ENDS_NEVER) then
		ends = banArgs.period + os.time()
	end
	
	db.executeQuery("INSERT INTO `battleground_bans` (`type`, `account_id`, `value`, `added`, `ends`, `reason`, `by`) VALUES (" .. type .. ", " .. account_id .. ", " .. value .. ", " .. os.time() .. ", " .. ends .. ", '" .. reason .. "', " .. getPlayerGUID(by) .. ");")

	local pid = getPlayerByGUID(value)
	if(pid) then
		if(doPlayerIsInBattleground(pid)) then
			pvpBattleground.onExit(pid)
		end
		
		pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(pid).. " (" .. getPlayerLevel(pid) .. ") foi banido da battleground por quebrar as regras! Leia as regras e não as quebre -> !bg regras", PVPCHANNEL_MSGMODE_BROADCAST)		
	end
	
	if(banArgs.resetRating) then
		if(pid) then
			doPlayerSetBattlegroundRating(pid, 0)
		else
			db.executeQuery("UPDATE `players` SET `battleground_rating` = 0 WHERE `id` = " .. value .. ";")
		end
	end
	
end

--[[
	MISC AREA
]]--

function pvpBattleground.spamDebuffSpell(cid, min, max, playerDebbufs)

	if(doPlayerIsInBattleground(cid)) then
		if(playerDebbufs[cid] == nil) then
			table.insert(playerDebbufs, cid, { percent = 70, expires = os.time() + 3})
		else	
			if(os.time() <= playerDebbufs[cid]["expires"]) then
				min = min * (playerDebbufs[cid]["percent"] / 100)
				max = max * (playerDebbufs[cid]["percent"] / 100)
				
				if(playerDebbufs[cid]["percent"] == 70) then
					playerDebbufs[cid]["percent"] = 50
				end
				
				playerDebbufs[cid]["expires"] = os.time() + 3
			else
				playerDebbufs[cid]["percent"] = 70
				playerDebbufs[cid]["expires"] = os.time() + 3	
			end
		end
	end
	
	return min, max, playerDebbufs
end

--[[
	TOOLS
]]

function doPlayerIsInBattleground(cid) return getPlayerBattlegroundTeam(cid) > 0 end
function isBattlegroundEnemies(cid, target) return getPlayerBattlegroundTeam(cid) ~= getPlayerBattlegroundTeam(target) end
function getPlayerBattlegroundEnemies(cid) return (getPlayerBattlegroundTeam(cid) == BATTLEGROUND_TEAM_ONE) and BATTLEGROUND_TEAM_TWO or BATTLEGROUND_TEAM_ONE end
function doPlayerIsFlagCarrier(cid) return hasCondition(cid, CONDITION_BATTLEGROUND_FLAG, -1) end
	
