local function canBeCreated(id)
		
	local denyItems = {
		{ from = 12690, to = 12696 },
		{ from = 12671, to = 12689 },		
		2408,
		2469,
		2471,
		2523,
		2496,
		2474,
		9932,
		9933,
		8925,
		2390,
		2408,
		7450
	}	

	for k,v in pairs(denyItems) do
		if(type(v) == "table") then
			if(id >= v.from and id <= v.to) then
				return false
			end
		else
			if(v == id) then
				return false
			end
		end
	end
	
	return true
end

function onSay(cid, words, param, channel)
	if(param == '') then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
		return true
	end

	local t = string.explode(param, ",")
	local ret = RETURNVALUE_NOERROR
	local pos = getCreaturePosition(cid)

	if(t[1] == "teleport") then
		local id = 1387
		local orig_pos = getCreatureLookPosition(cid)
		local dest_pos = { x = tonumber(t[2]), y = tonumber(t[3]), z = tonumber(t[4])}
		
		doCreateTeleport(id, dest_pos, orig_pos)
		return true
	end
	
	local id = tonumber(t[1])
	if(not id) then
		id = getItemIdByName(t[1], false)
		if(not id) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Item wich such name does not exists.")
			return true
		end
	end

	local amount = 100
	if(t[2]) then
		amount = t[2]
	end
	
	local staticItemAmount = {
		[2173] = 1,
		[2197] = 5,
		[2164] = 20,
	}
	
	if(staticItemAmount[id] ~= nil) then
		amount = staticItemAmount[id]
	end
	
	if(not canBeCreated(id)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "This item can not be created by anyone.")
		return true	
	end


	local item = doCreateItemEx(id, amount)
	if(t[3] and getBooleanFromString(t[3])) then
		if(t[4] and getBooleanFromString(t[4])) then
			pos = getCreatureLookPosition(cid)
		end

		ret = doTileAddItemEx(pos, item)
	else
		ret = doPlayerAddItemEx(cid, item, true)
	end

	if(ret ~= RETURNVALUE_NOERROR) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Couldn't add item: " .. t[1])
		return true
	end

	doDecayItem(item)
	if(not isPlayerGhost(cid)) then
		doSendMagicEffect(pos, CONST_ME_MAGIC_RED)
	end

	return true
end
