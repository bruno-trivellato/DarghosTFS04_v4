-- Arena configs

-- Consts
ARENA_LEVEL_GREENHORN = 1
ARENA_LEVEL_SCRAPPER = 2
ARENA_LEVEL_WARLORD = 3

ARENA_DURATION = 60 * 6

ArenaClear = {
	{from = { x = 1991, y = 1178 }, to = { x = 2042, y = 1187 }}
	,{from = { x = 1998, y = 1164 }, to = { x = 2035, y = 1173 }}
	,{from = { x = 2005, y = 1150 }, to = { x = 2028, y = 1159 }}
	,{from = { x = 2012, y = 1136 }, to = { x = 2021, y = 1145 }}
}

ArenaLevelDoors = {
	[ARENA_LEVEL_GREENHORN] = sid.ARENA_GREENHORN_DOOR
	,[ARENA_LEVEL_SCRAPPER] = sid.ARENA_SCRAPPER_DOOR
	,[ARENA_LEVEL_WARLORD] = sid.ARENA_WARLORD_DOOR
}

ArenaLevelStrings = {
	[ARENA_LEVEL_GREENHORN] = "greenhorn"
	,[ARENA_LEVEL_SCRAPPER] = "scrapper"
	,[ARENA_LEVEL_WARLORD] = "warlord"
}

ArenaBosses = {

	{ -- 1#
		[ARENA_LEVEL_GREENHORN] = "frostfur"
		,[ARENA_LEVEL_SCRAPPER] = "avalanche"
		,[ARENA_LEVEL_WARLORD] = "webster"
	},
	{ -- 2#
		[ARENA_LEVEL_GREENHORN] = "bloodpaw"
		,[ARENA_LEVEL_SCRAPPER] = "kreebosh the exile"
		,[ARENA_LEVEL_WARLORD] = "darakan the executioner"
	},
	{ -- 3#
		[ARENA_LEVEL_GREENHORN] = "bovinus"
		,[ARENA_LEVEL_SCRAPPER] = "the dark dancer"
		,[ARENA_LEVEL_WARLORD] = "norgle glacierbeard"
	},
	{ -- 4#
		[ARENA_LEVEL_GREENHORN] = "achad"
		,[ARENA_LEVEL_SCRAPPER] = "the hag"
		,[ARENA_LEVEL_WARLORD] = "the pit lord"
	},
	{ -- 5#
		[ARENA_LEVEL_GREENHORN] = "colerian the barbarian"
		,[ARENA_LEVEL_SCRAPPER] = "slim"
		,[ARENA_LEVEL_WARLORD] = "svoren the mad"
	},
	{ -- 6#
		[ARENA_LEVEL_GREENHORN] = "the hairy one"
		,[ARENA_LEVEL_SCRAPPER] = "grimgor guteater"
		,[ARENA_LEVEL_WARLORD] = "the masked marauder"
	},
	{ -- 7#
		[ARENA_LEVEL_GREENHORN] = "axeitus headbanger"
		,[ARENA_LEVEL_SCRAPPER] = "drasilla"
		,[ARENA_LEVEL_WARLORD] = "gnorre chyllson"
	},
	{ -- 8#
		[ARENA_LEVEL_GREENHORN] = "rocky"
		,[ARENA_LEVEL_SCRAPPER] = "spirit of earth"
		,[ARENA_LEVEL_WARLORD] = "fallen mooh'tah master ghar"
	},
	{ -- 9#
		[ARENA_LEVEL_GREENHORN] = "cursed gladiator"
		,[ARENA_LEVEL_SCRAPPER] = "spirit of water"
		,[ARENA_LEVEL_WARLORD] = "deathbringer"
	},
	{ -- 10#
		[ARENA_LEVEL_GREENHORN] = "orcus the cruel"
		,[ARENA_LEVEL_SCRAPPER] = "spirit of fire"
		,[ARENA_LEVEL_WARLORD] = "the obliverator"
	},
}

Arena = {
	FightEvent = nil
}

function Arena.onEnterTeleport(cid, item, position, fromPosition)
	
	if(item.actionid == aid.ARENA_TELEPORT) then
		local current = getPlayerStorageValue(cid, sid.CURRENT_ARENA)
		
		if(current == -1) then
			local arenaIsBusy = getStorage(gid.ARENA_PLAYER_INSIDE) ~= -1
			if(arenaIsBusy) then
				doPlayerSendCancel(cid, "Another person already are fighting in arena. Please, wait some time and try again later...")
				doTeleportThing(cid, fromPosition, false)
				doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)
				
				return false		
			end
			
			for k,v in pairs(ArenaClear) do
				for _x = v.from.x, v.to.x do
					for _y = v.from.y, v.to.y do
						doCleanTile({x = _x, y = _y, z = 7})
					end
				end
			end
			
			setPlayerStorageValue(cid, sid.CAN_ENTER_ARENA, -1)
			setPlayerStorageValue(cid, sid.CURRENT_ARENA, 1)
			doSetStorage(gid.ARENA_PLAYER_INSIDE, getPlayerGUID(cid))
		else
			setPlayerStorageValue(cid, sid.CURRENT_ARENA, current + 1)
		end
		
		Arena.onFight(cid)
	elseif(item.actionid == aid.ARENA_TELEPORT_EXIT) then
		
		Arena.onLeave(cid)
	elseif(item.actionid == aid.ARENA_TELEPORT_REWARD) then
	
		Arena.onLeave(cid, true)
	end
	
	return true
end

function Arena.onLeave(cid, won)
	
	won = won or false

	if(not won) then
		local current = getPlayerStorageValue(cid, sid.CURRENT_ARENA)
		local arenaLevel = getPlayerStorageValue(cid, sid.ARENA_LEVEL)
		
		if(current ~= -1 and arenaLevel ~= -1) then
			local bossName = ArenaBosses[current][arenaLevel]
			local boss = getCreatureByName(bossName)
			
			if(boss) then
				doRemoveCreature(boss)
			end
			
			setPlayerStorageValue(cid, sid.CURRENT_ARENA, -1)
			setPlayerStorageValue(cid, sid.CAN_ENTER_ARENA, -1)
			setPlayerStorageValue(cid, sid.ARENA_LEVEL, -1)	
		end		
	end
	
	doSetStorage(gid.ARENA_LAST_BATTLE_START, -1)
	
	if(Arena.FightEvent) then
		stopEvent(Arena.FightEvent)
		Arena.FightEvent = nil
	end	
	
	doSetStorage(gid.ARENA_PLAYER_INSIDE, -1)
end

function Arena.onFight(cid)
	
	local arenaLevel = getPlayerStorageValue(cid, sid.ARENA_LEVEL)
	local current = getPlayerStorageValue(cid, sid.CURRENT_ARENA)
	local bossName = ArenaBosses[current][arenaLevel]

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You already prepared for the next combat? I wait that yes! The next arena gladiator are the " .. bossName .. "! Good luck!")
	addEvent(doSummonCreature, 1000 * 5, bossName, getThingPosition(uid.ARENA.TELEPORTS[current]), true, true)
	registerCreatureEvent(cid, "onKill")
	registerCreatureEvent(cid, "onDeath")
	
	doSetStorage(gid.ARENA_LAST_BATTLE_START, os.time())
	
	if(Arena.FightEvent) then
		stopEvent(Arena.FightEvent)
	end
	
	Arena.FightEvent = addEvent(Arena.onFightTimeEnd, 1000 * ARENA_DURATION, cid)
end

function Arena.onFightTimeEnd(cid)
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Sorry, the time to you win the battle against the arena gladiator has end and you game is over! Try again later!")
	doTeleportThing(cid, getThingPosition(uid.ARENA_EXIT), false)
	doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_BLUE)
	Arena.onLeave(cid)
end

-- callback event for kill monster in arena
function Arena.onKill(cid, target)
	
	local arenaPlayer = getStorage(gid.ARENA_PLAYER_INSIDE)
	if(not isPlayer(cid) or arenaPlayer == -1 or arenaPlayer ~= getPlayerGUID(cid)) then
		return
	end
	
	local current = getPlayerStorageValue(cid, sid.CURRENT_ARENA)
	local arenaLevel = getPlayerStorageValue(cid, sid.ARENA_LEVEL)
	local bossName = ""
	
	if(ArenaBosses[current] ~= nil and ArenaBosses[current][arenaLevel] ~= nil) then
		bossName = ArenaBosses[current][arenaLevel]
	else
		std.clog("Cant find arena data for player " .. getPlayerName(cid) .. ", their data has been reseted, but check this issue. Arena: " .. current .. ", Level:" .. arenaLevel)
		setPlayerStorageValue(cid, sid.CURRENT_ARENA, -1)
		setPlayerStorageValue(cid, sid.ARENA_LEVEL, -1)
		return
	end
	
	local cName = string.lower(getCreatureName(target))
	
	if(bossName == cName) then
		
		local msg = "Congratulations!"
		
		local dest
		local _aid = aid.ARENA_TELEPORT
		
		if(current == 10)  then
			dest = getThingPosition(uid.ARENA_REWARD_ROOM)
			_aid = aid.ARENA_TELEPORT_REWARD
			
			-- if is needed, set correct storage to access the door of the reward room
			local doorStorage = getPlayerStorageValue(cid, ArenaLevelDoors[arenaLevel])
			if(doorStorage == -1) then
				setPlayerStorageValue(cid, ArenaLevelDoors[arenaLevel], 1)
			end
			
			msg = msg .. " You won all the 10 gladiators for " .. ArenaLevelStrings[arenaLevel] .. " arena! Go in magic portal and go to the north and choose one reward!"
		else
			dest = getThingPosition(uid.ARENA.ENTRANCES[current + 1])
			msg = msg .. " The " .. bossName .. " now know your power! Go in the magic portal when all are done to you face your next opponent!"
		end
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
		
		local tp = doCreateTeleport(1387, dest, getThingPosition(uid.ARENA.TELEPORTS[current]))
		doItemSetActionId(tp, _aid)
	end
end 

-- callback event for player death in arena
function Arena.onDeath(cid)
	
	local arenaPlayer = getStorage(gid.ARENA_PLAYER_INSIDE)
	if(not isPlayer(cid) or arenaPlayer == -1 or arenaPlayer ~= getPlayerGUID(cid)) then
		return
	end	
	
	Arena.onLeave(cid)
end