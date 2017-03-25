function bkingPortal(cid, item, position, fromPosition)
	if(item.actionid == aid.BKING_ENTRANCE) then
		if(getStorage(gid.EVENT_BKING) == EVENT_STATE_INIT) then
			doPlayerEnterBking(cid)
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
end

function doPlayerLeaveBking(cid)
	setPlayerStorageValue(cid, sid.BKING_INSIDE, -1)
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
	doSetStorage(gid.EVENT_BKING, EVENT_STATE_INIT)
end

function onBkingDie(cid, corpse, deathList)
	local msg = "Behemoth King was defeated one more time by the Quendorians! As reward all players that helped in this will receive as bonus 15% increased exp until next week. Congratulations!"
	doBroadcastMessage(msg, MESSAGE_EVENT_ADVANCE)

	doSetStorage(gid.EVENT_BKING, EVENT_STATE_END)
	
	-- TODO: apply a mark to all who are inside the event when the boss die that will apply the bonus exp	
	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.BKING_INSIDE) == 1 then
			setPlayerStorageValue(uid, sid.SLAIN_BKING, os.time() + ((60 * 60 * 24 * 7) - (60 * 60 * (os.date("%H") - 16))))
			reloadExpStages(uid)
		end
	end
end