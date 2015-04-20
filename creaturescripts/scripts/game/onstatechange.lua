local wallStatus = {}
local function bgWallStatChangeCallback(cid, attacker, type, combat, value)

	local wallCids = {
		[getStorage(gid.WALL_CID_TEAM_ONE)] = "Time A",
		[getStorage(gid.WALL_CID_TEAM_TWO)] = "Time B"
	}
	
	local messages = {
		{percent = 90, message = "O muro que protege a bandeira do |team| está sob ataque inimigo!"},
		{percent = 50, message = "O muro que protege a bandeira do |team| já está bastante danificado! Protejam a bandeira!"},
		{percent = 20, message = "O muro que protege a bandeira do |team| está quase no chão! A segurança da bandeira esta em apuros!"}
	}	
	
	if(wallCids[cid]) then	
		if(not wallStatus[cid]) then
			wallStatus[cid] = 1
		end	
	
		if(getCreatureHealth(cid) - value > 0) then
			local lifePercent = math.floor((getCreatureHealth(cid) * 100) / getCreatureMaxHealth(cid))
			if(not messages[wallStatus[cid]]) then
				return
			end
			
			if(wallStatus[cid] <= #messages and lifePercent <= messages[wallStatus[cid]].percent) then
				local rep = string.gsub(messages[wallStatus[cid]].message, "|team|", wallCids[cid])
				pvpBattleground.sendPvpChannelMessage("[Battleground] " .. rep, PVPCHANNEL_MSGMODE_INBATTLE)
				wallStatus[cid] = wallStatus[cid] + 1
			end
		else
			pvpBattleground.sendPvpChannelMessage("[Battleground] O muro que protegia a bandeira do " .. wallCids[cid] .. " foi derrubada! A bandeira está vulneravel!", PVPCHANNEL_MSGMODE_INBATTLE)
			pvpBattleground.removeWall((wallCids[cid] == "Time A") and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO)
			wallStatus[cid] = nil		
		end
	end
end

local monsterCallbacks = { 
	["bg_wall"] = {callback = bgWallStatChangeCallback}
}

function onStatsChange(cid, attacker, type, combat, value)

	if(isMonster(cid)) then
		if(monsterCallbacks[string.lower(getCreatureName(cid))] ~= nil) then
			monsterCallbacks[string.lower(getCreatureName(cid))].callback(cid, attacker, type, combat, value)
		end
	end
	
	if(isPlayer(attacker) and doPlayerIsInBattleground(attacker)) then
		if(type == STATSCHANGE_MANALOSS or type == STATSCHANGE_HEALTHLOSS) then
			pvpBattleground.onDealDamage(attacker, value)
		elseif(type == STATSCHANGE_HEALTHGAIN and getCreatureHealth(cid) < getCreatureMaxHealth(cid)) then
			local healed = math.min(getCreatureMaxHealth(cid) - getCreatureHealth(cid), value)
			pvpBattleground.onDealHeal(attacker, healed)
		end
	end
	
	return true
end