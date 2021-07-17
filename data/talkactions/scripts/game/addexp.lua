local callbacks = {
	
	["/addexp"] = function(cid, param)

		if(param == '') then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command requires param.")
			return true
		end

		local t = string.explode(param, ",")
		if(not t[2]) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Not enough params.")
			return true
		end

		local pid = getPlayerByNameWildcard(t[1])
		if(not pid or (isPlayerGhost(pid) and getPlayerGhostAccess(pid) > getPlayerGhostAccess(cid))) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. t[1] .. " not found.")
			return true
		end

		local amount = tonumber(t[2])
		if(not amount or amount == 0) then
			amount = 1
		end

		doPlayerAddExperience(pid, amount)
		return true
	end
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid, param)
		return true
	end

	return false
end