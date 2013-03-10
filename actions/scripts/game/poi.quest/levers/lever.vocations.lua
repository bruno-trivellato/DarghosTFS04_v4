function onUse(cid, item, fromPosition, itemEx, toPosition)

	local FIREWALL_ID = 6289

	-- O indice do array configs é a aid da lever
	local configs = {
	
		[aid.POI_LEVER_SORCERER] = {
			vocation = 1,
			uid_remove = uid.POI_FIREBLOCK_1
		},
	
		[aid.POI_LEVER_DRUID] = {
			vocation = 2,
			uid_remove = uid.POI_FIREBLOCK_2
		},	
		
		[aid.POI_LEVER_PALADIN] = {
			vocation = 3,
			uid_remove = uid.POI_FIREBLOCK_3
		},	
		
		[aid.POI_LEVER_KNIGHT] = {
			vocation = 4,
			uid_remove = uid.POI_FIREBLOCK_4
		}
		
	}

	
	local config = configs[item.actionid]
	
	if(config ~= nil) then
		
		if(config.vocation == getPlayerBaseVocation(cid)) then		
			local firePos = getThingPosition(config.uid_remove)
			firePos.stackpos = 1
			
			local fireWall = getTileThingByPos(firePos)
			
			if(fireWall ~= nil and fireWall.itemid == FIREWALL_ID) then
				doRemoveItem(fireWall.uid, 1)	
			else
				doCreateItem(FIREWALL_ID, 1, firePos)
			end
			
		end
		
	end


end

