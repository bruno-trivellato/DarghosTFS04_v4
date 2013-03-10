function onSay(cid, words, param)

	local _access = getPlayerAccess(cid)

	if(param == "") then
	
		local msg = "O uso deste comando requer um ou mais parametros. Exemplos:\n"
		--msg = msg .. "!dungeon sobre, !dungeon info, !dungeon help -> Exibe informações sobre o sistema de Battlegrounds.\n"
	
		if(_access >= access.COMMUNITY_MANAGER) then
			-- special CM dungeon commands...
		else
			msg = msg .. "!dungeon city -> Teletransporta o jogador para a sua cidade natal.*\n"
			msg = msg .. "!dungeon entrance -> Teletransporta o jogador para a entrada da Dungeon.*\n"
		end
	
		msg = msg .. "\n * = Requer estar dentro de uma dungeon."	
	
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
		return TRUE
	end
	
	local explode = string.explode(param, " ", 1)
	
	option = explode[1]
	param = explode[2] or nil
	
	msg = ""
	
	if(isInArray({"city"}, option)) then		
		Dungeons.onTeleportCity(cid)
	elseif(isInArray({"entrance"}, option)) then
		Dungeons.onTeleportEntrance(cid)
	end
	
	return true
end
