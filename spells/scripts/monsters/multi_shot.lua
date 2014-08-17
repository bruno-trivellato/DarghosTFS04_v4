local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, TRUE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FLASHARROW)

function onCastSpell(cid, var)

	local target = getCreatureTarget(cid)
	
	local pos = getCreaturePosition(target)
	
	local spectators = getSpectators(pos, 1, 1)
	
	local damage = math.random(215, 365)
	
	if(spectators) then
		for _,thing in pairs(spectators) do
			if((isPlayer(thing) or (getCreatureMaster(thing) and isPlayer(getCreatureMaster(thing)))) and thing ~= target) then
				local tempVar = {
					number = thing
					,type = 1
				}
				
				doCombat(cid, combat, tempVar)
				doCreatureAddHealth(thing, -damage, CONST_ME_HITAREA, COLOR_GREY)
			end
		end
	end
	
	doCreatureSay(cid, "Sintam a dor de minhas flechas!", TALKTYPE_MONSTER_YELL)
	
	doCreatureAddHealth(target, -damage, CONST_ME_HITAREA, COLOR_GREY)
	return doCombat(cid, combat, var)
end
