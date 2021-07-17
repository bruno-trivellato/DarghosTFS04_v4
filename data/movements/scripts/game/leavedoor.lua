function onStepIn(cid, item, position, fromPosition)

	local newPosition = {x = position.x, y = position.y, z = position.z}
	if(isInArray(verticalOpenDoors, item.itemid)) then
		if(fromPosition.x > position.x) then
			dir = WEST
		else
			dir = EAST
		end
	else
		if(fromPosition.y > position.y) then
			dir = NORTH
		else
			dir = SOUTH
		end
	end

	doMoveCreature(cid, dir)
	return true
end