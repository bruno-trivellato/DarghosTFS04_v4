function onLook(cid, thing, position, lookDistance)    

	local item_id = thing.itemid	
	if(item_id == CUSTOM_ITEMS.OUTFIT_TICKET) then
		lookingOutfitTicket(cid, thing)
	elseif(thing.actionid == aid.ARENA_SEARING_FIRE and getPlayerStorageValue(cid, sid.CURRENT_ARENA) ~= -1) then
		local lastBattleEnd = getStorage(gid.ARENA_LAST_BATTLE_START) + ARENA_DURATION
		if(os.time() < lastBattleEnd) then
			local ticksLeft = lastBattleEnd - os.time()
			
			local desc = "Time left: "
			
			if(ticksLeft > 60) then
				local minLeft = math.floor(ticksLeft / 60)
				desc = desc .. "about " .. minLeft .. " minutes."
			else
				desc = desc .. ticksLeft .. " seconds."
			end
			
			doItemSetAttribute(thing.uid, "description", desc)
		end
	end

	return true
end