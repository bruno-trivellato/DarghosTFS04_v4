local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)

function onGetFormulaValues(cid, level, maglevel)
	local min = ((level/5)+(maglevel*7))
	local max = ((level/5)+(maglevel*14))
	
	if(doPlayerIsInBattleground(cid)) then
		min = math.ceil(min * 1.30)
		max = math.ceil(max * 1.30)
	end

	if(isPremium(cid)) then
	    min = math.ceil(min * 1.10)
	    max = math.ceil(max * 1.10)
	end
	
	return -min, -max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
  
	local mana = 1200
	
	if(isPremium(cid)) then
	  mana = mana - math.ceil(mana * 0.2)
	end
	
        if(getCreatureMana(cid) < mana) then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTENOUGHMANA)
                doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
                return false
        end
  
	local ret = doCombat(cid, combat, var)
	
	if(ret) then
	  doCreatureAddMana(cid, -(mana), false)
	  if(not getPlayerFlagValue(cid, PlayerFlag_NotGainMana)) then
		  doPlayerAddSpentMana(cid, (mana))
	  end
	end
  
        return ret
end
