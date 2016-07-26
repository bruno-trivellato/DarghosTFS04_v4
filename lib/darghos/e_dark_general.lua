function darkGeneralPortal(cid, item, position, fromPosition)
	if(item.actionid == aid.DARK_GENERAL_ENTRANCE) then
		if(getStorage(gid.EVENT_DARK_GENERAL) == EVENT_STATE_INIT) then
			doPlayerEnterDarkGeneral(cid)
		else
			doPlayerSendCancel(cid, "O evento do Dark General só está disponível aos domingos a partir das 16:00.")
			pushBack(cid, position, fromPosition)
			return false
		end
	end

	if(item.actionid == aid.DARK_GENERAL_LEAVE) then
		doPlayerLeaveDarkGeneral(cid)
	end

	return true
end

function doPlayerEnterDarkGeneral(cid)
	setPlayerStorageValue(cid, sid.DARK_GENERAL_INSIDE, 1)
end

function doPlayerLeaveDarkGeneral(cid)
	setPlayerStorageValue(cid, sid.DARK_GENERAL_INSIDE, -1)
end

function doPlayerDieOnDarkGeneral(cid)

	if getPlayerStorageValue(cid, sid.DARK_GENERAL_INSIDE) ~= 1 then
		return false
	end

	doPlayerLeaveDarkGeneral(cid)

	luaDeath(cid)
	return true
end

function summonDarkGeneral()
	
	local summonPos = {x = 1825, y = 1879, z = 7}

	local creature = doSummonCreature("Dark General", summonPos, true, true)
	registerCreatureEvent(creature, "monsterDeath")
end

function onDarkGeneralDie(cid, corpse, deathList)
	local msg = "Com muita bravura os guerreiros retomaram a cidade de Quendor do invasor Dark General e suas tropas! Como recompensa, todos que ajudaram no combate receberam 15% mais expêriencia pela proxima semana."
	doBroadcastMessage(msg, MESSAGE_EVENT_ADVANCE)

	doSetStorage(gid.EVENT_DARK_GENERAL, EVENT_STATE_END)
	
	-- TODO: apply a mark to all who are inside the event when the boss die that will apply the bonus exp	
	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.DARK_GENERAL_INSIDE) == 1 then
			setPlayerStorageValue(uid, sid.SLAIN_DARK_GENERAL, os.time() + ((60 * 60 * 24 * 7) - (60 * 60 * (os.date("%H") - 16))))
			reloadExpStages(uid)
		end
	end
end