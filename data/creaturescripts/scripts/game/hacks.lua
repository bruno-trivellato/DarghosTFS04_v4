local function checkLight(cid)
	local hackstate = getPlayerStorageValue(cid, sid.HACKS_LIGHT)
	
	if(hackstate == LIGHT_FULL) then
		setPlayerLight(cid, LIGHT_FULL)
	end	
end

local castManaExhaust = createConditionObject(CONDITION_EXHAUST)
setConditionParam(castManaExhaust, CONDITION_PARAM_TICKS, 2000)
setConditionParam(castManaExhaust, CONDITION_PARAM_SUBID, EXHAUST_HEALING)

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

		if(mana >= manalimit and not hasCondition(cid, CONDITION_EXHAUST, EXHAUST_HEALING)) then
			doPlayerAddMana(cid, -(manachange), false)
			doPlayerAddManaSpent(cid, manachange)
			doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_BLUE)
			--doCreatureSay(cid, "Automana...", TALKTYPE_MONSTER)
			doAddCondition(cid, castManaExhaust)
		end
	end	
end

danceEvents = {}
expEvents = {}

function autoDance(cid)
	if(not isCreature(cid)) then
		return
	end

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
end
