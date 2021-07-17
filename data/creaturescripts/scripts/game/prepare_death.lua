function onPrepareDeath(cid, deathList)
	
	if(isPlayer(cid)) then
	
		if(doRoyalBlessIsEnable()) then
			return useRoyalBless(cid)
		end

		if doPlayerDieOnDarkGeneral(cid) then
			return false
		end

		if doPlayerDieOnAncientNature(cid) then
			return false
		end		

		if doPlayerDieOnBking(cid) then
			return false
		end		
	
		--local isInside = getPlayerStorageValue(cid, sid.INSIDE_MINI_GAME) == 1
		
		--if(isInside) then			
		--	setPlayerStorageValue(cid, sid.INSIDE_MINI_GAME, -1)
		--end
		
		
		Dungeons.onPlayerDeath(cid)		
	end
	
	return true
end

function luaDeath(cid)

	doCreatureAddHealth(cid, getCreatureMaxHealth(cid), nil, nil, true)
	doCreatureAddMana(cid, getCreatureMaxMana(cid), false)
	doRemoveConditions(cid, false)

	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
end

function useRoyalBless(cid)
	
	luaDeath(cid)
	return false
end