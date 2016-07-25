local callbacks = {
	
	["/talkbot"] = function(cid, param)

		if param == "" then 
			local onlineList = getPlayersOnline()
			local botList = {}

			for i, uid in ipairs(onlineList) do
				if doPlayerIsBot(uid) then
					table.insert(botList, uid)
				end
			end

			local bot = botList[math.random(1, #botList)]

			currentSpeakingBot[cid] = bot

			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Talking on public channels as " .. getPlayerName(currentSpeakingBot[cid]) .. " (" .. getPlayerLevel(currentSpeakingBot[cid]) .. ").")
			return true
		elseif param == "stop" then
			table.remove(currentSpeakingBot, cid)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Talking as " .. getPlayerName(cid) .. ".")
		else
			local bot = getPlayerByNameWildcard(param)

			if not bot or not doPlayerIsBot(bot) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Bot with name " .. param .. " not found.")	
			end

			currentSpeakingBot[cid] = bot
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Talking on public channels as " .. getPlayerName(currentSpeakingBot[cid]) .. ".")
		end
	end
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid, param)
		return true
	end

	return false
end