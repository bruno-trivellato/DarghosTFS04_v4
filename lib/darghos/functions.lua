function getWorldConfig(config)

	local value = world_config[getConfigValue("worldId")][config]
	if value == nil then
		std.clog("World config " .. config .. " not found.")
	end

	return value
end

function scriptBotCheckMoving(cid)
	if getPlayerStorageValue(cid, sid.SCRIPTBOT_RECORDING) == 1 then
		local pos = getPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS) ~= -1 and unpackPosition(getPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS)) or false

		if not pos or getDistanceBetween(getPlayerPosition(cid), pos) > 5 then
			setPlayerStorageValue(cid, sid.SCRIPTBOT_LAST_POS, packPosition(getPlayerPosition(cid)))
			botScriptMove(getPlayerPosition(cid))
		end
	end
end

function isInTunnel(cid)
	local player_ip_str = doConvertIntegerToIp(getPlayerIp(cid))
	if(player_ip_str == getConfigValue("ip")) then
		return true
	end
	
	return false
end

function doUpdateDBPlayerSkull(cid)

	local player_id = getPlayerGUID(cid)
	local skull, skullEnd = getCreatureSkull(cid), getPlayerSkullEnd(cid)
	
	local queryStr = "UPDATE `players` SET `skull` = " .. skull .. ", `skulltime` = " .. skullEnd .. " WHERE `id` = " .. player_id .. ";"
	db.executeQuery(queryStr)	
end

function getAccountExpBonus(cid)
	local account = getPlayerAccountId(cid)

	local data, result = {}, db.getResult("SELECT `exp`, `end`, `desc` FROM `wb_account_exp` WHERE `account_id` = " .. account .. " AND `end` > UNIX_TIMESTAMP();")
	if(result:getID() ~= -1) then
		repeat
			table.insert(data, {["exp"] = result:getDataInt("exp"), ["end"] = result:getDataInt("end"), ["desc"] = result:getDataString("desc")})
		until not(result:next())
		result:free()
	end	

	return data
end

function increasePremiumSpells(cid, min, max)
	--if(isPremium(cid)) then
	--	min = math.floor(min * 1.1)
	--	max = math.floor(max * 1.1)
	--end
	
	return min, max
end

function isPlayerMale(cid)
	return getPlayerSex(cid) == 1
end

function isPlayerFemale(cid)
	return not isPlayerMale(cid)
end

function getChangePvpPrice(cid)

	local level = getPlayerLevel(cid)
	
	local prices = {
		{ from = 100, to = 199, price = 4 } 	-- R$ 1,32
		,{ from = 200, to = 249, price = 10 } 	-- R$ 3,30
		,{ from = 250, to = 299, price = 20 } 	-- R$ 6,60
		,{ from = 300, to = 324, price = 30 } 	-- R$ 9,90
		,{ from = 325, to = 349, price = 40 } 	-- R$ 13,20
		,{ from = 350, to = 374, price = 55 } 	-- R$ 18,15
		,{ from = 375, to = 399, price = 75 } 	-- R$ 24,75
		,{ from = 400, to = 424, price = 100 } 	-- R$ 33,00
		,{ from = 425, to = 449, price = 140 } 	-- R$ 46,20
		,{ from = 450, to = 499, price = 200 } 	-- R$ 66,00
		,{ from = 500, to = 1000, price = 340 } -- R$ 112,00
	}
	
	for _,v in pairs(prices) do
		if((not v.from and level < v.to) or (level >= v.from and level <= v.to) or (level >= v.from and not v.to) ) then
			return v.price
		end
	end
	
	return 0
end

mcs = {}

mcs.list = {}
mcs.toDrop = 0

function mcs.buildList()

	local onlineList = getPlayersOnline()
	
	for i, uid in ipairs(onlineList) do
	
		if getPlayerGroupId(uid) == 8 then
			table.insert(mcs.list, uid)
		end
	end
	
	print("Mcs list builded with " .. #mcs.list .. " characters")
end

function mcs.dropOne()

	local stop = false
	
	print("Kicking one of " .. mcs.toDrop .. " mcs.")

	if(#mcs.list > 0) then
		local mc_pos = math.random(1, #mcs.list)
		
		if(isPlayer(mcs.list[mc_pos])) then
			print(getPlayerName(mcs.list[mc_pos]) .. " kicked.")
			doRemoveCreature(mcs.list[mc_pos])
			mcs.list[mc_pos] = nil
		else
			print("Creature at key  " .. mc_pos .. " is not a player!")
		end
	else
		stop = true
	end
	
	if(mcs.toDrop > 0) then
		if(mcs.toDrop == 1) then
			stop = true
		end
		
		mcs.toDrop = mcs.toDrop - 1
	end
	
	if(not stop) then
		addEvent(mcs.dropOne, 1000 * 60)
	end
end

function getMinMaxClassicFormula(level, maglevel, minFactor, maxFactor, _min, _max)
	
	local min = ((level / 3) + (maglevel / 2)) * minFactor
	local max = ((level / 3) + (maglevel / 2)) * maxFactor
	
	if(_min ~= nil and _min > min) then
		min = _min
		
		if(_max ~= nil and _max > max) then
			max = _max
		end
	end
	
	return min, max
end

function getPlayerBaseVocation(cid)

	if(isSorcerer(cid)) then
		return 1
	elseif(isDruid(cid)) then
		return 2
	elseif(isPaladin(cid)) then
		return 3
	elseif(isKnight(cid)) then
		return 4
	end
	
	return 0
end

function searchItemDepthContainer(container, itemlist, result, recursively)

	recursively = recursively or true
	
	if(not isContainer(container.uid)) then
		return false
	end
	
	local foundItems = {}
	
	function tryAddItemToResult(item, attributes, result)
		if(attributes.actionid ~= nil and item.aid ~= attributes.aid) then
			return false
		end
		
		table.insert(result, tmp)
		return true
	end
	
    for k = (getContainerSize(container.uid) - 1), 0, -1 do
        local tmp = getContainerItem(container.uid, k)
        
		local iList = itemlist[tmp.itemid]
        if (iList ~= nil) then
			tryAddItemToResult(item, iList, result)
        elseif (isContainer(tmp.uid) and recursively) then
        	searchItemDepthContainer(tmp, itemlist, result)
        end
    end	
	return true
end

function lookingOutfitTicket(cid, thing)

	local outfitId = thing.actionid or 0
	local outfitName = {
		[1] = "Citizen",
		[2] = "Hunter",
		[3] = "Mage",
		[4] = "Knight",
		[5] = "Noble",
		[6] = "Summoner",
		[7] = "Warrior",
		[8] = "Barbarian",
		[9] = "Druid",
		[10] = "Wizard",
		[11] = "Oriental",
		[12] = "Pirate",
		[13] = "Assassin",
		[14] = "Beggar",
		[15] = "Shaman",
		[16] = "Norse",
		[17] = "Nightmare",
		[18] = "Jester",
		[19] = "Brotherhood",
		[20] = "Demonhunter",
		[21] = "Yalaharian",
		[22] = "Warmaster",
		[23] = "Wayfarer"
	}

	local tempName = "Unkwnown"

	if(outfitName[outfitId] ~= nil) then
		tempName = outfitName[outfitId]
	end
	
	local desc = ""
	
	if(not canPlayerWearOutfitId(cid, outfitId, 0)) then
		desc = "Use este bilhete para ganhar o outfit " .. tempName .. "."
	else
		if(canPlayerWearOutfitId(cid, outfitId, 2)) then
			desc = "Você já possui todos addons para o outfit" .. tempName .. ". Mas outras pessoas ainda podem usar-lo."
		elseif(canPlayerWearOutfitId(cid, outfitId, 1)) then
			desc = "Use este bilhete para ganhar o segundo addon para o outfit " .. tempName .. "."
		else
			desc = "Use este bilhete para ganhar o primeiro addon  para o outfit " .. tempName .. "."
		end		
	end	

	doItemSetAttribute(thing.uid, "name", string.lower(tempName) .. " outfit ticket")
	doItemSetAttribute(thing.uid, "description", desc)
end

function enableRoyalBlessing(msg, class)
	doSetStorage(gid.ROYAL_BLESSING, 1)

	msg = msg or "Rei Ordon anúncia: Por Quendor está concedida a BENÇÃO REAL a todos durante esta ameaça! Lutem por Quendor sem medo!"
	class = class or MESSAGE_EVENT_ADVANCE
	doBroadcastMessage(msg, class)
end

function disableRoyalBlessing(msg, class)
	doSetStorage(gid.ROYAL_BLESSING, 0)

	msg = msg or "Rei Ordon: Não há mais ameaça, a benção real está ENCERRADA!"
	if(msg) then
		class = class or MESSAGE_EVENT_ADVANCE
		doBroadcastMessage(msg, class)
	end
end

function doRoyalBlessIsEnable()
	return getStorage(gid.ROYAL_BLESSING) == 1
end

function getHelpMessage(command, paramTable)
	local str = "Instruções de uso:\n"
	str = str .. "Ex: " .. command .. " [arg1] | [arg2] ... \n"
	str = str .. "\nArgumentos: \n"
	for k,v in pairs(paramTable) do
		str = str .. v.key .. " --> " .. v.help .. "\n"
	end
	
	return str
end

function parseTalkactionParameters(paramTable, str, separator)
	separator = separator or "|"
	
	local params = string.explode(str, separator)
	
	if(#params == 0) then
		params = { str }
	end
	
	local nextProperties = nil
	
	for _, param in pairs(params) do
		
		param = string.trim(param)		
		local result = string.explode(param, " ", 1)
	
		local _key = result[1]
		local _value = result[2]
		
		if(_key == "-h") then
			return TALK_PARAMS_CALL_HELP, ""
		end
		
		local knowKey = false
		
		for key, props in pairs(paramTable) do
			if(_key == props.key) then
				
				knowKey = true
				
				local expectType = "string" 
				
				if(props.expectedType == nil) then
					props.expectedType = expectType
				end
				
				if(props.expectedValues ~= nil and not isInArray(props.expectedValues, _value)) then
					return TALK_PARAMS_WRONG_EXPECTED_VALUE, "Valor incorreto para o argumento " .. v .. ", era esperado um de: " .. table.implode(", ", props.expectedValues) .. "."
				end
				
				if(props.expectedType == "string") then
					paramTable[key].value = _value
				elseif(props.expectedType == "numeric") then
					paramTable[key].value = tonumber(_value)
				end
			end
		end
		
		if(not knowKey) then
			return TALK_PARAMS_WRONG_PARAMETER, "O parametro " .. _key .. " não é valido. Use o -h para ajuda."
		end
	end
	
	return TALK_PARAMS_DONE, paramTable
end

function getPlayerAccountIdByName(name)
	local result = db.getResult("SELECT `account_id` FROM `players` WHERE `name` = " .. db.escapeString(name) .. " LIMIT 1;")
	
	if(result:getID() == -1) then
		return false
	end
	
	local account_id = result:getDataInt("account_id")
	result:free()
	
	return account_id
end

function isOnContainer(position)
	if(position.x == CONTAINER_POSITION) then
		return true
	end
	
	return false
end

function isOnSlot(position)

	if(not isOnContainer(position)) then
		return false
	end

	if(getBooleanFromString(bit.uband(position.y, 64))) then
		return false
	end
	
	return true
end

function isOnGround(position)

	if(not isOnContainer(position) and not isOnSlot(position)) then
		return true
	end
	
	return false
end

function round(number, decimals)
	decimals = decimals or 1
	local shift = 10 ^ decimals
	return math.floor(number * shift + 0.5) / shift
end

function getPlayerPVPBlessing(cid)
	local pvpBless = getConfigValue('useBlessingAsPvp')
	return getPlayerBlessing(cid, pvpBless) or false
end

function doPlayerSetPVPBlessing(cid)
	local pvpBless = getConfigValue('useBlessingAsPvp')
	return doPlayerAddBlessing(cid, pvpBless)
end

function doPlayerIsInArena(cid) return getPlayerStorageValue(cid, sid.ARENA_INSIDE) == 1 end

function incPlayerStorageValue(cid, storage, value)
	value = value or 1
	
	local sv = tonumber(getPlayerStorageValue(cid, storage))
	sv = (sv == -1) and value or sv + value
	
	setPlayerStorageValue(cid, storage, sv)
	return sv
end

function broadcastChannel(channelId, message, talktype)
	local users = getChannelUsers(channelId)
	talktype = talktype or TALKTYPE_TYPES["channel-white"]
	
	for k,v in pairs(users) do
		doPlayerSendChannelMessage(v, "", message, talktype, channelId)
	end
end

function customStaminaUpdate(cid)

	if(not isPlayer(cid)) then
		return
	end

	local event = getPlayerStorageValue(cid, sid.EVENT_STAMINA)
	local staminaNextUpdate = getPlayerStorageValue(cid, sid.STAMINA_NEXT_UPDATE)
	
	if(os.time() < staminaNextUpdate) then
		return
	end
		
	local bonusStamina = 40 * 60
	local maxStamina = 42 * 60
	
	local staminaMinutes = getPlayerStamina(cid)
	local newStamina = staminaMinutes + 1
	
	local highStaminaInterval = (60 * 10)
	local lowStaminaInterval = (60 * 3)
	
	if(isPremium(cid)) then
		highStaminaInterval = (60 * 7)
		lowStaminaInterval = (60 * 2)	
	end
	
	if(staminaMinutes >= maxStamina and event ~= -1) then
		return
	end
	
	local interval = nil
	
	if(newStamina >= bonusStamina) then		
		interval = highStaminaInterval
	else	
		interval = lowStaminaInterval
	end
	
	if(event ~= -1) then	
		doPlayerSetStamina(cid, newStamina)
		doSendAnimatedText(getPlayerPosition(cid), "STAMINA +1", TEXTCOLOR_PURPLE)
	end
	
	setPlayerStorageValue(cid, sid.STAMINA_NEXT_UPDATE, os.time() + interval)
	setPlayerStorageValue(cid, sid.EVENT_STAMINA, addEvent(customStaminaUpdate, 1000 * interval, cid))
end

function storePlayerOutfit(cid)
	local json = require("json")
	setPlayerStorageValue(cid, sid.OUTFIT, json.encode(getCreatureOutfit(cid)))
end

function restorePlayerOutfit(cid)
	local json = require("json")
	local data = getPlayerStorageValue(cid, sid.OUTFIT)
	
	if(data ~= -1) then
		doCreatureChangeOutfit(cid, json.decode(data))
	end
end

function packPosition(pos)
	local json = require("json")
	return json.encode(pos)
end

function unpackPosition(data)
	local json = require("json")
	return json.decode(data)
end

function lockChangeOutfit(cid)
	registerCreatureEvent(cid, "OnChangeOutfit")
	setPlayerStorageValue(cid, sid.CHANGE_OUTFIT_LOCK, 1)
end

function unlockChangeOutfit(cid)
	unregisterCreatureEvent(cid, "OnChangeOutfit")
	setPlayerStorageValue(cid, sid.CHANGE_OUTFIT_LOCK, -1)
end

function changeOutfitIsLocked(cid)
	return (getPlayerStorageValue(cid, sid.CHANGE_OUTFIT_LOCK) == 1) and true or false
end

function lockTeleportScroll(cid)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_LOCK, 1)
end

function unlockTeleportScroll(cid)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_LOCK, -1)
end

function teleportScrollIsLocked(cid)
	
	return (getPlayerStorageValue(cid, sid.TELEPORT_RUNE_LOCK) == 1) and true or false
end

function doPlayerRemoveBalance(cid, balance)

	local account = getPlayerAccountId(cid)
	local result = db.getResult("SELECT `balance` FROM `accounts` WHERE `id` = " .. account .. ";")

	if(result:getID() ~= -1) then
		local _balance = result:getDataInt("balance")
		result:free()
		
		if(_balance - balance < 0) then
			return false
		end

		db.executeQuery("UPDATE `accounts` SET `balance` = " .. _balance - balance .. " WHERE `id` = " .. account .. ";")
		return true
	end

	return false
end

function doLogItemShopUse(cid, log_id)

	if(not canUseShopItem(log_id)) then
		return false
	end

	db.executeQuery("INSERT INTO `wb_itemshop_use_log` (`log_id`, `player_id`, `date`) VALUES (" .. log_id .. ", " .. getPlayerGUID(cid) .. ", " .. os.time() .. ");")
	return true
end

function canUseShopItem(log_id)

	local result = db.getResult("SELECT COUNT(*) as `count` FROM `wb_itemshop_use_log` WHERE `log_id` = " .. log_id .. ";")

	if(result:getID() ~= -1) then
		local count = result:getDataInt("count")
		result:free()
		
		if(count == 0) then
			return true
		end
	end
	
	return false	
end

function doCreateRespawnArea(respawns, position, radius)

	local min_x, max_x = position.x - radius, position.x + radius
	local min_y, max_y = position.y - radius, position.y + radius
	
	for k,v in pairs(respawns) do
		for i = 1, v.count do
			local temp_pos = { z = position.z }
			temp_pos.x = math.random(min_x, max_x)
			temp_pos.y = math.random(min_y, max_y)
			
			doCreateMonster(v.name, temp_pos, true)
		end
	end
end

function restoreAddon(cid)

	local patch = getDataDir() .. "lib/darghos/addons.json"
	local file = io.open(patch, "r")
	local jsonStr = file:read("*all")
	
	local json = require("json")
	local data = json.decode(jsonStr)
	
	local player_id = tostring(getPlayerGUID(cid))
	
	if(data[player_id] == nil) then
		return
	end
	
	for k,v in pairs(data[player_id]) do
	
		local outfitId = v["outfitId"]
		local addons = v["addons"]
		
		if(addons == 3) then
		
			doPlayerAddOutfitId(cid, outfitId, 3)
		else
		
			if(addons == 1) then
			
				local hasAddon = playerHasAddonById(cid, outfitId, 2)
				
				if(not hastAddon) then
					doPlayerAddOutfitId(cid, outfitId, 1)
				else
					doPlayerAddOutfitId(cid, outfitId, 3)
				end
			elseif(addons == 2) then

				local hasAddon = playerHasAddonById(cid, outfitId, 1)
				
				if(not hastAddon) then
					doPlayerAddOutfitId(cid, outfitId, 2)
				else
					doPlayerAddOutfitId(cid, outfitId, 3)
				end
			end
		end
	end
	
	data[player_id] = nil
	
	jsonStr = json.encode(data)
	
	local file = io.open(patch, "w+")
	file:write(jsonStr)
	file:close()
end

function playerHasAddonById(cid, outfit, addon)

	local storage = nil

	if(outfit == 1) then
		if(addon == 1) then
			storage = sid.FIRST_CITIZEN
		else
			storage = sid.SECOND_CITIZEN
		end
	elseif(outfit == 2) then
		if(addon == 1) then
			storage = sid.FIRST_HUNTER
		else
			storage = sid.SECOND_HUNTER
		end	
	elseif(outfit == 3) then
		if(addon == 1) then
			storage = sid.FIRST_MAGE
		else
			storage = sid.SECOND_MAGE
		end	
	elseif(outfit == 4) then
		if(addon == 1) then
			storage = sid.FIRST_KNIGHT
		else
			storage = sid.SECOND_KNIGHT
		end	
	elseif(outfit == 5) then
		if(addon == 1) then
			storage = sid.FIRST_NOBLEMAN
		else
			storage = sid.SECOND_NOBLEMAN
		end	
	elseif(outfit == 6) then
		if(addon == 1) then
			storage = sid.FIRST_SUMMONER
		else
			storage = sid.SECOND_SUMMONER
		end	
	elseif(outfit == 7) then
		if(addon == 1) then
			storage = sid.FIRST_WARRIOR
		else
			storage = sid.SECOND_WARRIOR
		end	
	elseif(outfit == 8) then
		if(addon == 1) then
			storage = sid.FIRST_BARBARIAN
		else
			storage = sid.SECOND_BARBARIAN
		end	
	elseif(outfit == 9) then
		if(addon == 1) then
			storage = sid.FIRST_DRUID
		else
			storage = sid.SECOND_DRUID
		end	
	elseif(outfit == 10) then
		if(addon == 1) then
			storage = sid.FIRST_WIZARD
		else
			storage = sid.SECOND_WIZARD
		end	
	elseif(outfit == 11) then
		if(addon == 1) then
			storage = sid.FIRST_ORIENTAL
		else
			storage = sid.SECOND_ORIENTAL
		end	
	elseif(outfit == 12) then
		if(addon == 1) then
			storage = sid.FIRST_PIRATE
		else
			storage = sid.SECOND_PIRATE
		end	
	elseif(outfit == 13) then
		if(addon == 1) then
			storage = sid.FIRST_ASSASSIN
		else
			storage = sid.SECOND_ASSASSIN
		end	
	elseif(outfit == 14) then
		if(addon == 1) then
			storage = sid.FIRST_BEGGAR
		else
			storage = sid.SECOND_BEGGAR
		end	
	elseif(outfit == 15) then
		if(addon == 1) then
			storage = sid.FIRST_SHAMAN
		else
			storage = sid.SECOND_SHAMAN
		end	
	elseif(outfit == 16) then
		if(addon == 1) then
			storage = sid.FIRST_NORSEMAN
		else
			storage = sid.SECOND_NORSEMAN
		end	
	elseif(outfit == 17) then
		if(addon == 1) then
			storage = sid.FIRST_NIGHTMARE
		else
			storage = sid.SECOND_NIGHTMARE
		end	
	elseif(outfit == 18) then
		if(addon == 1) then
			storage = sid.FIRST_JESTER
		else
			storage = sid.SECOND_JESTER
		end	
	elseif(outfit == 19) then
		if(addon == 1) then
			storage = sid.FIRST_BROTHERHOOD
		else
			storage = sid.SECOND_BROTHERHOOD
		end	
	elseif(outfit == 20) then
		if(addon == 1) then
			storage = sid.FIRST_DEMONHUNTER
		else
			storage = sid.SECOND_DEMONHUNTER
		end	
	elseif(outfit == 21) then
		storage = sid.UNIQUE_YALAHARIAN
	else
		print("Unknown addon type.")
		return
	end

	local v = getPlayerStorageValue(cid, storage)
	
	if(v ~= -1) then
		return true
	else
		return false
	end
end

function raidLog(raidname)
	local out = os.date("%X") .. " | Raid [" .. raidname .. "] started. "
	
	local date = os.date("*t")
	local fileStr = date.day .. "-" .. date.month .. ".log"
	local patch = getConfigValue("logsDirectory") .. "raids/"
	local file = io.open(patch .. fileStr, "a+")
	
	file:write(out .. "\n")
	file:close()
end

function setPlayerAntiIdle(cid, interval)
	
	if(not isCreature(cid)) then
		return
	end
	
	if(interval > 0) then
		local dir = math.random(0, 3)
		doCreatureSetLookDirection(cid, dir)	
	
		local eventid = addEvent(setPlayerAntiIdle, interval, cid, interval)
		setPlayerStorageValue(cid, sid.HACKS_DANCE_EVENT, eventid)
	else
		local lastevent = getPlayerStorageValue(cid, sid.HACKS_DANCE_EVENT)
		stopEvent(lastevent)
		setPlayerStorageValue(cid, sid.HACKS_DANCE_EVENT, STORAGE_NULL)
	end
end

function setPlayerLight(cid, lightmode)

	if(lightmode == LIGHT_FULL) then
	
		local condition = createConditionObject(CONDITION_LIGHT)
		setConditionParam(condition, CONDITION_PARAM_LIGHT_COLOR, 215)
		setConditionParam(condition, CONDITION_PARAM_TICKS, 1000) --33 minutes(time in ms)
		setConditionParam(condition, CONDITION_PARAM_LIGHT_LEVEL, 255)	
			
		doAddCondition(cid, condition)
		
		setPlayerStorageValue(cid, sid.HACKS_LIGHT, LIGHT_FULL)
			
	elseif(lightmode == LIGHT_NONE) then
		doRemoveCondition(cid, CONDITION_LIGHT)
		setPlayerStorageValue(cid, sid.HACKS_LIGHT, LIGHT_NONE)
	end
end

function playerAutoEat(cid)
	if(not darghos_need_eat and isPlayer(cid)) then
		doPlayerFeed(cid, 1200)
		setPlayerStorageValue(cid, sid.EVENT_AUTO_EAT, addEvent(playerAutoEat, 1000 * ((60 * 20) + 1), cid))
	end	
end

function getLuaFunctions()-- by Mock
	local str = ""
	for f,k in pairs(_G) do
		if type(k) == 'function' then
			str = str..f..','
		elseif type(k) == 'table' then
			for d,o in pairs(k) do
				if type(o) == 'function' then
					if f ~= '_G' and d ~= "_G" and f ~= 'package' then
						str = str..f.."."..d..','
					end
				elseif type(o) == 'table' then
					for m,n in pairs(o) do
						if type(n) == 'function' then
							if d == "_M" and m ~= "_M" and f ~= "_G" and f ~= 'package' then
								str = str..f.."."..m..","
							elseif f ~= '_G' and m ~= "_G" and d ~= "_G" and f ~= 'package' then
								str = str..f.."."..d..'.'..m..','
							end
						elseif type(n) == 'table' then
							for x,p in pairs(n) do
								if type(p) == 'function' then
									if m == "_M" and d ~= "_M" and f ~= "_G" and f ~= 'package' then
										str = str..f.."."..d..'.'..x..','
									elseif m == "_M" and d == "_M" and f ~= "_G" and f ~= 'package' then
										str = str..f.."."..x..','
									elseif m ~= "_M" and d == "_M" and f ~= "_G" and f ~= 'package' then
										str = str..f..'.'..m..'.'..x..','
									elseif f ~= '_G' and m ~= "_G" and d ~= "_G" and f ~= 'package' then
										str = str..f.."."..d..'.'..m..'.'..x..','
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return string.explode(str,',')
end
 
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end 

function consoleLog(type, npcname, caller, string, params)
	local out = os.date("%X") .. " | [" .. type .. "] " .. caller .. " | " .. string
	
	if(params ~= nil) then
		out = out .. " | Params: {"
		
		local isFirst = true	
		
		for k,v in pairs(params) do
			
			if(not isFirst) then
				out = out .. ", "
			end
			
			out = out .. "[" .. k .. "] = " .. v
			
			isFirst = false
		end
		
		out = out .. "}"
	end
	
	local printTypes = { T_LOG_ALL }
	
	if(isInArray(printTypes, type) == TRUE or printTypes[1] == T_LOG_ALL) then
	
		local date = os.date("*t")
		local fileStr = npcname .. "_" .. date.day .. "-" .. date.month .. ".log"
		local patch = getConfigValue("logsDirectory") .. "npc/"
		local file = io.open(patch .. fileStr, "a+")
		
		file:write(out .. "\n")
		file:close()
		
		--debugPrint(out)
	end
end

function getPlayerHighMelee(cid)
	local skill = getPlayerSkill(cid, LEVEL_SKILL_CLUB)
	local skillid = LEVEL_SKILL_CLUB
	
	if(getPlayerSkill(cid, LEVEL_SKILL_SWORD) > skill) then
		skillid = LEVEL_SKILL_SWORD
		skill = getPlayerSkill(cid, LEVEL_SKILL_SWORD)
	end
	
	if(getPlayerSkill(cid, LEVEL_SKILL_AXE) > skill) then
		skillid = LEVEL_SKILL_AXE
		skill = getPlayerSkill(cid, LEVEL_SKILL_AXE)
	end
	
	return skillid
end

function startShieldTrain(cid, target)
	
	local trainingShield = getPlayerStorageValue(cid, sid.TRAINING_SHIELD) > 0 and true or false

	if(not trainingShield) then
		addEvent(addShieldTrie, 1000 * 2, cid, target)
		setPlayerStorageValue(cid, sid.TRAINING_SHIELD, 1)
	end
end

function addShieldTrie(cid, target)	

	-- aqui provavelmente o player morreu
	if(isCreature(cid) == FALSE) then
		return
	end

	--print("Training: " .. getCreatureName(cid) .. " value: " .. getPlayerStorageValue(cid, sid.TRAINING_SHIELD))
	local cTarget = getCreatureTarget(cid)
	
	if(cTarget == 0) then
		--print("Alvo nï¿½o encontrado, limpando... ")
		setPlayerStorageValue(cid, sid.TRAINING_SHIELD, 0)
		return
	else 
	
		if(getCreatureName(cTarget) ~= "Marksman Target" and getCreatureName(cTarget) ~= "Hitdoll") then
			setPlayerStorageValue(cid, sid.TRAINING_SHIELD, 0)
			return
		end
		
		doPlayerAddSkillTry(cid, LEVEL_SKILL_SHIELDING, 2, TRUE) 
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
		
		addEvent(addShieldTrie, 1000 * 2, cid, target)			
	end	
end

function addAllOufits(cid)

	if(isPlayer(cid) == TRUE) then
	
		doPlayerAddOutfit(cid, outfits.CITIZEN.male, 3)
		doPlayerAddOutfit(cid, outfits.CITIZEN.female, 3)
		
		doPlayerAddOutfit(cid, outfits.HUNTER.male, 3)
		doPlayerAddOutfit(cid, outfits.HUNTER.female, 3)
		
		doPlayerAddOutfit(cid, outfits.MAGE.male, 3)
		doPlayerAddOutfit(cid, outfits.MAGE.female, 3)
		
		doPlayerAddOutfit(cid, outfits.KNIGHT.male, 3)
		doPlayerAddOutfit(cid, outfits.KNIGHT.female, 3)
		
		doPlayerAddOutfit(cid, outfits.NOBLE.male, 3)
		doPlayerAddOutfit(cid, outfits.NOBLE.female, 3)
		
		doPlayerAddOutfit(cid, outfits.SUMMONER.male, 3)
		doPlayerAddOutfit(cid, outfits.SUMMONER.female, 3)
		
		doPlayerAddOutfit(cid, outfits.WARRIOR.male, 3)
		doPlayerAddOutfit(cid, outfits.WARRIOR.female, 3)
		
		doPlayerAddOutfit(cid, outfits.BARBARIAN.male, 3)
		doPlayerAddOutfit(cid, outfits.BARBARIAN.female, 3)
		
		doPlayerAddOutfit(cid, outfits.DRUID.male, 3)
		doPlayerAddOutfit(cid, outfits.DRUID.female, 3)
		
		doPlayerAddOutfit(cid, outfits.WIZARD.male, 3)
		doPlayerAddOutfit(cid, outfits.WIZARD.female, 3)
		
		doPlayerAddOutfit(cid, outfits.ORIENTAL.male, 3)
		doPlayerAddOutfit(cid, outfits.ORIENTAL.female, 3)
		
		doPlayerAddOutfit(cid, outfits.PIRATE.male, 3)
		doPlayerAddOutfit(cid, outfits.PIRATE.female, 3)
		
		doPlayerAddOutfit(cid, outfits.ASSASSIN.male, 3)
		doPlayerAddOutfit(cid, outfits.ASSASSIN.female, 3)
		
		doPlayerAddOutfit(cid, outfits.BEGGAR.male, 3)
		doPlayerAddOutfit(cid, outfits.BEGGAR.female, 3)
		
		doPlayerAddOutfit(cid, outfits.SHAMAN.male, 3)
		doPlayerAddOutfit(cid, outfits.SHAMAN.female, 3)
		
		doPlayerAddOutfit(cid, outfits.NORSE.male, 3)
		doPlayerAddOutfit(cid, outfits.NORSE.female, 3)
		
		doPlayerAddOutfit(cid, outfits.NIGHTMARE.male, 3)
		doPlayerAddOutfit(cid, outfits.NIGHTMARE.female, 3)
		
		doPlayerAddOutfit(cid, outfits.JESTER.male, 3)
		doPlayerAddOutfit(cid, outfits.JESTER.female, 3)
		
		doPlayerAddOutfit(cid, outfits.BROTHERHOOD.male, 3)
		doPlayerAddOutfit(cid, outfits.BROTHERHOOD.female, 3)
		
		doPlayerAddOutfit(cid, outfits.DEMONHUNTER.male, 3)
		doPlayerAddOutfit(cid, outfits.DEMONHUNTER.female, 3)
		
		doPlayerAddOutfit(cid, outfits.YALAHARIAN.male, 3)
		doPlayerAddOutfit(cid, outfits.YALAHARIAN.female, 3)
		
		doPlayerAddOutfit(cid, outfits.WARMASTER.male, 3)
		doPlayerAddOutfit(cid, outfits.WARMASTER.female, 3)
		
		doPlayerAddOutfit(cid, outfits.WEEDING.male, 3)
		doPlayerAddOutfit(cid, outfits.WEEDING.female, 3)
	end
end

--[[
	* REGISTRO DE EVENTOS ONKILL PARA MISS?ES
]]--
function OnKillCreatureMission(cid)

	-- Bonartes Mission's
	local _demonMission = getPlayerStorageValue(cid, QUESTLOG.MISSION_BONARTES.KILL_DEMONS)
	local _heroMission = getPlayerStorageValue(cid, QUESTLOG.MISSION_BONARTES.KILL_HEROS)
	local _behemothMission = getPlayerStorageValue(cid, QUESTLOG.MISSION_BONARTES.KILL_BEHEMOTHS)	
	
	if(_heroMission == 2 or _behemothMission == 1 or _demonMission == 1) then
		registerCreatureEvent(cid, "CustomBonartesTasks")
	end
end

--[[
	* DIVINE ANKH QUEST
]]--
function onLordVankynerDie()

	local door = getThing(uid.CHURCH_CHAMBER_DOOR)
	
	doSetItemActionId(door.uid, 100)
	
	addEvent(LordVankynerEvent, 1000 * 60 * 10)		
end

function LordVankynerEvent()

	local door = getThing(uid.CHURCH_CHAMBER_DOOR)
	
	doSetItemActionId(door.uid, 10000)
	
	local ALTAR_ID = 1643
	
	local altar = doCreateItem(ALTAR_ID, 1, mcord.CHURCH_ALTAR)
	doSetItemActionId(altar, aid.CHURCH_ALTAR)
	
	summonLordVankyner()
end

function summonLordVankyner()

	local creaturePos = getThingPos(uid.LORD_VANKYNER)
	local creature = doSummonCreature("Lord Vankyner", creaturePos)
	registerCreatureEvent(creature, "monsterDeath")
end

function summonDemonOak()
	local pos = getThingPos(uid.THE_DEMON_OAK_POS)
	local temp_monster = doSummonCreature("Demon Oak", pos)
	setGlobalStorageValue(gid.THE_DEMON_OAK, temp_monster)
end

function summonGrynchGoblin()

	if(not getCreatureByName("Grynch Goblin")) then
		local summonPos = {x = 1981, y = 1902, z = 6}

		local creature = doSummonCreature("Grynch Goblin", summonPos, true, true)
	end
end

function onGrynchGoblinDie(cid)
	
	if isPlayer(cid) and getPlayerStorageValue(cid, sid.SANTA_CLAUS_MISSION) == 0 then
		setPlayerStorageValue(cid, sid.SANTA_CLAUS_MISSION, 1)
	end
end

inquisitionBosses =	{
	{name = "Ushuriel", uid = uid.INQ_USHURIEL_SPAWN},
	{name = "Madareth", uid = uid.INQ_MADARETH_SPAWN},
	{name = "Zugurosh", uid = uid.INQ_ZUGOROSH_SPAWN},
	{name = "Latrivan", uid = uid.INQ_LATRIVAN_SPAWN},
	{name = "Golgordan", uid = uid.INQ_GOLGORDAN_SPAWN},
	{name = "Annihilon", uid = uid.INQ_ANNIHILON_SPAWN},
	{name = "Hellgorak", uid = uid.INQ_HELLGORAK_SPAWN}
}

function summonInquisitionBoss(boss)

	boss = boss or nil
	
	local pos = nil
	local temp_monster = nil
	
	for k,v in pairs(inquisitionBosses) do
		if((boss == nil or string.lower(v.name) == boss) and not getCreatureByName(v.name)) then
			pos = getThingPos(v.uid)
			temp_monster = doSummonCreature(v.name, pos)
			registerCreatureEvent(temp_monster, "monsterDeath")	
			print("Summoning inquisition boss " .. v.name)
		end
	end
end

--[[
	* ARIADNE QUEST
]]--
function onGhazranDie(corpse)
	
	local leader = Dungeons.getLeader(gid.DUNGEONS_ARIADNE_GHAZRAN)
	
	if(leader) then
		local members = getPartyMembers(leader)
		
		local anyoneDied = false
		
		for _, cid in pairs(members) do
			doPlayerDefeatGhazran(cid)

			if (getPlayerStorageValue(cid, ARIADNE_TROLLS_WING_ATTEMP_DEATHS) > 0) then	
				anyoneDied = true
				break
			end	
		end		
		
		for _, cid in pairs(members) do
				
			playerHistory.logDungAriadneTrollsCompleted(cid)
			
			if(not anyoneDied and not playerHistory.hasAchievement(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_COMPLETE_WITHOUT_ANYONE_DIE)) then
				playerHistory.onAchiev(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_COMPLETE_WITHOUT_ANYONE_DIE)
			end	
			
			if (getPlayerStorageValue(cid, sid.ARIADNE_TROLLS_WING_TODAY_ATTEMPS) == 1) then
				
				if(not playerHistory.hasAchievement(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_COMPLETE_IN_ONLY_ONE_ATTEMP)) then
					playerHistory.onAchiev(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_COMPLETE_IN_ONLY_ONE_ATTEMP)
				end
			end	
		end
	end
end

function doPlayerDefeatGhazran(cid)

	local hasRemovedTongue = (getPlayerStorageValue(cid, sid.ARIADNE_GHAZRAN_TONGUE) == 1)
	
	if not(hasRemovedTongue) then

		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você conseguiu obter a língua de Ghazran. Seu questlog foi atualizado.")
		setPlayerStorageValue(cid, sid.ARIADNE_GHAZRAN_TONGUE, 1)
		setPlayerStorageValue(cid, QUESTLOG.ARIADNE.GHAZRAN_WING, 2)
		
		if(not playerHistory.hasAchievement(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_GOT_GHAZRAN_TONGUE)) then
			playerHistory.onAchiev(cid, PH_ACH_DUNGEON_ARIADNE_TROLLS_GOT_GHAZRAN_TONGUE)
		end
	end
end

--[[
	@ Chama scripts customizados para quests em chests.lua
]]--
function chestScripts(cid, questActionId)

	if(questActionId == aid.CHEST_DIVINE_ANKH) then
		setPlayerStorageValue(cid, QUESTLOG.DIVINE_ANKH.CHAMBER_TEMPTATION, 4)
	end
end

--[[
	* GLOBAL SERVER SAVE
]]--
function startGlobalSave()
	
	broadcastMessage("Efetuando pause para auto save...", MESSAGE_STATUS_CONSOLE_RED)
	print("[autosave] Auto save iniciando...")
	addEvent(endGlobalSave, 500)
	
end

function endGlobalSave()

	if(doSaveServer(TRUE) ~= LUA_ERROR) then
		broadcastMessage("Auto save concluido.", MESSAGE_STATUS_CONSOLE_RED)
		print("[autosave] Auto save concluido.")
	else
		print("[saveserver] Auto save falhou.")
	end
end

--[[
	* TRAINERS
]]--
function addTrainer(actionid)

	if(actionid == aid.TRAINERS_WEST) then
		local pos = {
			trainer1 = {x= item.x-1, y= item.y-1, z= item.z},
			trainer2 = {x= item.x-1, y= item.y+1, z= item.z}				
		}
	end
	
	if(actionid == aid.TRAINERS_EAST) then
		local pos = {
			trainer1 = {x= item.x-1, y= item.y-1, z= item.z},
			trainer2 = {x= item.x-1, y= item.y+1, z= item.z}				
		}	
	end
	
	

end

--[[
	* SETAR NOVOS ITEMS PARA FIRST LOGIN
]]--
function defineFirstItems(cid)

	if(isPlayer(cid) == FALSE) then
		return
	end

	if(getPlayerStorageValue(cid, sid.FIRSTLOGIN_ITEMS) == 1) then
		return
	end		
	
	local item_legs = doCreateItemEx(getItemIdByName("studded legs"), 1)
	local item_armor = 0
	local item_boots = doCreateItemEx(getItemIdByName("leather boots"), 1)
	local item_helmet = 0
	local item_left_hand = 0
	local item_right_hand = doCreateItemEx(getItemIdByName("dwarven shield"), 1)
	local item_backpack = doCreateItemEx(1988, 1)

	doAddContainerItem(item_backpack, 2120, 1) -- rope
	doAddContainerItem(item_backpack, 2554, 1) -- shovel	
	doAddContainerItem(item_backpack, 2789, 25) -- brown mushroom
	doAddContainerItem(item_backpack, 2152, 3) -- platinum coin
	
	if(isSorcerer(cid)) then
		item_armor = doCreateItemEx(getItemIdByName("magician's robe"), 1)
		item_helmet = doCreateItemEx(getItemIdByName("mage hat"), 1)
		item_left_hand = doCreateItemEx(getItemIdByName("wand of vortex"), 1)
	elseif(isDruid(cid)) then
		item_armor = doCreateItemEx(getItemIdByName("magician's robe"), 1)
		item_helmet = doCreateItemEx(getItemIdByName("mage hat"), 1)
		item_left_hand = doCreateItemEx(getItemIdByName("snakebite rod"), 1)
	elseif(isPaladin(cid)) then
		item_armor = doCreateItemEx(getItemIdByName("chain armor"), 1)
		item_helmet = doCreateItemEx(getItemIdByName("studded helmet"), 1)
		item_left_hand = doCreateItemEx(getItemIdByName("spear"), 5)
	elseif(isKnight(cid)) then
		item_armor = doCreateItemEx(getItemIdByName("chain armor"), 1)
		item_helmet = doCreateItemEx(getItemIdByName("studded helmet"), 1)
		item_left_hand = doCreateItemEx(getItemIdByName("hatchet"), 1)	
		
		-- adicional weapon to knights choose in backpack
		doAddContainerItem(item_backpack, getItemIdByName("katana"), 1) 
		doAddContainerItem(item_backpack, getItemIdByName("mace"), 1)
	end

	doPlayerAddItemEx(cid, item_legs, FALSE, CONST_SLOT_LEGS)
	doPlayerAddItemEx(cid, item_armor, FALSE, CONST_SLOT_ARMOR)
	doPlayerAddItemEx(cid, item_boots, FALSE, CONST_SLOT_FEET)
	doPlayerAddItemEx(cid, item_helmet, FALSE, CONST_SLOT_HEAD)
	doPlayerAddItemEx(cid, item_left_hand, FALSE, CONST_SLOT_LEFT)
	doPlayerAddItemEx(cid, item_right_hand, FALSE, CONST_SLOT_RIGHT)
	doPlayerAddItemEx(cid, item_backpack, FALSE, CONST_SLOT_BACKPACK)
	
	setPlayerStorageValue(cid, sid.FIRSTLOGIN_ITEMS, 1)		
end

function playerRecord()

	if(not darghos_use_record) then
		return
	end

	local record = getGlobalStorageValue(gid.PLAYERS_RECORD)
	
	if(record ~= -1) then
		
		local playerson = getPlayersOnlineList()
		local total = #playerson
		
		if(total <= 50) then
			total = total * 2
		else
			total = total + 50
		end
		
		if(total > record) then
		
			setGlobalStorageValue(gid.PLAYERS_RECORD, total)
			broadcastMessage("A marca de ".. total .." jogadores online é um novo recorde no Darghos!", MESSAGE_EVENT_DEFAULT)
		end
	else

		setGlobalStorageValue(gid.PLAYERS_RECORD, 200) 
	end
end

function msgcontains(txt, str)
      return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end

function checkGeneralInfoPlayer(cid)
	
	local level 		= 	getPlayerLevel(cid)
	
	if(isSorcerer(cid)) or (isDruid(cid)) then
		realHP 	=	(level * 5 + 145)
	elseif(isKnight(cid)) then
		realHP	=	(level * 15 + 65)
	elseif(isPaladin(cid)) then
		realHP	= 	(level * 10 + 105)
	else
		realHP	= 	(level * 5 + 145)
	end
	
	if(getPlayerMaxHealth(cid)) < realHP then
		print("[infoChecker] Player "..getCreatureName(cid).." esta com a life bugada!")
	else
		print("[infoChecker] Player "..getCreatureName(cid).." esta mil grau.")
	end	
	
end


-- Verifica??o ATUAL se um player est? em Area premmy, e teleporta ele para area free.
function runPremiumSystem(cid)

	if(isPremium(cid) and getPlayerStorageValue(cid,sid.PREMMY_VERIFY) ~= 1) then
		setPlayerStorageValue(cid, sid.PREMMY_VERIFY,1)
		return
	end
	
	if(not isPremium(cid) and getPlayerStorageValue(cid,sid.PREMMY_VERIFY) == 1) then
	
		local new_town = towns.QUENDOR
	
		if(getPlayerTown(cid) == towns.ISLAND_OF_PEACE) then
			new_town = towns.ISLAND_OF_PEACE
		end		
		
		doPlayerSetTown(cid, new_town)
		doTeleportThing(cid, getTownTemplePosition(new_town))
		setPlayerStorageValue(cid, sid.PREMMY_VERIFY,0)
		
		--Player is not premium - remove premium privileges
		--Change outfit
		local lookType = 128
		if(getPlayerSex(cid) == 0) then
			lookType = 136
		end
		doCreatureChangeOutfit(cid, {lookType = lookType, lookHead = 78, lookBody = 69, lookLegs = 97, lookFeet = 95, lookAddons = 0})	
		
		local message = "Caro " .. getCreatureName(cid) ..",\n\nA sua conta premium expirou e por isso você perdeu os privilegios exclusivos deste tipo de conta.\nVocê pode re-adquirir uma nova Conta Premium atraves de nosso website e todos os privilegios serão novamente ativos.\n\n Tenha um bom jogo!\nUltraXSoft Team."	
		doPlayerPopupFYI(cid, message)
	end
end

-- Reproduz um efeito em torno do jogador
function sendEnvolveEffect(cid, effect)

	doSendMagicEffect(getPlayerPosition(cid), effect)
	doSendMagicEffect({x = getPlayerPosition(cid).x + 1, y = getPlayerPosition(cid).y + 1, z = getPlayerPosition(cid).z}, effect) 
	doSendMagicEffect({x = getPlayerPosition(cid).x - 1, y = getPlayerPosition(cid).y + 1, z = getPlayerPosition(cid).z}, effect)
	doSendMagicEffect({x = getPlayerPosition(cid).x + 1, y = getPlayerPosition(cid).y - 1, z = getPlayerPosition(cid).z}, effect)
	doSendMagicEffect({x = getPlayerPosition(cid).x - 1, y = getPlayerPosition(cid).y - 1, z = getPlayerPosition(cid).z}, effect) 
	doSendMagicEffect({x = getPlayerPosition(cid).x, y = getPlayerPosition(cid).y - 1, z = getPlayerPosition(cid).z}, effect) 
	doSendMagicEffect({x = getPlayerPosition(cid).x - 1, y = getPlayerPosition(cid).y, z = getPlayerPosition(cid).z}, effect)
	doSendMagicEffect({x = getPlayerPosition(cid).x, y = getPlayerPosition(cid).y + 1, z = getPlayerPosition(cid).z}, effect)
	doSendMagicEffect({x = getPlayerPosition(cid).x + 1, y = getPlayerPosition(cid).y, z = getPlayerPosition(cid).z}, effect) 	
end 

function addPremiumTest(cid)

	doPlayerAddPremiumDays(cid, darghos_premium_test_quanty)
	local account = getPlayerAccountId(cid)
	db.executeQuery("INSERT INTO `wb_premiumtest` VALUES ('" .. account .. "', '" .. os.time() .. "');")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Parabens! Você recebeu 10 dias de conta premium no Darghos gratuitamente! Aproveite e divirta-se!")
	sendEnvolveEffect(cid, CONST_ME_HOLYAREA)
end

function canReceivePremiumTest(cid, newlevel)

	if(darghos_premium_test_level == 0 or newlevel < darghos_premium_test_level) then
		return false
	end	

	if(isPremium(cid)) then
		return false
	end

	local account = getPlayerAccountId(cid)
	
	local result = db.getResult("SELECT COUNT(*) as `rowscount` FROM `wb_premiumtest` WHERE `account_id` = '" .. account .. "';")
	if(result:getID() == -1) then
		--print("[Spoofing] Players list not found.")
		return false
	end

	local rowscount = result:getDataInt("rowscount")
	result:free()		
	
	if(rowscount > 0) then
		return false
	end
	
	if(not hasValidEmail(cid)) then
		return false
	end
	
	return true
end

function hasValidEmail(cid)

	local account = getPlayerAccountId(cid)
	
	local result = db.getResult("SELECT `email` FROM `accounts` WHERE `id` = '" .. account .. "' AND `email` != '';")
	if(result:getID() == -1) then
		return false
	end

	local email = result:getDataString("email")
	result:free()		
	
	if(email == "" or email == nil) then
		return false
	end	
	
	return true
end

function notifyValidateEmail(cid)
	local message = "Caro " .. getCreatureName(cid) ..",\n\n"
	message = message .. "Você ainda não registrou um e-mail valido em sua conta. Lembre-se que por isso\n"
	message = message .. "sua conta não esta segura e você não conseguirá recuperar-la caso perda seus dados de acesso!\n\n"
	message = message .. "As seguintes vantagens também serão desbloqueadas em sua conta após o registro do e-mail:\n\n"
	message = message .. " - Comprar um premium ticket em nossa loja Darghos.\n"
	message = message .. " - Usar um premium ticket.\n"
	message = message .. " - Receber instantaneamente 10 dias gratuitos para testar.\n"
	message = message .. " - Gerar uma chave de recuperação.\n\n"
	message = message .. "Acesse o website o mais breve possivel e registre o e-mail de sua conta!\n"
	message = message .. "www.darghos.com.br\n\n"
	message = message .. "Tenha um bom jogo!"
	doPlayerPopupFYI(cid, message)
end

-- Verifica se o jogador ja foi notificado, existe uma enquete aberta, se o jogador possui um usuario e se esse usuario jï¿½ votou, se tudo for verdadeiro, ele retorna falso
-- se nï¿½o, retorna o resumo da enquete para ser exibido
function hasPollToNotify(cid)

	--[[
	local notify = getPlayerStorageValue(cid, sid.WEBSITE_POLL_NOTIFY)
	
	if(notify == 1) then
		return false
	end

	local result = db.getResult("SELECT `id`, `text` FROM `wb_forum_polls` WHERE `end_date` > UNIX_TIMESTAMP();")
	if(result:getID() == -1) then
		return false
	end
	
	local poll = {}
	
	poll.id = result:getDataInt("id")
	poll.text = result:getDataString("text")
	result:free()
	
	local account = getPlayerAccountId(cid)
	result = db.getResult("SELECT `user`.`id` FROM `wb_forum_users` `user` LEFT JOIN `wb_forum_user_votes` `vote` ON `vote`.`member_id` = `user`.`id` LEFT JOIN `wb_forum_polls_opt` `opt` ON `opt`.`id` = `vote`.`opt_id` WHERE `user`.`account_id` = " .. account .. " AND `opt`.`poll_id` = " .. poll.id .. ";")

	if(result:getID() == -1) then
		setPlayerStorageValue(cid, sid.WEBSITE_POLL_NOTIFY, 1)
		return poll
	end
	
	result:free()
	]]
	
	return false
end

function getWeekday()
	return getGlobalStorageValue(gid.START_SERVER_WEEKDAY)
end

function table.copy(table_to_copy)
	local _copy = {}
	for k,v in pairs(table_to_copy) do
		if(type(v) == "table") then
			_copy[k] = table.copy(v)
		else
			_copy[k] = v
		end
	end
	
	return _copy
end

--HACK
function doPlayerIsInBattleground(cid)
	return false
end
