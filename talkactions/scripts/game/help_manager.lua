function onSay(cid, words, param)
	local playerPos = getPlayerPosition(cid)

	if(param == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You need to type the parameter.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true
	end

	local configs = {
	
		player_name = {
			key = "-p"
			,value = ""
			,help = "O nome do jogador."
		}
		,ban_action = {
			key = "-a"
			,value = "ban"
			,expectedValues = { "ban", "desban" }
			,help = "A ação a ser feita [ban ou desban] (padrão ban)."
		}
		,ban_duration = {
			key = "-d"
			,value = 24
			,expectedType = "numeric"
			,help = "A duração da ban (padrão 24 horas)."
		}
		,ban_reason = {
			key = "-r"
			,value = ""
			,help = "Motivo da punição."
		}	
	}
	
	local code, result = parseTalkactionParameters(configs, param)
	
	if(code == TALK_PARAMS_CALL_HELP) then
		local str = getHelpMessage(words, configs)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true
	end
	
	if(code == TALK_PARAMS_WRONG_EXPECTED_VALUE or code == TALK_PARAMS_WRONG_PARAMETER) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, result)
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true
	end
	
	configs = result
	
	if(getPlayerAccess(cid) >= access.GAME_MASTER and configs.ban_reason.value == "") then
		configs.ban_reason.value = "Conduta inapropriada obvia."
	end
	
	if(getPlayerAccess(cid) <= access.GAME_MASTER and configs.ban_duration.value > 24) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apénas Game Masters podem aplicar banições no Help superiores a 24h.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true		
	end
		
	local player = getCreatureByName(configs.player_name.value)
	
	if(not player) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Jogador " .. configs.player_name.value .. "não encontrado ou não está online.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)		
		return true
	end
	
	if(configs.ban_reason.value == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "É preciso descriminar uma razão para tal punição.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)		
		return true
	end
	
	if(configs.ban_action.value == "ban") then
		setPlayerStorageValue(player, sid.BANNED_IN_HELP, os.time() + (60 * 60 * configs.ban_duration.value))
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O jogador " .. getCreatureName(player) .. " foi bloqueado de postar no help  por " .. configs.ban_duration.value .. " horas com sucesso!")
		broadcastChannel(CHANNEL_HELP, "O jogador " ..  getCreatureName(player) .. " foi proibido de postar neste canal durante " .. configs.ban_duration.value .. " horas pelo motivo:\n" .. configs.ban_reason.value)
	elseif(configs.ban_action.value == "desban") then
		setPlayerStorageValue(player, sid.BANNED_IN_HELP, -1)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O jogador " .. getCreatureName(player) .. " foi desbloqueado e pode postar no help novamente.")
	end

	return true
end
