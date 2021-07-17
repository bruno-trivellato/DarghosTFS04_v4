function onCastSpell(cid, var)

	local target = getCreatureTarget(cid)
	
	local pos = getCreaturePosition(target)
	
	local radius = 4
	local rand_pos = {
		x = math.random(pos.x - radius, pos.x + radius)
		,y = math.random(pos.y - radius, pos.y + radius)
		,z = pos.z
	}
	
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	doTeleportThing(cid, rand_pos)
	
	doCreatureSay(cid, "Muhauhuahua!", TALKTYPE_MONSTER_YELL)
	return true
end
