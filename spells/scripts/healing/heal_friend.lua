local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)

function onGetFormulaValues(cid, level, maglevel)
	local min = ((level/5)+(maglevel*10))
	local max = ((level/5)+(maglevel*14))
	
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)

	if(hasCondition(cid, CONDITION_PARALYZE) and not hasCondition(cid, CONDITION_EXHAUST, EXHAUSTED_PARALYZE)) then 
		doRemoveCondition(cid, CONDITION_PARALYZE) 
	end

	local ret = doCombat(cid, combat, var)

	--send effects
	if ret == LUA_NO_ERROR then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
		if isCreature(var.number) == TRUE then
			if cid ~= var.number then
				doSendMagicEffect(getCreaturePosition(var.number), CONST_ME_MAGIC_GREEN)
			end
		end
	end

	return ret
end
