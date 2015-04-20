local lastUpdateData = {}
local updateInterval = 20

function onThink(cid, interval)
	if(not isCreature(cid)) then
		return
	end

	local skull, skullEnd = getCreatureSkull(cid), getPlayerSkullEnd(cid)
	if(skullEnd > 0 and skull > SKULL_WHITE and os.time() > skullEnd and not getCreatureCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSetSkullEnd(cid, 0, skull)
	end
	
	doCheckPlayerSkull(cid)
end

function doCheckPlayerSkull(cid)

	local data = lastUpdateData[cid]
	
	if(data ~= nil) then
	
		if(os.time() >= data["lastUpdate"] + updateInterval) then
			local skull = getCreatureSkull(cid)
			if((skull >= SKULL_WHITE and data["skull"] < SKULL_WHITE) or (skull < SKULL_WHITE and data["skull"] >= SKULL_WHITE)) then	
				doUpdateDBPlayerSkull(cid)
			end
			
			lastUpdateData[cid]["lastUpdate"] = os.time()
			lastUpdateData[cid]["skull"] = skull
		end
	else

		local skull = getCreatureSkull(cid)
		local data = {}
		data["lastUpdate"] = os.time()
		data["skull"] = skull
		
		table.insert(lastUpdateData, cid, data)
	end
end