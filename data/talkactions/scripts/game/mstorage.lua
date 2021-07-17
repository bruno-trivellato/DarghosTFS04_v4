function onSay(cid, words, param)
	local t = string.explode(param, ",")
	if(not t[2]) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Invalid param specified.")
		return true
	end

	db.executeQuery("UPDATE `player_storage` SET `value` = " .. t[2]  .. " WHERE `key` = " .. t[1] .. ";")

	for _, pid in ipairs(getPlayersOnline()) do

		setPlayerStorageValue(pid, t[1], t[2])
	end	

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "All players storage [" .. t[1] .. "] = " .. t[2])

	return true
end
