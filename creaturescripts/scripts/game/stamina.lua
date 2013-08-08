function onThink(cid, interval)
	if(not isCreature(cid) or not isPlayer(cid) or getPlayerPremiumDays(cid) == 0) then
		return
	end
	
	local target = getCreatureTarget(cid)
	if(not target or target == 0) then
		return
	end
	
	local check = false
	if(string.lower(getCreatureName(target)) == "marksman target" or string.lower(getCreatureName(target)) == "hitdoll") then
		check = true
	end
	
	if(not check) then
		return
	end
	
	--[[
	local master = getCreatureMaster(target)
	if(not master) then
		return
	end
	
	if(not isPlayer(master) or master == cid) then
		return
	end
	
	
	local tile = getTileInfo(getCreaturePosition(cid))
	
	if(not tile.optional) then
		setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, STORAGE_NULL)		
		return
	end
	]]
	
	local nextStaminaUpdate = getPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE)
	
	if(nextStaminaUpdate ~= -1 and os.time() < nextStaminaUpdate) then
		return
	end
	
	local bonusStamina = 39 * 60
	local maxStamina = 42 * 60
	
	local staminaMinutes = getPlayerStamina(cid)
	local newStamina = staminaMinutes + 1
	
	local highStaminaInterval = (60 * 20)
	local lowStaminaInterval = (60 * 6)
	
	if(staminaMinutes >= maxStamina) then
		return
	end
	
	if(newStamina >= bonusStamina) then		
		setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, os.time() + highStaminaInterval)
	else	
		setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, os.time() + lowStaminaInterval)
	end
	
	if(nextStaminaUpdate ~= -1) then
		doPlayerSetStamina(cid, 1)
		doSendAnimatedText(getPlayerPosition(cid), "STAMINA +1", TEXTCOLOR_PURPLE)
	end
end
