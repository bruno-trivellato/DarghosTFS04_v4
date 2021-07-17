local function isInSeaSerpentsArea(pos)
	local spawnarea = {
		xmin = 2060,
		xmax = 2180,
		ymin = 1115,
		ymax = 1210,
		zmin = 8,
		zmax = 10
	}

	if(pos.z >= spawnarea.zmin and pos.z <= spawnarea.zmax) then
		if(pos.x >= spawnarea.xmin and pos.x <= spawnarea.xmax and pos.y >= spawnarea.ymin and pos.y <= spawnarea.ymax) then
			return true
		end
	end

	
	return false
end

function onThink(cid, interval)
	if(not isCreature(cid) or not isPlayer(cid)) then
		return
	end
	
    local helmet = getPlayerSlotItem(cid, CONST_SLOT_HEAD)
    if helmet.uid ~= 0 then 
    	if helmet.itemid == 12541 and not isInSeaSerpentsArea(getPlayerPosition(cid)) then
			doTransformItem(helmet.uid, 5461)
		elseif helmet.itemid == 5461 and isInSeaSerpentsArea(getPlayerPosition(cid)) then
			doTransformItem(helmet.uid, 12541)
		end
    end
end
