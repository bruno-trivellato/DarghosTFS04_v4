local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_SMALLPLANTS)

function onGetFormulaValues(cid, level, maglevel)
    local minMult = 4.5
    local maxMult = 11

    local minDmg = -((level / 3) + (maglevel * minMult))
    local maxDmg = -((level / 3) + (maglevel * maxMult))
	
	minDmg, maxDmg = increasePremiumSpells(cid, minDmg, maxDmg)	

    return minDmg, maxDmg
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CROSS6X6)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
