function onStepIn(cid, item, position, fromPosition)
		
	local isInside = getPlayerStorageValue(cid, sid.INSIDE_MINI_GAME) == 1
	
	if(not isInside) then
		
		setPlayerStorageValue(cid, sid.INSIDE_MINI_GAME, 1)
	else
		
		setPlayerStorageValue(cid, sid.INSIDE_MINI_GAME, -1)
	end
	
	return true
end
