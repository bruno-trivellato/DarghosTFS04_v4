local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

local condition = createConditionObject(CONDITION_REGENERATION)
setConditionParam(condition, CONDITION_PARAM_SUBID, 1)
setConditionParam(condition, CONDITION_PARAM_TICKS, 10 * 1000)
setConditionParam(condition, CONDITION_PARAM_HEALTHTICKS, 1000)

function onCastSpell(cid, var)

	if(not doPlayerIsInBattleground(cid)) then
            doPlayerSendCancel(cid, "Esta magia so está disponivel dentro de partidas na Battleground.")
            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
            return false
	end
	
	local level, maglevel = getPlayerLevel(cid), getPlayerMagLevel(cid)
	
	local min = ((level*0.2)+(maglevel*2.4)+20)
	local max = ((level*0.2)+(maglevel*2.95)+35)	
	
	local healthGain = math.random(min, max)	
	setConditionParam(condition, CONDITION_PARAM_HEALTHGAIN, healthGain)
	setCombatCondition(combat, condition)
	
	local ret = doCombat(cid, combat, var)
	
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
