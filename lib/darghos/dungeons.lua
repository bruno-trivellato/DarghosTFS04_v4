HELL_POS = {x=2777, y=1367, z=13, stackpos=253}

GID_PLAYERS_IN_DUNGEON = 1
GID_LAST_BEGIN = 2
GID_LAST_END = 3

UID_DUNGEON_RESPAWN = 1

DUNGEON_THINK_INTERVAL = 1000 * 60

DUNGEON_NONE = 0

dungeonPlayerData = {
	[gid.DUNGEONS_ARIADNE_GHAZRAN] = {
		
	}
}

dungeonList =
{	
	[gid.DUNGEONS_ARIADNE_GHAZRAN] =
	{
		maxPlayers = 6
		,onPlayerEndLockTime = 60 * 60 * 24
		,onEndLockTime = 60 --seconds
		,maxTimeIn = 60 -- minutes
		,requiredItems = { {name = "obsidian knife"} }
		,onEnterEvent = function (cid)
			local mapMarks = uid.MM_GHAZRAN_TOTEMS
			
			for k,v in pairs(mapMarks) do
				
				local storage = sid.ARIADNE_TOTEMS[k]
				local pos = getThingPosition(v)
				if(getPlayerStorageValue(cid, storage) == 1) then
					doPlayerAddMapMark(cid, pos, MAPMARK_TICK)
				else
					doPlayerAddMapMark(cid, pos, MAPMARK_EXCLAMATION)
				end
			end
		end
		,onAttempEvent = function (cid)
			local attemps = getPlayerStorageValue(cid, sid.ARIADNE_TROLLS_WING_TODAY_ATTEMPS)
			attemps = (attemps > 0) and attemps + 1 or 1
			setPlayerStorageValue(cid, sid.ARIADNE_TROLLS_WING_TODAY_ATTEMPS, attemps)
			
			playerHistory.logDungAriadneTrollsAttemp(cid)
			setPlayerStorageValue(cid, ARIADNE_TROLLS_WING_ATTEMP_DEATHS, 0)
		end
		,onDeathEvent = function (cid)
			local attemps = getPlayerStorageValue(cid, ARIADNE_TROLLS_WING_ATTEMP_DEATHS)
			attemps = (attemps > 0) and attemps + 1 or 1
			setPlayerStorageValue(cid, ARIADNE_TROLLS_WING_ATTEMP_DEATHS, attemps)			
		end
	}	
}

DUNGEON_STATUS_NONE = 0
DUNGEON_STATUS_IN = 1
DUNGEON_STATUS_OUT = 2

dungeonEntranceUids =
{
	gid.DUNGEONS_ARIADNE_GHAZRAN
}

Dungeons = {
	--_singleton = nil
}	

-- Construtor nao necessario?! Talvez nao...
--function Dungeons:New(o)

--	local o = o or {}
--	setmetatable(o, self)
--	self.__index = self
--	return o
--end
	
function Dungeons.onPlayerEnter(cid, item, position)

	local dungeonId = item.actionid
	local dungeonInfo = dungeonList[dungeonId]
	
	local canEnter = ((getPlayerStorageValue(cid, dungeonId) == -1 or tonumber(getPlayerStorageValue(cid, dungeonId)) + dungeonInfo.onPlayerEndLockTime <= os.time()) and true or false)
	
	-- Verificamos se o Player jÃ¡ fez a Dungeon no dia
	if not(canEnter) then
		doPlayerSendCancel(cid, "Você já concluiu está dungeon hoje. Não pode passar novamente por aqui novamente por enquanto...")
		Dungeons.doTeleportPlayerBack(cid, position)
		
		return false
	end

	if not isInParty(cid) then
		doPlayerSendCancel(cid, "Para entrar em uma Dungeon você deve estar em party.")
		Dungeons.doTeleportPlayerBack(cid, position)
		
		return false
	end
	
	if not Dungeons.isFree(dungeonId) and getPlayerParty(cid) ~= Dungeons.getLeader(dungeonId) then
		doPlayerSendCancel(cid, "Esta Dungeon já esta oculpada por outros jogadores.")
		Dungeons.doTeleportPlayerBack(cid, position)
		
		return false
	end
	
	if Dungeons.isFree(dungeonId) and getPlayerParty(cid) ~= cid then
		doPlayerSendCancel(cid, "Somente lideres de uma party podem iniciar uma nova Dungeon.")
		Dungeons.doTeleportPlayerBack(cid, position)

		return false
	end
	
	if Dungeons.isFree(dungeonId) and #getPartyMembers(cid) ~= dungeonInfo.maxPlayers then
		doPlayerSendCancel(cid, "A sua party precisa possuir " .. dungeonInfo.maxPlayers .. " jogadores.")
		Dungeons.doTeleportPlayerBack(cid, position)

		return false
	end	
	
	if(Dungeons.isFree(dungeonId) and Dungeons.getLockedMinutes(dungeonId) > 0)then
		doPlayerSendCancel(cid, "Esta dungeon foi encerrada a pouco tempo, é necessario aguardar " .. Dungeons.getLockedMinutes(dungeonId) .. " minutos para que um novo time possa entrar...")
		Dungeons.doTeleportPlayerBack(cid, position)
		
		return false
	end
	
	if(dungeonInfo.requiredItems) then
		local foundAll = true
		local itemsString = ""
		local last = dungeonInfo.requiredItems[#dungeonInfo.requiredItems].name
		
		for k, itemType in pairs(dungeonInfo.requiredItems) do
			local itemId = getItemIdByName(itemType.name)
			local requireCount = itemType.count or 1
			if(getPlayerItemCount(cid, itemId) < requireCount) then
				itemsString = itemsString .. requireCount .. "x " .. itemType.name
				
				if(k == #dungeonInfo.requiredItems) then
					itemsString = itemsString .. "."
				else
					itemsString = itemsString .. ", "
				end
				
				foundAll = false
			end
		end
		
		if(not foundAll) then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Para você entrar nesta Dungeon e necessário possuir com você os seguinte(s) item(s): " .. itemsString)
			Dungeons.doTeleportPlayerBack(cid, position)
			
			return false
		end
	end
	
	-- Verificamos se hÃƒÂ¡ espaÃƒÂ§o na Dungeon
	if(Dungeons.getPlayersIn(dungeonId) == dungeonInfo.maxPlayers) then
		doPlayerSendCancel(cid, "Esta Dungeon já está com o numero maximo de jogadores a tentar realiza-la...")
		Dungeons.doTeleportPlayerBack(cid, position)
		
		return false
	end
	
	-- Daqui em diante dispararemos eventos que irao configurar o jogador dentro da dungeon
	
	-- Incrementamos o numero de jogadores na dungeon
	Dungeons.increasePlayers(dungeonId)
	
	-- Informamos em storage values que o jogador estÃƒÂ¡ em uma dungeon e em qual dungeon ele estÃƒÂ¡
	setPlayerDungeonId(cid, dungeonId)
	setPlayerDungeonStatus(cid, DUNGEON_STATUS_IN)
	
	-- Transportamos o jogador para dentro da dungeon
	Dungeons.doTeleportPlayer(cid, position)

	if Dungeons.isFree(dungeonId) then
		
		Dungeons.setLastBegin(dungeonId)
		Dungeons.setLeader(dungeonId, cid)
		Dungeons.onThink(dungeonId, 0)

		local members = getPartyMembers(cid)
		for _, _cid in pairs(members) do
			if(getPlayerGUID(cid) ~= getPlayerGUID(_cid)) then
				setPlayerDungeonId(_cid, dungeonId)
				setPlayerDungeonStatus(_cid, DUNGEON_STATUS_OUT)
			end
			
			if(dungeonInfo.onAttempEvent ~= nil) then
				dungeonInfo.onAttempEvent(_cid)
			end
		end
		
		-- Atualizamos a descriÃƒÂ§ÃƒÂ£o da entrada (o teleport)
		Dungeons.updateEntranceDescription(dungeonId, dungeonInfo.maxTimeIn)		
	end
	
	if(dungeonInfo.onEnterEvent ~= nil) then
		dungeonInfo.onEnterEvent(cid)
	end
	
	return true	
end

function Dungeons.increasePlayers(dungeonId)

	setGlobalStorageValue(dungeonId + GID_PLAYERS_IN_DUNGEON, Dungeons.getPlayersIn(dungeonId ) + 1)
end

function Dungeons.decreasePlayers(dungeonId)

	setGlobalStorageValue(dungeonId + GID_PLAYERS_IN_DUNGEON, Dungeons.getPlayersIn(dungeonId) - 1)
end

function Dungeons.getPlayersIn(dungeonId)
	
	local playersOnDungeon = getGlobalStorageValue(dungeonId + GID_PLAYERS_IN_DUNGEON) == -1 and 0 or getGlobalStorageValue(dungeonId + GID_PLAYERS_IN_DUNGEON)
	return playersOnDungeon
end

function Dungeons.setLastBegin(dungeonId, begin)
	begin = begin or os.time()
	setGlobalStorageValue(dungeonId + GID_LAST_BEGIN, begin)
end

function Dungeons.getLastBegin(dungeonId)
	return tonumber(getGlobalStorageValue(dungeonId + GID_LAST_BEGIN)) or 0
end

function Dungeons.setLastEnd(dungeonId, ending)
	ending = ending or os.time()
	setGlobalStorageValue(dungeonId + GID_LAST_END, ending)
end

function Dungeons.getLastEnd(dungeonId)
	return tonumber(getGlobalStorageValue(dungeonId + GID_LAST_END)) or 0
end

function Dungeons.getLockedMinutes(dungeonId)
	local availableIn = Dungeons.getLastEnd(dungeonId) + dungeonList[dungeonId].onEndLockTime
	if(availableIn > os.time()) then
		return math.floor((availableIn - os.time()) / 60)
	else
		return 0
	end
end

function Dungeons.isFree(dungeonId)
	return tonumber(getGlobalStorageValue(dungeonId)) == -1
end

function Dungeons.getLeader(dungeonId)
	return getPlayerByGUID(getGlobalStorageValue(dungeonId))
end

function Dungeons.setLeader(dungeonId, cid)
	setGlobalStorageValue(dungeonId, getPlayerGUID(cid))
end

function Dungeons.ereaseLeader(dungeonId)
	setGlobalStorageValue(dungeonId, -1)
end

function Dungeons.resetPlayersIn(dungeonId, reset)

	reset = reset or false

	setGlobalStorageValue(dungeonId + GID_PLAYERS_IN_DUNGEON, 0)
	Dungeons.ereaseLeader(dungeonId)
	
	if(not reset) then
		Dungeons.setLastEnd(dungeonId)
		
		local clearMonsters = { "sen gan guard", "sen gan shaman", "sen gan hunter", "sen gan hydra", "swamp thing", "big ooze", "ghazran", "bone wall" }
		for _,name in pairs(clearMonsters) do
			
			local found = true
			repeat
				local c = getCreatureByName(name)
				if(not c) then
					found = false
				else
					doRemoveCreature(c)
				end		
				
			until(not found)
		end
		
		spawnCreaturesByName("sen gan guard")
		spawnCreaturesByName("sen gan shaman")
		spawnCreaturesByName("sen gan hunter")
		spawnCreaturesByName("sen gan hydra")
		spawnCreaturesByName("swamp thing")
		spawnCreaturesByName("big ooze")
		spawnCreaturesByName("bone wall")
	else
		Dungeons.setLastEnd(dungeonId, 0)
	end	
end

function Dungeons.doTeleportPlayer(cid, position)
	
	local playerLookTo = getPlayerLookDir(cid)
	local destPos = {}
	
	if(playerLookTo == NORTH) then
		destPos = {x = position.x, y = position.y - 2, z = position.z, stackpos = 0}
	elseif(playerLookTo == SOUTH) then
		destPos = {x = position.x, y = position.y + 2, z = position.z, stackpos = 0}
	elseif(playerLookTo == EAST) then
		destPos = {x = position.x + 2, y = position.y, z = position.z, stackpos = 0}
	elseif(playerLookTo == WEST) then
		destPos = {x = position.x - 2, y = position.y, z = position.z, stackpos = 0}
	end
	
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
end

function Dungeons.doTeleportPlayerBack(cid, position)

	local playerLookTo = getPlayerLookDir(cid)
	local destPos = {}
	
	if(playerLookTo == NORTH) then
		destPos = {x = position.x, y = position.y + 1, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, SOUTH)
	elseif(playerLookTo == SOUTH) then
		destPos = {x = position.x, y = position.y - 1, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, NORTH)
	elseif(playerLookTo == EAST) then
		destPos = {x = position.x - 1, y = position.y, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, WEST)
	elseif(playerLookTo == WEST) then
		destPos = {x = position.x + 1, y = position.y, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, EAST)
	end
	
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
end

function Dungeons.onThink(dungeonId, runningTime, awayTime)
	
	if(dungeonId ~= -1) then
		local dungeonInfo = dungeonList[dungeonId]
		
		if(runningTime < dungeonInfo.maxTimeIn * DUNGEON_THINK_INTERVAL) then
		
			local leader = Dungeons.getLeader(dungeonId)
		
			if not leader or not isInParty(leader) then
				Dungeons.resetPlayersIn(dungeonId)
				Dungeons.updateEntranceDescription(dungeonId)
				
				return
			end
		
			Dungeons.updateEntranceDescription(dungeonId, dungeonInfo.maxTimeIn - (runningTime / DUNGEON_THINK_INTERVAL))
	
			if (runningTime / DUNGEON_THINK_INTERVAL) % 5 == 0 and isInParty(leader) then
			
				local leftTime = dungeonInfo.maxTimeIn - (runningTime / DUNGEON_THINK_INTERVAL)
				
				local members = getPartyMembers(leader)
				for _, cid in pairs(members) do
				
					if getPlayerDungeonId(cid) == dungeonId then
						doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Restam " .. leftTime .. " minutos para concluir a dungeon...")
					end
				end
			end
			
			if(Dungeons.getPlayersIn(dungeonId) == 0) then
				awayTime = awayTime + DUNGEON_THINK_INTERVAL
			else
				awayTime = 0
			end
			
			if(awayTime / DUNGEON_THINK_INTERVAL >= 5) then
				Dungeons.onAbandon(dungeonId)
				return
			end
			
			addEvent(Dungeons.onThink, DUNGEON_THINK_INTERVAL, dungeonId, runningTime + DUNGEON_THINK_INTERVAL, awayTime)		
		elseif(runningTime >= dungeonInfo.maxTimeIn  * DUNGEON_THINK_INTERVAL) then
			Dungeons.onTimeEnd(dungeonId)
		end
	end
end

function Dungeons.onAbandon(dungeonId)

	local leader = Dungeons.getLeader(dungeonId)
	local members = getPartyMembers(leader)
	
	for _, cid in pairs(members) do
	
		if getPlayerDungeonId(cid) == dungeonId then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você e toda sua party estiveram por mais de 5 minutos fora da Dungeon, e por isso, foi considerado que vocês a abandonaram.")
			
			setPlayerDungeonId(cid, DUNGEON_NONE)
			setPlayerDungeonStatus(cid, DUNGEON_STATUS_NONE)		
		end
	end	
	
	Dungeons.resetPlayersIn(dungeonId)
	Dungeons.updateEntranceDescription(dungeonId)
end

function Dungeons.onTimeEnd(dungeonId)

	local leader = Dungeons.getLeader(dungeonId)
	local members = getPartyMembers(leader)
	
	for _, cid in pairs(members) do
	
		if getPlayerDungeonId(cid) == dungeonId then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "O tempo para concluir esta dungeon acabou e você fracassou. Você e seus amigos precisarão ser mais rapidos da proxima vez!")
			
			if getPlayerDungeonStatus(cid) == DUNGEON_STATUS_IN then
				local dest = getPlayerMasterPos(cid)
				
				doTeleportThing(cid, dest)
				doSendMagicEffect(dest, CONST_ME_MAGIC_BLUE)
			end
			
			setPlayerDungeonId(cid, DUNGEON_NONE)
			setPlayerDungeonStatus(cid, DUNGEON_STATUS_NONE)		
		end
	end
	
	Dungeons.resetPlayersIn(dungeonId)
	Dungeons.updateEntranceDescription(dungeonId)
end

function Dungeons.onPlayerDeath(cid)

	if(not isPlayerInDungeon(cid)) then
		return
	end
	
	local dungeonId = getPlayerDungeonId(cid)
	
	if(getPlayerDungeonStatus(cid) ~= DUNGEON_STATUS_IN) then
		return
	end
	
	local dungeonInfo = dungeonList[dungeonId]
	if(dungeonInfo.onDeathEvent ~= nil) then
		dungeonInfo.onDeathEvent(cid)
	end		
	
	Dungeons.decreasePlayers(dungeonId)
	
	--local dest = getThingPosition(dungeonId + UID_DUNGEON_RESPAWN)
	
	--doTeleportThing(cid, dest)
	--doSendMagicEffect(dest, CONST_ME_MAGIC_BLUE)
	
	doCreatureAddHealth(cid, getCreatureMaxHealth(cid), nil, nil, true)
	doCreatureAddMana(cid, getCreatureMaxMana(cid), false)
	doRemoveConditions(cid, false)
	
	
	--doPlayerWearItems(cid, true)
	--setPlayerDungeonStatus(cid, DUNGEON_STATUS_OUT)
end

function Dungeons.onLogin(cid)

	if (isPlayerInDungeon(cid)) then
		setPlayerDungeonId(cid, DUNGEON_NONE)
		setPlayerDungeonStatus(cid, DUNGEON_STATUS_NONE)
		
		doTeleportThing(cid, getPlayerMasterPos(cid))
		
		--print("[Dungeons.onLogin] " .. getPlayerName(cid) .. " dungeon info cleaned.")
	end
end

function Dungeons.onServerStart()
	
	--configuraremos as descriÃ§Ãµes iniciais das portas das dungeons
	for key, dungeonId in pairs(dungeonEntranceUids) do
		
		if(getThing(dungeonId) ~= nil) then
			Dungeons.resetPlayersIn(dungeonId, true)
			Dungeons.updateEntranceDescription(dungeonId)	
		end
	end
end

function Dungeons.updateEntranceDescription(dungeonId, minutesLeft)
	
	if not Dungeons.isFree(dungeonId) then
		doItemSetAttribute(dungeonId, "description", "[Dungeon em andamento por " .. getPlayerName(Dungeons.getLeader(dungeonId)) .. " e sua party. Restam " .. minutesLeft .. " minutos para eles a terminarem.]")
	else
		doItemSetAttribute(dungeonId, "description", "[Dungeon disponivel, chame seus amigos para uma party e entre.]")
	end
end

function Dungeons.onPlayerLeave(cid)

	local dungeonId = getPlayerDungeonId(cid)
	
	setPlayerDungeonId(cid, DUNGEON_NONE)
	setPlayerDungeonStatus(cid, DUNGEON_STATUS_NONE)

	setPlayerStorageValue(cid, dungeonId, os.time())
	
	if(Dungeons.getPlayersIn(dungeonId) == 1) then
		Dungeons.resetPlayersIn(dungeonId)
		Dungeons.updateEntranceDescription(dungeonId)
	else
		Dungeons.decreasePlayers(dungeonId)	
	end
end

function Dungeons.onPartyPassLeadership(cid, target)

	local dungeonId = getPlayerDungeonId(cid)
	
	if(isPlayerInDungeon(cid) and Dungeons.getLeader(dungeonId) == cid) then
		Dungeons.setLeader(dungeonId, target)
		
		if(getPlayerDungeonStatus(cid) == DUNGEON_STATUS_NONE) then
			setPlayerDungeonId(cid, DUNGEON_NONE)
		end
	end
end

function Dungeons.onPartyLeave(cid)	
	if(getPlayerDungeonStatus(cid) == DUNGEON_STATUS_IN) then
		doPlayerSendCancel(cid, "Você não pode sair de uma party estando dentro de uma Dungeon.")
		return false
	elseif(getPlayerDungeonStatus(cid) == DUNGEON_STATUS_OUT) then
		setPlayerDungeonStatus(cid, DUNGEON_STATUS_NONE)
		setPlayerDungeonId(cid, DUNGEON_NONE)
	end
	
	return true
end

function Dungeons.onTeleportCity(cid)
	
	if(not isPlayerInDungeon(cid)) then
		doPlayerSendCancel(cid, "Para usar este comando é necessário que você esteja em alguma Dungeon.")
		return
	end
	
	if(getPlayerDungeonStatus(cid) == DUNGEON_STATUS_IN) then
		doPlayerSendCancel(cid, "Você não pode usar este comando estando no meio de uma Dungeon.")
		return
	end
	
	if(hasCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSendCancel(cid, "Você não pode usar este comando estando em combate.")
		return		
	end
	
	local dest = getPlayerMasterPos(cid)
	
	doTeleportThing(cid, dest)
	doSendMagicEffect(dest, CONST_ME_MAGIC_BLUE)
end

function Dungeons.onTeleportEntrance(cid)
	
	if(not isPlayerInDungeon(cid)) then
		doPlayerSendCancel(cid, "Para usar este comando é necessário que você esteja em alguma Dungeon.")
		return
	end
	
	if(hasCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSendCancel(cid, "Você não pode usar este comando estando em combate.")
		return		
	end
	
	local dest = getThingPosition(getPlayerDungeonId(cid) + UID_DUNGEON_RESPAWN)
	
	doTeleportThing(cid, dest)
	doSendMagicEffect(dest, CONST_ME_MAGIC_BLUE)
	
	if(getPlayerDungeonStatus(cid) == DUNGEON_STATUS_IN) then
		setPlayerDungeonStatus(cid, DUNGEON_STATUS_OUT)
		Dungeons.decreasePlayers(getPlayerDungeonId(cid))	
	end	
end

-- Player Tools

function isPlayerInDungeon(cid)
	return getPlayerDungeonId(cid) ~= DUNGEON_NONE
end