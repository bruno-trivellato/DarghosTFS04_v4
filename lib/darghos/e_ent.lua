ancientNatureDied = {}
ancientNatureExpRewards = {
	[1] = 2500000
	,[2] = 1500000
	,[3] = 1000000
}

ancientWalls = {{x = 1833, y = 1790, z = 7}, {x = 1834, y = 1790, z = 7}, {x = 1835, y = 1790, z = 7}, {x = 1836, y = 1790, z = 7}}
ancientWallId = 1547

ancientTpIn = {x = 1834, y = 1792, z = 7}
ancientTpOut = {x = 2003, y = 1861, z = 7}

function ancientNaturePortal(cid, item, position, fromPosition)
	if(item.actionid == aid.ENT_ENTRANCE) then
		if(getStorage(gid.EVENT_ENT) == EVENT_STATE_INIT) then
			doPlayerEnterAncientNature(cid)
		else
			doPlayerSendCancel(cid, "O evento da Ancient Nature só está disponível terça as 15:00, 18:00 e 23:00.")
			pushBack(cid, position, fromPosition)
			return false
		end
	end

	if(item.actionid == aid.ENT_LEAVE) then
		doPlayerLeaveAncientNature(cid)
	end	

	return true
end

function doPlayerEnterAncientNature(cid)
	setPlayerStorageValue(cid, sid.ENT_INSIDE, 1)

	local players = tonumber(getStorage(gid.EVENT_ENT_PLAYERS))
	doSetStorage(gid.EVENT_ENT_PLAYERS, players + 1)

	setPlayerStorageValue(cid, sid.ENT_PARTICIPATION, 1)

	doBroadcastMessage(players + 1 .. " players joined to Ancient Nature event.", MESSAGE_EVENT_DEFAULT)
end

function doPlayerLeaveAncientNature(cid)
	setPlayerStorageValue(cid, sid.ENT_INSIDE, -1)
end

function openAncientNatureEvent()
	for k,v in pairs(ancientWalls) do
		local item = getTileItemById(v, ancientWallId)
		if(item.uid ~= 0) then
			doRemoveItem(item.uid)
		end
	end

	doSetStorage(gid.EVENT_ENT, EVENT_STATE_END)
end

function summonAncientNature()
	
	doSetStorage(gid.EVENT_ENT_PLAYERS, 0)
	doSetStorage(gid.EVENT_ENT, EVENT_STATE_INIT)

	local summonPos = {x = 1834, y = 1792, z = 7}

	local creature = doSummonCreature("ent", summonPos, true, true)
	registerCreatureEvent(creature, "monsterDeath")

	for k,v in pairs(ancientWalls) do
		local item = getTileItemById(v, ancientWallId)
		if(item.uid == 0) then
			doCreateItem(ancientWallId, v)
		end
	end	
end

function doPlayerCombatAncientNature(cid, target)

	local player = nil
	if(isPlayer(cid) == TRUE) then
		player = cid
	elseif(isPlayer(getCreatureMaster(cid)) == TRUE) then
		player = getCreatureMaster(cid)
	end	

	if getPlayerStorageValue(player, sid.ENT_INSIDE) ~= 1 then
		return true
	end	

	local player_target = nil
	if(isPlayer(target) == TRUE) then
		player_target = target
	elseif(isPlayer(getCreatureMaster(target)) == TRUE) then
		player_target = getCreatureMaster(target)
	end	

	if isPlayer(player_target) then
		return false
	end

	return true
end

function doPlayerDieOnAncientNature(cid)

	if getPlayerStorageValue(cid, sid.ENT_INSIDE) ~= 1 then
		return false
	end

	local currentPlayersIn = tonumber(getStorage(gid.EVENT_ENT_PLAYERS))
	local newPlayersIn = currentPlayersIn - 1

	ancientNatureDied[currentPlayersIn] = getPlayerGUID(cid)
	doSetStorage(gid.EVENT_ENT_PLAYERS, newPlayersIn)

	if newPlayersIn == 0 then
		doBroadcastMessage(getPlayerName(cid) .. " has been defeated at Ancient Nature event. No one remains on the fight!", MESSAGE_EVENT_DEFAULT)
	else
		doBroadcastMessage(getPlayerName(cid) .. " has been defeated at Ancient Nature event. " .. newPlayersIn .. " players still remains on the fight!", MESSAGE_EVENT_DEFAULT)
	end

	if newPlayersIn == 0 then

		local w1 = getPlayerByGUID(ancientNatureDied[1])
		local w2 = getPlayerByGUID(ancientNatureDied[2])
		local w3 = getPlayerByGUID(ancientNatureDied[3])

		local text = "The players was not able to defeat Ancient Nature this time. The last three survivors are the winners:\n"

		doPlayerAddExperience(w1, ancientNatureExpRewards[1])
		text = text .. "1st (" .. getPlayerName(w1) .. ", " .. ancientNatureExpRewards[1] .. " exp)"

		if w2 ~= nil then
			doPlayerAddExperience(w2, ancientNatureExpRewards[2])
			text = text .. "\n2st (" .. getPlayerName(w2) .. ", " .. ancientNatureExpRewards[2] .. " exp)"
		end

		if w3 ~= nil then
			doPlayerAddExperience(w3, ancientNatureExpRewards[3])
			text = text .. "\n3st (" .. getPlayerName(w3) .. ", " .. ancientNatureExpRewards[3] .. " exp)"
		end		

		doBroadcastMessage(text, MESSAGE_EVENT_DEFAULT)

		local boss = getCreatureByName("ancient nature")
		if(boss) then
			doRemoveCreature(boss)
		end
		
		ancientNatureDied = {}
	end


	doPlayerLeaveAncientNature(cid)
	luaDeath(cid)

	return true
end

function onAncientNatureDie(cid, corpse, deathList)
	local msg = "Acient Nature has been defeated. All players still alive on the event are rewarded with " .. ancientNatureExpRewards[1] .. " exp."
	
	doBroadcastMessage(msg, MESSAGE_EVENT_ADVANCE)
	
	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.ENT_INSIDE) == 1 then
			doPlayerAddExperience(uid, ancientNatureExpRewards[1])
		end
	end

	ancientNatureDied = {}

	local tp = doCreateTeleport(1387, ancientTpOut, ancientTpIn)
	doItemSetActionId(tp, aid.ENT_LEAVE)

	addEvent(ancientNatureClear, 1000 * 30)
	-- we should create a task to remove players from the event after some minutes
end

function ancientNatureClear()

	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.ENT_INSIDE) == 1 then
			doPlayerLeaveAncientNature(uid)
			doTeleportThing(uid, getTownTemplePosition(getPlayerTown(uid)))
		end
	end

	local tp = getTileItemById(ancientTpIn, 1387)
	if(tp.uid ~= 0) then
		doRemoveItem(tp.uid)
	end
end