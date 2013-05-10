local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

function onGetFormulaValues(cid, level, maglevel)
	local min = ((level*0.2)+(maglevel*1.4)+8)
	local max = ((level*0.2)+(maglevel*1.795)+11)
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	
	if(hasCondition(cid, CONDITION_PARALYZE) and not hasCondition(cid, CONDITION_EXHAUST, EXHAUSTED_PARALYZE)) then 
		doRemoveCondition(cid, CONDITION_PARALYZE) 
	end
	
	return doCombat(cid, combat, var)
end