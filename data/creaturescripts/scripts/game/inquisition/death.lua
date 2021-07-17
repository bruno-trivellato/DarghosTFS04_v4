function onDeath(cid, corpse, deathList)
	
	if(getCreatureName(cid) ~= "demon") then
		addEvent(shadowNexusDemon, 1000 * 2)
	end
	
	return true
end 

function shadowNexusDemon()	
	
	local demons = {
		getThingPosition(uid.INQ_DEMON_1),
		getThingPosition(uid.INQ_DEMON_2),
		getThingPosition(uid.INQ_DEMON_3),
		getThingPosition(uid.INQ_DEMON_4),
		getThingPosition(uid.INQ_DEMON_5),
	}
	
	local rand = math.random(1, #demons)
	local portalPos = demons[rand]
	
	local demon = doSummonCreature("demon", portalPos)
	registerCreatureEvent(demon, "inquisitionReplaceDemons")	
end