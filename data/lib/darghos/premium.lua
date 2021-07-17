PREMIUM_TYPE_BUY = 0
PREMIUM_TYPE_SELL = 1

priceConfigWorlds = {	
	[WORLD_ANTINUM] = { startPrice = 1000000, increase = math.random(200, 250), decrease = math.random(800, 1000) }
	,[WORLD_NOVIUM] = { startPrice = 300000, increase = math.random(66, 83), decrease = math.random(264, 332) }
}

function addPremiumTest(cid)

	doPlayerAddPremiumDays(cid, darghos_premium_test_quanty)
	local account = getPlayerAccountId(cid)
	db.executeQuery("INSERT INTO `wb_premiumtest` VALUES ('" .. account .. "', '" .. os.time() .. "');")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Parabens! Você recebeu 10 dias de conta premium no Darghos gratuitamente! Aproveite e divirta-se!")
	sendEnvolveEffect(cid, CONST_ME_HOLYAREA)
end

function canReceivePremiumTest(cid, newlevel, checkEmail)

	checkEmail = checkEmail or true

	if(darghos_premium_test_level == 0 or newlevel < darghos_premium_test_level) then
		return false
	end	

	if(isPremium(cid)) then
		return false
	end

	local account = getPlayerAccountId(cid)
	
	local result = db.getResult("SELECT COUNT(*) as `rowscount` FROM `wb_premiumtest` WHERE `account_id` = '" .. account .. "';")
	if(result:getID() == -1) then
		--print("[Spoofing] Players list not found.")
		return false
	end

	local rowscount = result:getDataInt("rowscount")
	result:free()		
	
	if(rowscount > 0) then
		return false
	end
	
	if checkEmail then
		if(not hasValidEmail(cid)) then
			return false
		end
	end
	
	return true
end

function getCurrentPremiumPrice(type)

	local v
	local world_id = getConfigValue('worldId')

	if type == PREMIUM_TYPE_BUY then
		v = getGlobalStorageValue(gid.PREMIUM_VALUE)

		if v < priceConfigWorlds[world_id].startPrice then
			v = priceConfigWorlds[world_id].startPrice
			setGlobalStorageValue(gid.PREMIUM_VALUE, v)
		end
		
	elseif type == PREMIUM_TYPE_SELL then
		v = getGlobalStorageValue(gid.PREMIUM_VALUE) * 4

		if v < priceConfigWorlds[world_id].startPrice then
			
			v = priceConfigWorlds[world_id].startPrice
			setGlobalStorageValue(gid.PREMIUM_VALUE, v)
		end

		v = v * 0.95
	end

	return v
end