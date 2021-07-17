function onSay(cid, words, param, channel)
	local pid = 0
	if(param == '') then
		pid = getCreatureTarget(cid)
		if(pid == 0) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
			return true
		end
	else
	
		local t = string.explode(param, ",")
		
		if(t[1] == "mcs" and getPlayerAccess(cid) == ACCESS_SADMIN) then
			
			if(t[2] ~= nil and type(t[2]) == "number") then
				mcs.toDrop = t[2]
			else
				mcs.toDrop = 60				
			end
			
			mcs.buildList()
			mcs.dropOne()
			
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Droping...")
			return true		
		end
	
		pid = getPlayerByNameWildcard(param)
	end

	if(not pid or (isPlayerGhost(pid) and getPlayerGhostAccess(pid) > getPlayerGhostAccess(cid))) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. param .. " is not currently online.")
		return true
	end

	if(isPlayerPzLocked(pid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You can not kick players with pz-locked state.")
		return true	
	end	
	
	if(isPlayer(pid) and getPlayerAccess(pid) >= getPlayerAccess(cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You cannot kick this player.")
		return true
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) .. " has been kicked.")
	doRemoveCreature(pid)
	return true
end
