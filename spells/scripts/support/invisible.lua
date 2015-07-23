local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)

local condition = createConditionObject(CONDITION_INVISIBLE)
setConditionParam(condition, CONDITION_PARAM_TICKS, 200000)
setCombatCondition(combat, condition)

function onCastSpell(cid, var)
	
	if(doPlayerIsInBattleground(cid)) then
		doPlayerSendCancel(cid, "Você não pode usar essa magia dentro de uma Battleground.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
		return false
	end
	
	return doCombat(cid, combat, var)
end