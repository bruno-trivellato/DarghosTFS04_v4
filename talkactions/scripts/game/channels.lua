function onSay(cid, words, param, channel, type)

	if(wordsIsSpell(words .. " " .. param)) then
		local attacked = getCreatureTarget(cid)
		if(getBooleanFromString(attacked) and isInArray({"Marksman Target", "Hitdoll"}, getCreatureName(attacked))) then
			doPlayerSendCancel(cid, "You dont need cast spells to get magic level while training.")
			return true
		end	
	
		return false
	end

	if(channel == CHANNEL_HELP) then
		return help.onSay(cid, words, param, channel)
	elseif(channel == CUSTOM_CHANNEL_PVP or channel == CUSTOM_CHANNEL_BG_CHAT) then
		return pvp.onSay(cid, words, param, channel)
	end
end

pvp = {}

function pvp.onSay(cid, words, param, channel)
	
	if(getPlayerAccess(cid) == ACCESS_PLAYER) then
		if(channel == CUSTOM_CHANNEL_BG_CHAT) then
			if(pvpBattleground.playerSpeakTeam(cid, words .. " " .. param)) then
				return true			
			else
				doPlayerSendCancel(cid, "Não é permitido a jogadores fora da battleground enviarem mensagens por este canal. Para entrar em uma partida digite \"!bg entrar\"")
				return true
			end	
		elseif(channel == CUSTOM_CHANNEL_PVP) then
			doPlayerSendCancel(cid, "Não é permitido enviar mensagens neste canal. Para entrar em uma Battleground digite \"!bg entrar\"")
			return true		
		end
	end

	return false
end

help = {}

local HELP_EXHAUSTED = 15 -- segundos

function help.onSay(cid, words, param, channel)
	
	local banExpires = getPlayerStorageValue(cid, sid.BANNED_IN_HELP)
	local lastMessage = getPlayerStorageValue(cid, sid.LAST_HELP_MESSAGE)
	
	if(getPlayerAccess(cid) == ACCESS_PLAYER and lastMessage ~= STORAGE_NULL and lastMessage + HELP_EXHAUSTED >= os.time()) then
		doPlayerSendCancel(cid, "You can send messages in this channel only every 15 seconds.")
		return true	
	end
	
	if(banExpires ~= STORAGE_NULL and banExpires >= os.time()) then
		doPlayerSendCancel(cid, "You are banned from this channel until " .. os.date("%d/%m/%Y - %X", banExpires) .. ".")
		return true
	else
		setPlayerStorageValue(cid, sid.LAST_HELP_MESSAGE, os.time())
	end

	return false
end