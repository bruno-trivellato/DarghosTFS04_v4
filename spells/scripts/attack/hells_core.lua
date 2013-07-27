local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)

function onGetFormulaValues(cid, level, maglevel)
    local minMult = 8.25
    local maxMult = 13.2

    local minDmg = -((level / 3) + (maglevel * minMult))
    local maxDmg = -((level / 3) + (maglevel * maxMult))
	
	minDmg, maxDmg = increasePremiumSpells(cid, minDmg, maxDmg)	

    return minDmg, maxDmg
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
