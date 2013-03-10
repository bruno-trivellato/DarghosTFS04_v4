local function checkLight(cid)
	local hackstate = getPlayerStorageValue(cid, sid.HACKS_LIGHT)
	
	if(hackstate == LIGHT_FULL) then
		setPlayerLight(cid, LIGHT_FULL)
	end	
end

local function checkCastMana(cid)

	local tile = getTileInfo(getCreaturePosition(cid))
	if(not tile.optional) then		
		return
	end
	
	local attacked = getCreatureTarget(cid)
	if(getBooleanFromString(attacked) and isInArray({"Marksman Target", "Hitdoll"}, getCreatureName(attacked))) then
		local mana = getCreatureMana(cid)
		local manamax = getCreatureMaxMana(cid)
		local manachange = math.ceil(manamax / 2) -- default is half (50%)
		local manalimit = manamax - math.ceil(manamax / 4) -- 75%

		if(mana >= manalimit) then
			doPlayerAddMana(cid, -(manachange), false)
			doPlayerAddManaSpent(cid, manachange)
			doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_BLUE)
			doCreatureSay(cid, "Automana...", TALKTYPE_MONSTER)
		end
	end	
end

danceEvents = {}

function checkPlayerBot(cid)
	
	if(getPlayerGroupId(cid) ~= GROUPS_PLAYER_BOT) then
		return
	end
			
	local attacked = getCreatureTarget(cid)
	if(not danceEvents[cid] and getBooleanFromString(attacked) and isInArray({"Marksman Target", "Hitdoll"}, getCreatureName(attacked))) then
		danceEvents[cid] = addEvent(autoDance, 1000 * 10, cid)
	end
end

function autoDance(cid)
	doCreatureSetLookDirection(cid, math.random(NORTH, WEST))
	danceEvents[cid] = nil
end

function onThink(cid, interval)
	if(not isCreature(cid)) then
		return
	end

	if(not darghos_need_eat) then
		if(getPlayerFood(cid) == 0) then
			doPlayerFeed(cid, 1200)
		end
	end

	checkLight(cid)
	checkCastMana(cid)
	checkPlayerBot(cid)
end
