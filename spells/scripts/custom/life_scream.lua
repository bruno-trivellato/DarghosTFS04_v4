local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local min = math.ceil(getCreatureMaxHealth(cid) * 0.88)
	local max = math.ceil(getCreatureMaxHealth(cid) * 0.93)
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)

	if(not doPlayerIsInBattleground(cid)) then
            doPlayerSendCancel(cid, "Esta magia so está disponivel dentro de partidas na Battleground.")
            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
            return false
	end

	return doCombat(cid, combat, var)
end
