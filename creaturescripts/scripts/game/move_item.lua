function checkMoveBlockPatchItem(cid, item, isGround)
	isGround = isGround or false
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

	return true
end

function onMoveSlotItem(cid, item, slot)

	return true
end
