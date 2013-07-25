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
	
	local statistics = {
		ping_min = nil,

		ping_sum = 0,
		ping_max = nil,	
		pingT_min = nil,
		pingT_sum = 0,
		pingT_max = nil,
		tunnel = 0,
	}
	
	local skipped = 0	
	local j = 0
	for i, uid in ipairs(onlineList) do
		
		local attacked = getCreatureTarget(uid)
		if(getPlayerGroupId(uid) ~= GROUPS_PLAYER_BOT and (not attacked or not isInArray({"Marksman Target", "Hitdoll"}, getCreatureName(attacked)))) then

			local addStr = "\n"
			addStr = addStr .. getPlayerName(uid) .. " ("
			addStr = addStr .. "lv " .. getPlayerLevel(uid) .. ", "
			addStr = addStr .. "ml " .. getPlayerMagLevel(uid) .. ", "
			addStr = addStr .. (isPremium(uid) and "P" or "F") .. ", "
			addStr = addStr .. getPlayerCurrentPing(uid) .. (isInTunnel(uid) and "*" or "") .. " ms"
			addStr = addStr .. ")"
			
			if(not isInTunnel(uid)) then
				if(statistics.ping_min == nil or getPlayerCurrentPing(uid) < statistics.ping_min) then
					statistics.ping_min = getPlayerCurrentPing(uid)

				end		
				
				if(statistics.ping_max == nil or getPlayerCurrentPing(uid) > statistics.ping_max) then
					statistics.ping_max = getPlayerCurrentPing(uid)
				end
				
				statistics.ping_sum = statistics.ping_sum + getPlayerCurrentPing(uid)
			else
				if(statistics.pingT_min == nil or getPlayerCurrentPing(uid) < statistics.pingT_min) then
					statistics.pingT_min = getPlayerCurrentPing(uid)
				end		
				
				if(statistics.pingT_max == nil or getPlayerCurrentPing(uid) > statistics.pingT_max) then
					statistics.pingT_max = getPlayerCurrentPing(uid)
				end
				
				statistics.pingT_sum = statistics.pingT_sum + getPlayerCurrentPing(uid)		
				statistics.tunnel = statistics.tunnel + 1		
			end

			if string.len(addStr) + string.len(str) >= 255 then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
				str = addStr
			elseif #onlineList == 1 then
				str = addStr
			else
				str = str .. addStr
			end
			j = j + 1
		else
			skipped = skipped + 1
		end
	end

	if str ~= "" then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Total: " .. #onlineList .. " player's online (" .. skipped .. " skiped, " .. statistics.tunnel .. " via tunnel).")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Ping statistics: min ".. statistics.ping_min .." ms, avg ".. math.floor(statistics.ping_sum / (j - statistics.tunnel)) .." ms, max ".. statistics.ping_max .." ms.")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Ping statistics (tunnel): min ".. statistics.pingT_min .." ms, avg ".. math.floor(statistics.pingT_sum / statistics.tunnel) .." ms, max ".. statistics.pingT_max .." ms.")

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