local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TARGETCASTERORTOPMOST, true)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)

local condition = createConditionObject(CONDITION_PARALYZE)
setConditionParam(condition, CONDITION_PARAM_TICKS, 20000)
setConditionFormula(condition, -0.8, 0, -0.8, 0)
setCombatCondition(combat, condition)

function onCastSpell(cid, var)
	
	local target = getSpellTargetCreature(var)
	if(not target) then
		error("Invalid target: " .. table.show(var))
		return false
	end
	
	if(doPlayerIsFlagCarrier(target)) then
		doPlayerSendCancel(cid, "Você não pode usar magias que alterem a velocidade de quem está carregando a bandeira.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
		return false
	end	
	
	if(not doCombat(cid, combat, var)) then
		return false
	end

	doSendMagicEffect(getThingPosition(cid), CONST_ME_MAGIC_GREEN)
	return true
end