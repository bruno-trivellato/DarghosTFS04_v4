local config = {
	showGamemasters = getBooleanFromString(getConfigValue('displayGamemastersWithOnlineCommand')),
	world_id = getConfigValue('worldId')
}

MESSAGE_LIMIT = 240
UPDATE_LIST_INTERVAL = 1000 * 30
onlineList = {}
onlineStrings = {}

function updateOnlineList()

	onlineList = {}

	local result = db.getResult("SELECT `name`, `level` FROM `players` WHERE `online` = '1' AND `world_id` = ".. config.world_id .. " ORDER BY `name`");
	
	if(result:getID() ~= -1) then
		repeat
			local pname, plevel = result:getDataString("name"), result:getDataInt("level")
			local player = {name = pname, level = plevel}
			table.insert(onlineList, player)
		until not(result:next())
	end
	
	local str, first = "", true
	local size = table.size(onlineList)
	onlineStrings = {}
	
	for _, info in ipairs(onlineList) do
	
		local pid = getCreatureByName(info.name)
		
		local canAdd = true
		
		if(creature ~= nil) then
			if((config.showGamemasters or getPlayerCustomFlagValue(cid, PLAYERCUSTOMFLAG_GAMEMASTERPRIVILEGES) or not getPlayerCustomFlagValue(pid, PLAYERCUSTOMFLAG_GAMEMASTERPRIVILEGES)) and (not isPlayerGhost(pid) or getPlayerGhostAccess(cid) >= getPlayerGhostAccess(pid))) then
				canAdd = false
			end
		end
	
		if(canAdd) then			
			local tmp = info.name .. " [" .. info.level .. "]"
			if(string.len(str) + string.len(tmp) > MESSAGE_LIMIT) then
				str = str .. "."
				table.insert(onlineStrings, str)
				str = tmp
			else
				if(first) then
					first = false
				else
					str = str .. ", "
				end
				
				str = str .. tmp
			end
		end
	end

	str = str .. "."
	table.insert(onlineStrings, str)
	addEvent(updateOnlineList, UPDATE_LIST_INTERVAL)
end

function onlinePrivileged(cid, words, param)

	local onlineList = getPlayersOnline()
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Players Online:")

	local str = ""
	
	local j = 0
	for i, uid in ipairs(onlineList) do
		
		local addStr = "\n"
		addStr = addStr .. "Name: " .. getPlayerName(uid) .. ", "
		addStr = addStr .. "Level: " .. getPlayerLevel(uid) .. ", "
		addStr = addStr .. "Ping: " .. getPlayerCurrentPing(uid) .. ", "
		addStr = addStr .. "Premium: " .. (isPremium(uid) and "S" or "N") .. ", "
		addStr = addStr .. "Mag: " .. getPlayerMagLevel(uid) .. "\n"

		if string.len(addStr) + string.len(str) >= 255 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
			str = addStr
		elseif #onlineList == 1 then
			str = addStr
		else
			str = str .. addStr
		end
		j = j + 1
	end

	if str ~= "" then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
	end

	if j <= 1 then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Total: ".. j .." player online.")
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Total: " .. j .. " players online.")
	end

	return true
end

function refleshPlayersOnline(cid)
	local onlineList = getPlayersOnline()
	
	local playersStr = ""
	local first = true
	
	for i, uid in ipairs(onlineList) do
		if(not first) then
			playersStr = playersStr .. ","
		else
			first = false
		end
		
		playersStr = playersStr ..  getPlayerGUID(uid)
	end
		
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Players reflesh done.")	
	db.executeQuery("UPDATE `players` SET `online` = '1' WHERE id IN (" .. playersStr .. ");")
	return true
end

function onSay(cid, words, param, channel)
	
	if(getPlayerAccess(cid) >= access.GOD and param == "reflesh") then
		return refleshPlayersOnline(cid, words, param)
	end	
	
	if(getPlayerAccess(cid) >= access.GOD and param ~= "normal") then
		return onlinePrivileged(cid, words, param)
	end
	
	if(#onlineStrings == 0) then
		updateOnlineList()
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, (#onlineList) .. " player" .. (#onlineList > 1 and "s" or "") .. " online:")

	if(#onlineStrings > 0) then
		for k,v in pairs(onlineStrings) do
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, v)
		end
	end
	
	return true
end