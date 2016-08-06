local SWITCHES = { {416, 417}, {426, 425}, {446, 447}, {3216, 3217} }

local function doTransformTile(item)
	for i, v in pairs(SWITCHES) do
		if(item.itemid == v[1]) then
			return doTransformItem(item.uid, v[2])
		elseif(item.itemid == v[2]) then
			return doTransformItem(item.uid, v[1])
		end
	end
end

function onStepIn(cid, item, position, fromPosition)

	if(isPlayer(cid) == TRUE) then
		if(item.itemid == 1387) then
			if(item.uid == item.actionid) then
				return Dungeons.onPlayerEnter(cid, item, position)
			else
				return Dungeons.onPlayerLeave(cid, item)
			end	
		else	
			doTransformTile(item)
			local dungeonInfo = dungeonList[item.actionid]
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "ATENÇÃO: Isto é uma Dungeon, para entrar é necessário estar em uma party de " .. dungeonInfo.maxPlayers .. " jogadores e o primeiro a entrar deve ser o lider. Atenção, pois ao atravessar esta porta, uma vez do outro lado é IMPOSSIVEL voltar, e você terá dois destinos: Ou concluir o desafio, ou irá morrer e poderá tentar novamente. O limite de tempo para concluir esta Dungeon é de " .. dungeonInfo.maxTimeIn .. " minutos!")
		end
	end
	
	return TRUE
end

function onStepOut(cid, item, pos)
	doTransformTile(item)
	return TRUE
end 