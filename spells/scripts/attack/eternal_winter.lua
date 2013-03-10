local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)

function onGetFormulaValues(cid, level, maglevel)
    local minMult = 7.5
    local maxMult = 12

    local minDmg = -((level / 3) + (maglevel * minMult))
    local maxDmg = -((level / 3) + (maglevel * maxMult))

    return minDmg, maxDmg
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
