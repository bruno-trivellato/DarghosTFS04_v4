function onSay(cid, words, param, channel)
	if(param == '') then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command requires param.")
		return true
	end

	local target = getPlayerByNameWildcard(param)
	if(not target) then
		target = getCreatureByName(param)
		if(not target) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Creature not found.")
			return true
		end
	end
	
	if(isMonster(target)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You can teleport only players and npcs.")
		return true	
	end

	if(isPlayerGhost(target) and getPlayerGhostAccess(target) > getPlayerGhostAccess(cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Creature not found.")
		return true
	end

	if(isPlayer(target)) then
		if(isPlayerPzLocked(target)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You can not teleport players with pz-locked state.")
			return true	
		end
		
		createSummonRequest(cid, target)
		
	elseif(isNpc(target)) then
		doSummonCreatureNear(cid, target)
	end



	return true
end
