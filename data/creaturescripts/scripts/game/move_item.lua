function checkMoveBlockPatchItem(cid, item, isGround)
	isGround = isGround or false
	
	local thing = getPlayerByGUID(getItemAttribute(item.uid, "dropGroundBy"))
	if(thing ~= nil and (not doPlayerIsPvpEnable(cid) and getDistanceBetween(getPlayerPosition(cid), getPlayerPosition(thing)) <= 10)) then
		doPlayerSendCancel(cid, "Você não pode mover um item deste tipo colocado no chão por um jogador Agressivo enquanto ele estiver por perto.")
		return false
	else
		if(isGround and doPlayerIsPvpEnable(cid)) then
			doItemSetAttribute(item.uid, "dropGroundBy", getPlayerGUID(cid))
		else
			doItemEraseAttribute(item.uid, "dropGroundBy")
		end
	end	
	
	return true
end

function onMoveItem(cid, item, fromPosition, position)

	if(isOnContainer(position)) then
	
		if(not isOnSlot(position)) then
			return onMoveContainerItem(cid, item, position.z)
		else
			return onMoveSlotItem(cid, item, position.y)
		end		
	end
	
	return onMoveGroundItem(cid, item, position)
end

SOULBOUND_ITEMS = { 2392 }

function onMoveGroundItem(cid, item, position)

	--[[
	local isSoulBound = isInArray(SOULBOUND_ITEMS, item.itemid)
	if(isSoulBound) then
		doPlayerSendCancel(cid, "Este item foi preso a sua alma pelos Deuses, você não pode o colocar em lugares que ele possa ser pegado por alguém.")
		return false
	end
	--]]

	if(getTileInfo(position).depot) then
		local dist = getDistanceBetween(getPlayerPosition(cid), position)
		if(depotBusy(position) and dist > 1) then			
			doPlayerSendCancel(cid, "Você não pode jogar um item no depot de outra pessoa.")
			return false
		end
	elseif(getTileInfo(position).house) then
		local house_id = getHouseFromPos(position)
		
		local accessLevel = getHouseAccessLevel(house_id, cid)
		if(accessLevel == HOUSE_ACCESS_NOT_INVITED) then
			doPlayerSendCancel(cid, "Você precisa estar convidado para entrar nesta casa para poder jogar itens dentro dela.")
			return false		
		end
	elseif(not getItemAttribute(item.uid, "dropGroundByPacified") and not doPlayerIsPvpEnable(cid) and isOnGround(position)) then
		doItemSetAttribute(item.uid, "dropGroundByPacified", true)
	end
	
	local tileInfo = getTileInfo(position)
	if(not getItemAttribute(item.uid, "dropGroundBy")) then
		if(doPlayerIsPvpEnable(cid) and (not tileInfo.protection and not tileInfo.optional and not tileInfo.house and not tileInfo.depot) and getItemInfo(item.itemid).blockPathing) then
			doItemSetAttribute(item.uid, "dropGroundBy", getPlayerGUID(cid))
		end
	else
		local ret = checkMoveBlockPatchItem(cid, item, true)
		if(not ret) then
			return false
		end
	end	
	
	return true
end

function depotBusy(position)

	local _pos = table.copy(position)
	_pos.x = _pos.x + 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end
	
	_pos = table.copy(position)
	_pos.x = _pos.x - 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end	
	
	_pos = table.copy(position)
	_pos.y = _pos.y + 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end
	
	_pos = table.copy(position)
	_pos.y = _pos.y - 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end	

	return false
end

function onMoveContainerItem(cid, item, containerPos)

	if(getItemAttribute(item.uid, "dropGroundByPacified")) then
		if(doPlayerIsPvpEnable(cid) and hasCondition(cid, CONDITION_INFIGHT)) then
			doPlayerSendCancel(cid, "Você não pode pegar um item colocado no chão por um jogador Pacifico enquanto estiver em combate.")
			return false
		else
			doItemSetAttribute(item.uid, "dropGroundByPacified", false)
		end
	end
	
	local ret = checkMoveBlockPatchItem(cid, item)
	if(not ret) then
		return false
	end

	return true
end

function onMoveSlotItem(cid, item, slot)

	if(getItemAttribute(item.uid, "dropGroundByPacified")) then
		if(doPlayerIsPvpEnable(cid) and hasCondition(cid, CONDITION_INFIGHT)) then
			doPlayerSendCancel(cid, "Você não pode pegar um item colocado no chão por um jogador Pacifico enquanto estiver em combate.")
			return false
		else
			doItemSetAttribute(item.uid, "dropGroundByPacified", false)
		end
	end

	local ret = checkMoveBlockPatchItem(cid, item)
	if(not ret) then
		return false
	end
	
	--[[
	local isSoulBound = isInArray(SOULBOUND_ITEMS, item.itemid)
	if(isSoulBound) then
		if(slot == CONST_SLOT_RIGHT or slot == CONST_SLOT_LEFT) then
			doItemEraseAttribute(item.uid, "attack")
			doItemSetAttribute(item.uid, "attack", 81)
		end
	end
	--]]

	return true
end
