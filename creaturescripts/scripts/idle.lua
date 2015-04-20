local config = {
	idleWarning = getConfigValue('idleWarningTime'),
	idleKick = getConfigValue('idleKickTime')
}

local bgConfig = {
	idleWarning = (60 + 30) * 1000,
	idleKick = 2 * 60 * 1000
}

function onThink(cid, interval)
    
        if(not isPlayer(cid)) then
            return true
        end
    
	if((getTileInfo(getCreaturePosition(cid)).nologout or getCreatureNoMove(cid) or
		getPlayerCustomFlagValue(cid, PLAYERCUSTOMFLAG_ALLOWIDLE) 
		or getPlayerCustomFlagValue(cid, PLAYERCUSTOMFLAG_CONTINUEONLINEWHENEXIT))
		and not doPlayerIsInBattleground(cid)
		) then
		--or doPlayerGetAfkState(cid)) then
		return true
	end
	
	if(doPlayerIsInBattleground(cid) and hasCondition(cid, CONDITION_INFIGHT)) then
		return true
	end
	
	local idleTime = getPlayerIdleTime(cid) + interval
	doPlayerSetIdleTime(cid, idleTime)
	
	if(doPlayerIsInBattleground(cid)) then
	
		if(getBattlegroundStatus() == BATTLEGROUND_STATUS_PREPARING) then
			doPlayerSetIdleTime(cid, 0)
		elseif(getBattlegroundStatus() == BATTLEGROUND_STATUS_STARTED) then
			if(bgConfig.idleKick > 0 and idleTime > bgConfig.idleKick) then
				pvpBattleground.onExit(cid, true)
			elseif(bgConfig.idleWarning > 0 and idleTime == bgConfig.idleWarning) then
				local message = "Você esta inativo a " .. bgConfig.idleWarning / 1000 .. " segundos. Você sera expulso da batalha e marcado como desertor se continuar inativo por mais " .. (bgConfig.idleKick - bgConfig.idleWarning) / 1000 .. " segundos"	
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, message .. ".")
			end		
		end
	else
		if(config.idleKick > 0 and idleTime > config.idleKick) then
			doRemoveCreature(cid)
		elseif(config.idleWarning > 0 and idleTime == config.idleWarning) then
			local message = "You have been idle for " .. math.ceil(config.idleWarning / 60000) .. " minutes"
			if(config.idleKick > 0) then
				message = message .. ", you will be disconnected in "
				local diff = math.ceil((config.idleWarning - config.idleKick) / 60000)
				if(diff > 1) then
					message = message .. diff .. " minutes"
				else
					message = message .. "one minute"
				end
	
				message = message .. " if you are still idle"
			end
	
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, message .. ".")
		end
	end

	return true
end
