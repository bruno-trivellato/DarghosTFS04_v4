local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onTargetCreature(cid, target)
	
	if(isPlayer(target)) then
		return
	end
	
	local master = getCreatureMaster(target)
	if(master and isPlayer(master)) then
		return
	end
	
	local heal = math.random(650, 1050)
	doCreatureAddHealth(target, heal, CONST_ME_MAGIC_BLUE, COLOR_BLUE)
end

setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

local area = createCombatArea(AREA_CIRCLE5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
