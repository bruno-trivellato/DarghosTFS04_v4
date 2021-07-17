function onStepIn(cid, item, position, fromPosition)

	if(item.actionid >= ACTION_ID_RANGES.MIN_FIELD_DAMAGE and item.actionid <= ACTION_ID_RANGES.MAX_FIELD_DAMAGE and isPlayer(cid)) then
	
		local playerTotems = 0
		
		for key, value in ipairs(sid.ARIADNE_TOTEMS) do
		
			local totemStatus = getPlayerStorageValue(cid, sid.ARIADNE_TOTEMS[key])
			
			if(totemStatus == 1) then
			
				playerTotems = playerTotems + 1
			end		
		end	
		
		if(playerTotems == 12) then
		
			doPlayerAddHealth(cid, -10)
			
			doSendMagicEffect(position, CONST_ME_HITBYPOISON)	
			doSendMagicEffect(position, CONST_ME_POISONAREA)	
			
			return TRUE			
		end
	
		local needDamagePlayer = getPlayerStorageValue(cid, ACTION_ID_RANGES.MIN_FIELD_DAMAGE)
		
		if(needDamagePlayer <= 5) then
			
			local damage = item.actionid - ACTION_ID_RANGES.MIN_FIELD_DAMAGE
			
			if(damage == 0) then
				doPlayerAddHealth(cid, -600)
			elseif(damage == 1) then
				doPlayerAddHealth(cid, -1400)	
			elseif(damage == 2) then
				doPlayerAddHealth(cid, -3100)	
			elseif(damage == 3) then
				doPlayerAddHealth(cid, -6500)	
			elseif(damage == 4) then
				doPlayerAddHealth(cid, -14000)	
			elseif(damage >= 5) then
				doPlayerAddHealth(cid, -40000)	
			end		

			doSendMagicEffect(position, CONST_ME_HITBYPOISON)	
			doSendMagicEffect(position, CONST_ME_POISONAREA)	
			
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você não tem as doze benções de Ghazran!!")
		end
	end
	
	return TRUE
end
