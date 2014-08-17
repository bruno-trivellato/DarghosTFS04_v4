local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

local condition = createConditionObject(CONDITION_REGENERATION)
setConditionParam(condition, CONDITION_PARAM_SUBID, 1)
setConditionParam(condition, CONDITION_PARAM_TICKS, 22 * 1000)
setConditionParam(condition, CONDITION_PARAM_HEALTHTICKS, 1000)

function onGetFormulaValues(cid, level, maglevel)
	local min = math.ceil(getCreatureMaxHealth(cid) * 0.09)
	local max = math.ceil(getCreatureMaxHealth(cid) * 0.12)
	
	if(min < 300) then
		min = 300
		max = 350
	end
	
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)

	if(not doPlayerIsInBattleground(cid)) then
            doPlayerSendCancel(cid, "Esta magia so está disponivel dentro de partidas na Battleground.")
            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
            return false
	end
	
	local healthGain = math.ceil(math.random(math.ceil(getCreatureMaxHealth(cid) * 0.27), math.ceil(getCreatureMaxHealth(cid) * 0.31)) / 15)	
	setConditionParam(condition, CONDITION_PARAM_HEALTHGAIN, healthGain)
	setCombatCondition(combat, condition)	

	return doCombat(cid, combat, var)
end
