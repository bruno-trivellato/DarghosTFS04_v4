local DARK_GENERAL_SUMMON_POS = {x = 1826, y = 1871, z = 7}

dark_general_antilure_ticks = 0

function darkGeneralOnThink(cid, interval)

	if getDistanceBetween(getCreaturePosition(cid), DARK_GENERAL_SUMMON_POS) > 16 then

		if dark_general_antilure_ticks == 0 then
			doBroadcastMessage("Dark General was taken too far away from his respawn. Back to the depot region or the boss will be reseted soon!", MESSAGE_TYPES["orange"])
		end

		dark_general_antilure_ticks = dark_general_antilure_ticks + interval

		if dark_general_antilure_ticks > 15000 then
			doCreatureSay(cid, "I WILL NOT FOLLOW YOU! FIGHT AND DIE HERE!", TALKTYPE_MONSTER_YELL)
			doCreatureAddHealth(cid, getCreatureMaxHealth(cid) - getCreatureHealth(cid), CONST_ME_MAGIC_BLUE)
			doTeleportThing(cid, DARK_GENERAL_SUMMON_POS)
		end
	else
		dark_general_antilure_ticks = 0
	end

	return true
end

function darkGeneralPortal(cid, item, position, fromPosition)
	if(item.actionid == aid.DARK_GENERAL_ENTRANCE) then
		if(getStorage(gid.EVENT_DARK_GENERAL) == EVENT_STATE_INIT) then
			doPlayerEnterDarkGeneral(cid)
		else
			doPlayerSendCancel(cid, "O evento do Dark General só está disponível aos Dom 15:00, Qua 18:00 e Qui 23:00.")
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

	local creature = doSummonCreature("Dark General", DARK_GENERAL_SUMMON_POS, true, true)
	registerCreatureEvent(creature, "monsterDeath")
	registerCreatureEvent(creature, "bossThink")
	registerCreatureEvent(creature, "onStateChange")
end

function onDarkGeneralDie(cid, corpse, deathList)
	local msg = "Com muita bravura os guerreiros retomaram a cidade de Quendor do invasor Dark General e suas tropas! Como recompensa, todos que ajudaram no combate receberam 15% mais expêriencia pela proxima semana."
	doBroadcastMessage(msg, MESSAGE_EVENT_ADVANCE)

	doSetStorage(gid.EVENT_DARK_GENERAL, EVENT_STATE_END)
	
	-- TODO: apply a mark to all who are inside the event when the boss die that will apply the bonus exp	
	local onlineList = getPlayersOnline()
	for _,uid in pairs(onlineList) do
		if getPlayerStorageValue(uid, sid.DARK_GENERAL_INSIDE) == 1 then
			if not playerHistory.hasAchievement(uid, PH_ACH_DEFEAT_DARK_GENERAL) then
				playerHistory.onAchiev(uid, PH_ACH_DEFEAT_DARK_GENERAL)
			end

			setPlayerStorageValue(uid, sid.SLAIN_DARK_GENERAL, os.time() + ((60 * 60 * 24 * 7) - (60 * 60 * (os.date("%H") - 16))))
			reloadExpStages(uid)
		end
	end
end