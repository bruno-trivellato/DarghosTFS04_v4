
PREMIUM_TYPE_BUY = 0
PREMIUM_TYPE_SELL = 1

local CODE_EXPIRATION = 1 -- minutes

local codes = {}

CODE_EXPIRED = 0
CODE_WRONG = 1
CODE_NON_EXIST = 2
CODE_NO_ERROR = 3

BUY_DAYS = 5
SELL_DAYS = 20

local priceConfigWorlds = {	
	[WORLD_ANTINUM] = { startPrice = 1000000, increase = math.random(200, 250), decrease = math.random(800, 1000) }
	,[WORLD_NOVIUM] = { startPrice = 300000, increase = math.random(66, 83), decrease = math.random(264, 332) }
}

local function generateCode(cid)

	local valid = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
	local code = ""

	for i = 1, 5 do
		local rand = math.random(1, #valid)
		code = code .. valid:sub(rand, rand)
	end

	table.insert(codes, cid, {date = os.time(), value = code})

	return code
end

local function checkCode(cid, _code)
	local code = codes[cid]

	if(code == nil) then
		return {"", CODE_NON_EXIST}
	end

	if(code ~= nil and os.time() >= code.date + (60 * CODE_EXPIRATION)) then
		return {code.value, CODE_EXPIRED}
	end

	if(code.value ~= _code) then
		return {code.value, CODE_WRONG}
	end

	return {code.value, CODE_NO_ERROR}
end

local function registerHistory(cid, type, value)

	local world_id = getConfigValue('worldId')
	local v = getGlobalStorageValue(gid.PREMIUM_VALUE)

	if type == PREMIUM_TYPE_BUY then
		v = v + (priceConfigWorlds[world_id].increase * 1000)
		setGlobalStorageValue(gid.PREMIUM_VALUE, v)
	elseif type == PREMIUM_TYPE_SELL then
		v = v - (priceConfigWorlds[world_id].decrease * 1000)
		v = v <= priceConfigWorlds[world_id].startPrice and priceConfigWorlds[world_id].startPrice or v
		setGlobalStorageValue(gid.PREMIUM_VALUE, v)
	end

	db.executeQuery("INSERT INTO `premium_history` (`player_id`, `date`, `type`, `value`) VALUES (" .. getPlayerGUID(cid) .. ", " .. os.time() .. ", " .. type .. ", " .. value .. ");")
end

local function getCurrentPrice(type)

	local v
	local world_id = getConfigValue('worldId')

	if type == PREMIUM_TYPE_BUY then
		v = getGlobalStorageValue(gid.PREMIUM_VALUE)

		if v < priceConfigWorlds[world_id].startPrice then
			v = priceConfigWorlds[world_id].startPrice
			setGlobalStorageValue(gid.PREMIUM_VALUE, v)
		end
		
	elseif type == PREMIUM_TYPE_SELL then
		v = getGlobalStorageValue(gid.PREMIUM_VALUE)

		if v < priceConfigWorlds[world_id].startPrice then
			
			v = priceConfigWorlds[world_id].startPrice
			setGlobalStorageValue(gid.PREMIUM_VALUE, v)
		end

		v = v * 0.95
	end

	return v
end

local callbacks = {
	
	["/premiumvalue"] = function(cid, param)
		local oldvalue = getCurrentPrice(PREMIUM_TYPE_BUY)
		setGlobalStorageValue(gid.PREMIUM_VALUE, param)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You change the premium value from " .. oldvalue .. " to " .. param .. " gold coins.")
	end,

	["!buypremium"] = function(cid, param)

		local price = getCurrentPrice(PREMIUM_TYPE_BUY)

		if(param ~= "") then
			local code_value, code_ret = unpack(checkCode(cid, param))

			if(code_ret == CODE_NO_ERROR) then
				if(getPlayerMoney(cid) < price) then
					local msg = "You do not have enough gold coins. You have " .. getPlayerMoney(cid) .. " and " .. price .. " gold coins is needed."
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
				elseif getPlayerPremiumDays(cid) > BUY_DAYS then
					local msg = "You have too much premium days on this account. Only can buy more when left " .. BUY_DAYS .. " or less days."
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)					
				else
					registerHistory(cid, PREMIUM_TYPE_BUY, price)

					doPlayerAddPremiumDays(cid, BUY_DAYS)
					doPlayerRemoveMoney(cid, price)

					doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You bought " .. BUY_DAYS .. " days of premium account for " .. price .." gold coins.")
				end				
			else
				if(code_ret == CODE_EXPIRED or code_ret == CODE_NON_EXIST) then
					local msg = "For " .. price .. " gold coins you will buy " .. BUY_DAYS .. " days of premium account (you have " .. getPlayerMoney(cid) .. " gold coins)."
					msg = msg .. "\nTo confirm your purchase, type the following command: \"!buypremium " .. generateCode(cid) .. "\""
				elseif(code_ret == CODE_WRONG) then
					msg = "Wrong command. To confirm type \"!buypremium " .. code_ret .. "\""
				end

				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
			end	
		else
			local msg = "For " .. price .. " gold coins you will buy " .. BUY_DAYS .. " days of premium account."
			msg = msg .. "\nTo confirm your purchase, type the following command: \"!buypremium " .. generateCode(cid) .. "\""
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
		end
	end,

	["!sellpremium"] = function(cid, param)
		local price = getCurrentPrice(PREMIUM_TYPE_SELL)

		if(param ~= "") then
			local ret = checkCode(cid, param)
			local code_value, code_ret = unpack(ret)

			if(code_ret == CODE_NO_ERROR) then
				if(getPlayerPremiumDays(cid) <= SELL_DAYS + 5) then
					local msg = "You need have at least " .. SELL_DAYS + 5 .. " days of premium account to be able to do this. You have just " .. getPlayerPremiumDays(cid) .. " days."
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
				else
					registerHistory(cid, PREMIUM_TYPE_SELL, price)

					doPlayerAddPremiumDays(cid, -SELL_DAYS)
					doPlayerAddMoney(cid, price)
					
					doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You sold " .. SELL_DAYS .. " days of premium account for " .. price .." gold coins.")
				end				
			else
				if(code_ret == CODE_EXPIRED or code_ret == CODE_NON_EXIST) then
					local msg = "For " .. price .. " gold coins you will sell " .. SELL_DAYS .. " days of premium account."
					msg = msg .. "\nTo confirm your purchase, type the following command: \"!sellpremium " .. generateCode(cid) .. "\""
				elseif(code_ret == CODE_WRONG) then
					msg = "Wrong command. To confirm type \"!sellpremium " .. code_ret .. "\""
				end

				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
			end	
		else
			local msg = "For " .. price .. " gold coins you will sell " .. SELL_DAYS .. " days of premium account."
			msg = msg .. "\nTo confirm your purchase, type the following command: \"!sellpremium " .. generateCode(cid) .. "\""
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
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