function onSay(cid, words, param)
	local playerPos = getPlayerPosition(cid)

	if(param == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You need to type the parameter.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true
	else
		param = string.explode(param, ",")
	end

	local player = getCreatureByName(param[1])
	local expBonus = tonumber(param[2]) or nil
	local expBonusHours = tonumber(param[3]) or nil
	
	if(player == 0 or expBonus == nil or expBonusHours == nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Comando errado, tente. Ex: '/specialexp Slash,100,12' aonde slash e  nome, 100 e a quantidade de exp bonus e 12 e a quantidade de horas.")
		doSendMagicEffect(playerPos, CONST_ME_POFF)
		return true			
	end
	
	setPlayerStorageValue(player, sid.EXP_MOD_ESPECIAL, expBonus)
	setPlayerStorageValue(player, sid.EXP_MOD_ESPECIAL_END, os.time() + 60 * 60 * expBonusHours)
	setStageType(player, SKILL__LEVEL)
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O jogador " .. getPlayerName(player) .. " recebeu o exp bonus de " .. expBonus .. "% pelas proximas " .. expBonusHours .. " horas.")

	return true
end
