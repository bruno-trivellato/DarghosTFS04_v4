function onSay(cid, words, param)
	
	if not getWorldConfig("change_pvp_allowed") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Comando desativado para este mundo.")		
		return true
	end

	local tile = getTileInfo(getCreaturePosition(cid))
	if not tile.protection then	
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Para usar este comando você precisa estar em uma area protegida como templo ou depot.")		
		return true
	end

	local lastChange = tonumber(getPlayerStorageValue(cid, sid.LAST_CHANGE_PVP))

	if lastChange > 0 and os.time() <= lastChange + (60 * 60 * 24 * 3) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você já fez uma mudança de PvP recentemente. Você poderá mudar novamente em: " .. os.date("%a %b %d %X %Y", lastChange + (60 * 60 * 24 * 3)) )		
		return true		
	end

	if(doPlayerIsPvpEnable(cid)) then
		doPlayerDisablePvp(cid)
		msg = "O seu PvP foi desativado!"
		doSendAnimatedText(getPlayerPosition(cid), "PvP OFF!", TEXTCOLOR_PURPLE)
	else
		doPlayerEnablePvp(cid)
		msg = "O seu PvP está ativado!"
		doSendAnimatedText(getPlayerPosition(cid), "PvP ON!", TEXTCOLOR_PURPLE)
	end

	setPlayerStorageValue(cid, sid.LAST_CHANGE_PVP, os.time())
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)

	return true
end
