local expDays = 60 * 60 * 24 * 2
local expBonus = 50
local vipDays = 7

function onSay(cid, words, param)

	if(param == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You need to type a nick name as parameter.")
		return true
	end

	local player = getPlayerByNameWildcard(param)

	if(not player) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Personagem com nick " .. param .. " não existe ou não esta online.")
		return true				
	end

	local date = tonumber(getPlayerStorageValue(player, sid.EXP_MOD_ESPECIAL_END))
	if(date and date > os.time()) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Personagem com nick " .. param .. " já esta com este beneficio ativo.")
		return true			
	end

	setPlayerStorageValue(player, sid.EXP_MOD_ESPECIAL, expBonus)
	setPlayerStorageValue(player, sid.EXP_MOD_ESPECIAL_END, os.time() + expDays)
	setStageType(player, SKILL__LEVEL)
	doPlayerAddVipDays(player, vipDays)
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O personagem " .. param .. " recebeu o exp bonus de " .. expBonus .. "% pelos proximos 2 dias além de 7 dias de VIP.")	
	return true
end