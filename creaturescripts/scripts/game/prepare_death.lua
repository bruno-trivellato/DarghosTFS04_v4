function onPrepareDeath(cid, deathList)
	
	if(isPlayer(cid)) then
	
		if(doRoyalBlessIsEnable()) then
			return useRoyalBless(cid)
		end

		if doPlayerDieOnDarkGeneral(cid) then
			return false
		end
	
		--local isInside = getPlayerStorageValue(cid, sid.INSIDE_MINI_GAME) == 1
		
		--if(isInside) then			
		--	setPlayerStorageValue(cid, sid.INSIDE_MINI_GAME, -1)
		--end
		
		
		--Dungeons.onPlayerDeath(cid)		
	end
	
	return true
end

function useRoyalBless(cid)
	
	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
	doRemoveCreature(cid, true)
	
	return false
end