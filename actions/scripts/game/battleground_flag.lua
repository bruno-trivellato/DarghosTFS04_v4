function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	local pos = table.copy(fromPosition)
	pos["stackpos"] = 0
	local ground = getThingFromPos(pos)
	local team = getPlayerBattlegroundTeam(cid)
	local enemy = getPlayerBattlegroundEnemies(cid)
	local teams = { "Time A", "Time B" }
	
	if(isInArray({uid.BATTLEGROUND_TEAM_ONE_FLAG_SPAWN, uid.BATTLEGROUND_TEAM_TWO_FLAG_SPAWN}, ground.uid)) then
		-- assumimos aqui que o jogador está dando use com a bandeira dentro da base
		
		local flagTeam = (item.uid == uid.BATTLEGROUND_TEAM_ONE_FLAG) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		
		if(flagTeam == enemy) then			
			onPlayerPickupFlag(cid, item.uid, true)
		else	
			if(doPlayerIsFlagCarrier(cid)) then
				
				local bgSecondsLeft = (getStorage(gid.BG_LAST_INIT) + BG_CONFIG_DURATION) - os.time()
				if(bgSecondsLeft <= 10) then
					doPlayerSendCancel(cid, "Você não pode mais entregar a bandeira, aguarde agora o fim da partida.")
					return true
				end
				
				local points = getBattlegroundTeamsPoints()
				points[team] = points[team] + 1
				
				setBattlegroundTeamsPoints(team, points[team])
				
				local msg = "[Battleground | (|TEAM_ONE|) |TEAM_ONE_POINTS| X |TEAM_TWO_POINTS| (|TEAM_TWO|)] |FLAG_CAPTURER| capturou a bandeira adversaria marcando um ponto pelo |FLAG_CAPTURER_TEAM|! A bandeira capturada ira reaparecer na base em 5 segundos..."
				
				msg = string.gsub(msg, "|TEAM_ONE|", teams[BATTLEGROUND_TEAM_ONE])
				msg = string.gsub(msg, "|TEAM_ONE_POINTS|", points[BATTLEGROUND_TEAM_ONE])
				msg = string.gsub(msg, "|TEAM_TWO|", teams[BATTLEGROUND_TEAM_TWO])
				msg = string.gsub(msg, "|TEAM_TWO_POINTS|", points[BATTLEGROUND_TEAM_TWO])
				msg = string.gsub(msg, "|FLAG_CAPTURER|", getPlayerName(cid) .. " (" .. getPlayerLevel(cid) .. ")")
				msg = string.gsub(msg, "|FLAG_CAPTURER_TEAM|", teams[team])
			
				pvpBattleground.sendPvpChannelMessage(msg, PVPCHANNEL_MSGMODE_INBATTLE)
				
				pvpBattleground.setPlayerCarryingFlagState(cid, BG_FLAG_STATE_CAPTURED)
                                doPlayerDropBgFlag(cid)
				
				addEvent(pvpBattleground.returnFlag, 1000 * 5, enemy)
			else
				doPlayerSendCancel(cid, "Você não pode capturar a sua propria bandeira! Capture a bandeira do time adversario e a traga até aqui!")
			end
		end
	
	else
		-- aqui está sendo dado use na bandeira em qualquer lugar do mapa
		
		local flagTeam = (item.uid == uid.BATTLEGROUND_TEAM_ONE_FLAG) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		
		if(flagTeam == enemy) then
			onPlayerPickupFlag(cid, item.uid, false)
		else
			local msg = "[Battleground | A bandeira do |TEAM| foi recuperada por |FLAG_RETURNER|! A bandeira ira reaparecer a base em 5 segundos..."
				
			msg = string.gsub(msg, "|TEAM|", teams[team])
			msg = string.gsub(msg, "|FLAG_RETURNER|", getPlayerName(cid) .. " (" .. getPlayerLevel(cid) .. ")")
		
			pvpBattleground.sendPvpChannelMessage(msg, PVPCHANNEL_MSGMODE_INBATTLE)
			
			pvpBattleground.setPlayerCarryingFlagState(cid, BG_FLAG_STATE_RETURNED)
			
			addEvent(pvpBattleground.returnFlag, 1000 * 5, team)
			
			doSendMagicEffect(fromPosition, CONST_ME_POFF)
			doRemoveItem(item.uid)
		end
	end
	
	return true
end

function onPlayerPickupFlag(cid, uid, inBase)
	
	local teams = { "Time A", "Time B" }
	local enemy = getPlayerBattlegroundEnemies(cid)
        
        if(not doPlayerCaptureBgFlag(cid)) then
            print("Error?")
        end
	
	local msg = "[Battleground] A bandeira do |TEAM| foi pega por |FLAG_CAPTURER| e está sendo levada para a base do time adversário!"
	
	if(not inBase) then		
		msg = "[Battleground] A bandeira do |TEAM| foi pega novamente por |FLAG_CAPTURER| e está sendo levada para a base do time adversário!"		
	end
	
	msg = string.gsub(msg, "|TEAM|", teams[enemy])
	msg = string.gsub(msg, "|FLAG_CAPTURER|", getPlayerName(cid) .. " (" .. getPlayerLevel(cid) .. ")")
	
	pvpBattleground.sendPvpChannelMessage(msg, PVPCHANNEL_MSGMODE_INBATTLE)
	
	pvpBattleground.setPlayerCarryingFlagState(cid, BG_FLAG_STATE_CARRYING)

        local pos = getThingPosition(uid)
	doRemoveItem(uid)
        
        if(inBase) then
            doCreateItem(BATTLEGROUND_STONE_SPAWN_ID, pos)
        end
end