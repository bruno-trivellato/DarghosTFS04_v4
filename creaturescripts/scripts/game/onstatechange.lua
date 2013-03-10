local monsterCallbacks = { 
}

function onStatsChange(cid, attacker, type, combat, value)

	if(isMonster(cid)) then
		if(monsterCallbacks[string.lower(getCreatureName(cid))] ~= nil) then
			monsterCallbacks[string.lower(getCreatureName(cid))].callback(cid, attacker, type, combat, value)
		end
	end
	
	return true
end