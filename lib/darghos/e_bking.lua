bking_enraged_notify = false
bking_locked_notify = false
bking_idle_ticks = 0

function bkingOnThink(cid, interval)

	local lifePercent = math.floor((getCreatureHealth(cid) * 100) / getCreatureMaxHealth(cid))

	local players = tonumber(getStorage(gid.EVENT_BKING_PLAYERS))

	if lifePercent <= 80 and not bking_locked_notify then
		doBroadcastMessage("A group of " .. players .. " brave players was on Behemoth King challange. The portal to the boss now is locked until the group get your destiny!", MESSAGE_TYPES["orange"])
		doSetStorage(gid.EVENT_BKING, EVENT_STATE_WAITING)

		bking_locked_notify = true
	end

	if lifePercent <= 10 and not bking_enraged_notify then
		doBroadcastMessage("The boss is with LESS THAN 10% of life! Behemoth King now go into his ENRAGED PHASE!", MESSAGE_TYPES["orange"])
		bking_enraged_notify = true
	end

	if bking_locked_notify then
		if players == 0 then
			bkingReset(cid)
		end

		local targets = getMonsterTargetList(cid)
		if #targets == 0 then
			bking_idle_ticks = bking_idle_ticks + 1000
		else
			bking_idle_ticks = 0
		end

		if bking_idle_ticks > 8000 then
			bkingReset(cid)
		end
	end

	return true
end

function bkingReset(cid)

	doCreatureAddHealth(cid, getCreatureMaxHealth(cid) - getCreatureHealth(cid), CONST_ME_MAGIC_BLUE)

	local list = getSpectators({x = 1995, y = 1820, z = 15}, 18, 18, false)
	for k,v in ipairs(list) do
	
		local player = nil
		if isPlayer(v) then
	        if(getPlayerGroupId(v) <= GROUPS_GAMEMASTER) then
	        	doPlayerLeaveBking(v)
				luaDeath(v)
	        end
		elseif isPlayer(getCreatureMaster(v)) and getPlayerGroupId(getCreatureMaster(v)) <= GROUPS_GAMEMASTER then
			doRemoveCreature(v)
		end	

		if isMonster(v) then
			if string.lower(getCreatureName(v)) == "behemoth" then
				doRemoveCreature(v)
			end
		end
	end

	doBroadcastMessage("The last group has been smashed by Behemoth King! Portal to the boss in Quendor depot is now open!", MESSAGE_TYPES["orange"])
	doSetStorage(gid.EVENT_BKING, EVENT_STATE_INIT)

	bking_locked_notify = false
	bking_enraged_notify = false
end

function bkingPortal(cid, item, position, fromPosition)
	if(item.actionid == aid.BKING_ENTRANCE) then
		local event = getStorage(gid.EVENT_BKING)
		if event == EVENT_STATE_INIT then
			doPlayerEnterBking(cid)
		elseif event == EVENT_STATE_WAITING then
			doPlayerSendCancel(cid, "An fight against Behemoth King is running! If current group fail the portal will be avialable again to a new attempt! Be ready!")
			pushBack(cid, position, fromPosition)		
			return false	
		else
			doPlayerSendCancel(cid, "O world boss Behemoth King so esta disponivel as Seg 23:00, Sex 15:00 e Sab 18:00.")
			pushBack(cid, position, fromPosition)
			return false
		end
	end

	if(item.actionid == aid.BKING_LEAVE) then
		doPlayerLeaveBking(cid)
	end

	return true
end

function doPlayerEnterBking(cid)
	setPlayerStorageValue(cid, sid.BKING_INSIDE, 1)

	local players = tonumber(getStorage(gid.EVENT_BKING_PLAYERS))
	doSetStorage(gid.EVENT_BKING_PLAYERS, players + 1)

	doBroadcastMessage(players + 1 .. " players joined to Behemoth King challenge.", MESSAGE_EVENT_DEFAULT)	
end

function doPlayerLeaveBking(cid, die)
	setPlayerStorageValue(cid, sid.BKING_INSIDE, -1)

	local players = tonumber(getStorage(gid.EVENT_BKING_PLAYERS))
	doSetStorage(gid.EVENT_BKING_PLAYERS, players - 1)

	doBroadcastMessage("A player left from Behemoth King challenge. " .. players - 1 .. " players still remains in the fight.", MESSAGE_EVENT_DEFAULT)	
end

function doPlayerDieOnBking(cid)

	if getPlayerStorageValue(cid, sid.BKING_INSIDE) ~= 1 then
		return false
	end

	doPlayerLeaveBking(cid)

	luaDeath(cid)
	return true
end

function summonBking()
	
	local summonPos = {x = 1996, y = 1821, z = 15}

	local creature = doSummonCreature("Behemoth King", summonPos, true, true)
	registerCreatureEvent(creature, "monsterDeath")
	registerCreatureEvent(creature, "bossThink")
	doSetStorage(gid.EVENT_BKING, EVENT_STATE_INIT)
	doSetStorage(gid.EVENT_BKING_PLAYERS, 0)
end

function onBkingDie(cid, corpse, deathList)
	local msg = "Behemoth King was defeated one more time by the Quendorians! As reward all players that helped in this will receive as bonus 15% increased exp until next week. Congratulations!"
	doBroadcastMessage(msg, MESSAGE_TYPES["orange"])

	doSetStorage(gid.EVENT_BKING, EVENT_STATE_END)
	
	-- TODO: apply a mark to all who are inside the event when the boss die that will apply the bonus exp	
	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.BKING_INSIDE) == 1 then
			if not playerHistory.hasAchievement(uid, PH_ACH_DEFEAT_BEHEMOTH_KING) then
				playerHistory.onAchiev(uid, PH_ACH_DEFEAT_BEHEMOTH_KING)
			end
			
			setPlayerStorageValue(uid, sid.SLAIN_BKING, os.time() + ((60 * 60 * 24 * 7) - (60 * 60 * (os.date("%H") - 16))))
			reloadExpStages(uid)
		end
	end
end