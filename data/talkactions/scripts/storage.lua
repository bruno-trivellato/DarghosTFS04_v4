function onSay(cid, words, param)
	local t = string.explode(param, ",")
	if(not t[2]) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Invalid param specified.")
		return true
	end

	local isGlobal = false
	local tid
	
	if(t[1] ~= "global") then
		tid = getPlayerByNameWildcard(t[1])
		if(not tid or (isPlayerGhost(tid) and getPlayerGhostAccess(tid) > getPlayerGhostAccess(cid))) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. t[1] .. " not found.")
			return true
		end
	else
		isGlobal = true
	end

	if(not t[3]) then
		
		local value
		
		if(isGlobal) then
			value = getGlobalStorageValue(t[2])
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, " [" .. t[2] .. "] = " .. value)
		else
			value = getPlayerStorageValue(tid, t[2])
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, " [" .. t[1] .. " - " .. t[2] .. "] = " .. value)
		end		
	else
		if(isGlobal) then
			setGlobalStorageValue(t[2], t[3])
		else
			setPlayerStorageValue(tid, t[2], t[3])
		end
	end

	return true
end
