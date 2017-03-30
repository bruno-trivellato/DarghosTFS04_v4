function onCastSpell(cid, var)
	
	local general = getCreatureByName("dark general")
	
	if(not general) then
		return true
	end

	local generalDps = tonumber(getStorage(gid.EVENT_DARK_GENERAL_DMG))
	
	if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(general)) <= 14) then
		local lifePercent = math.floor((getCreatureHealth(general) * 100) / getCreatureMaxHealth(general))
		local heal = lifePercent <= 50 and math.random(generalDps * 0.9, generalDps * 1.1) or math.random(2680, 4350)
		doCreatureAddHealth(general, heal, CONST_ME_MAGIC_BLUE, COLOR_BLUE)
		doCreatureSay(cid, "Protejam o General a todo custo!", TALKTYPE_MONSTER_YELL)
	end
	
	return true
end
