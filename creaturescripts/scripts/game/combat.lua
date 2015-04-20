local function bgWallOnCombat(cid, target)

	local enemy = (getPlayerBattlegroundTeam(cid) == BATTLEGROUND_TEAM_ONE) and getStorage(gid.WALL_CID_TEAM_TWO) or getStorage(gid.WALL_CID_TEAM_ONE) 
	local isEnemyWall = target == enemy
	if(not isEnemyWall) then
		return false
	end
	
	return true
end

local monsterCallbacks = { 
	["bg_wall"] = {callback = bgWallOnCombat}
}

function onCombat(cid, target)

	if(isPlayer(cid) and doPlayerIsInBattleground(cid)) then
	
		--checks target
		local player_target = nil
		if(isPlayer(target) == TRUE) then
			player_target = target
		elseif(isPlayer(getCreatureMaster(target)) == TRUE) then
			player_target = getCreatureMaster(target)
		end	
		
		if(player_target and isBattlegroundEnemies(cid, player_target)) then
			setPlayerStorageValue(cid, sid.BATTLEGROUND_LAST_DAMAGE, os.time())
			setPlayerStorageValue(cid, sid.BATTLEGROUND_LONG_TIME_PZ, 0)
			setPlayerStorageValue(cid, sid.BATTLEGROUND_PZTICKS, 0)			
		end
		
		local wallCids = {
			[getStorage(gid.WALL_CID_TEAM_ONE)] = "Time A",
			[getStorage(gid.WALL_CID_TEAM_TWO)] = "Time B"
		}		
	end
	
	if(isMonster(target)) then
		if(monsterCallbacks[string.lower(getCreatureName(target))] ~= nil) then
			return monsterCallbacks[string.lower(getCreatureName(target))].callback(cid, target)
		end		
	end

	--checks attacker
	if(server_distro == DISTROS_OPENTIBIA) then
		if(isPlayer(cid) == TRUE and isMonster(target) and (getCreatureName(target) == "Marksman Target" or getCreatureName(target) == "Hitdoll")) then
			startShieldTrain(cid, target)
		end	
	
		local player_attacker = nil
		if(isPlayer(cid) == TRUE) then
			player_attacker = cid
		elseif(isPlayer(getCreatureMaster(cid)) == TRUE) then
			player_attacker = getCreatureMaster(cid)
		end
	
		--checks target
		local player_target = nil
		if(isPlayer(target) == TRUE) then
			player_target = target
		elseif(isPlayer(getCreatureMaster(target)) == TRUE) then
			player_target = getCreatureMaster(target)
		end
	
		if(player_attacker ~= nil and player_target ~= nil) then	
			if(getPlayerTown(player_attacker) == towns.ISLAND_OF_PEACE or
			   getPlayerTown(player_target) == towns.ISLAND_OF_PEACE) then
				return false
			end
		end
	end

	return true
end