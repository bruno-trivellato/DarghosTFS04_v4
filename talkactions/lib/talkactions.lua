-- Nothing --

summonRequests = {
}

function createSummonRequest(cid, target)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You create a request to teleport " .. getPlayerName(target) .. " successfully. Now he need accept it.")
	doPlayerSendTextMessage(target, MESSAGE_STATUS_CONSOLE_BLUE, "ATENÇÃO: " .. getPlayerName(cid) .. " deseja convocar você em sua tela. Digite \"!aceitotp\" para fazer isto.")

	table.insert(summonRequests, target, cid)
end

function completeSummonRequest(cid)

	local requestBy = summonRequests[cid]
	if(requestBy == nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Não há nenhuma solicitação de convocação para você em andamento.")
		return false
	end
	
	if(not isPlayer(requestBy)) then
		summonRequests[requestBy] = nil
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O membro da staff não se encontra mais online. Sua convocação foi cancelada.")
		return false
	end
	
	if(isPlayerPzLocked(cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você está com o status de pz-blocked.")
		return false	
	end
	
	if(not doSummonCreatureNear(requestBy, cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Impossivel concluir a convocação...")
	end
	
	summonRequests[cid] = nil
	return true
end

function doSummonCreatureNear(cid, target)

	local pos = getClosestFreeTile(target, getCreaturePosition(cid), false, false)
	if(not pos or isInArray({pos.x, pos.y}, 0)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Cannot perform action.")
			return false
	end

	local tmp = getCreaturePosition(target)
	if(doTeleportThing(target, pos, true) and not isPlayerGhost(target)) then
		doSendMagicEffect(tmp, CONST_ME_POFF)
		doSendMagicEffect(pos, CONST_ME_TELEPORT)
		
		return true
	end	
	
	return false
end