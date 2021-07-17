function onPush(cid, target)

	if(isPlayer(cid) and isPlayer(target)) then	
		local tile = getTileInfo(getCreaturePosition(cid))
		if(tile.optional) then		
			local attacked = getCreatureTarget(target)
			if(getBooleanFromString(attacked) and isInArray({"Marksman Target", "Hitdoll"}, getCreatureName(attacked))) then
				doPlayerSendCancel(cid, "Não o encomode! Ele está treinando concentradamente!")	
				return false
			end
		end	
	end
	
	return true
end