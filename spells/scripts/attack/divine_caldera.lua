local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)

function onGetFormulaValues(cid, level, maglevel)
    local minMult = 4.2
    local maxMult = 17.8

    local minDmg = -((level / 3) + (maglevel * minMult))
    local maxDmg = -((level / 3) + (maglevel * maxMult))
	
	minDmg, maxDmg = increasePremiumSpells(cid, minDmg, maxDmg)	

    return minDmg, maxDmg
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CIRCLE3X3)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
