local callbacks = {
	
	["/lockhelp"] = function(cid, param)

		_helpChannel.locked	= true
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Help locked.")
		return true
	end,

	["/unlockhelp"] = function(cid, param)

		_helpChannel.locked	= true
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Help unlocked.")
		return true
	end,

	["/mutep"] = function(cid, param)
		local pid = getPlayerByNameWildcard(param)
		if(not pid) then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Player " .. param .. " not found.")
			return true 
		end

		setPlayerStorageValue(pid, sid.MUTED, 1)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Player " .. param .. " muted.")
	end,

	["/unmutep"] = function(cid, param)
		local pid = getPlayerByNameWildcard(param)
		if(not pid) then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Player " .. param .. " not found.")
			return true 
		end

		setPlayerStorageValue(pid, sid.MUTED, 0)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Player " .. param .. " unmuted.")
	end	
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid, param)
		return true
	end

	return false
end