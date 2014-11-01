local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 10000)
setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCEPERCENT, 150)
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
setCombatCondition(combat, condition)

local speed = createConditionObject(CONDITION_PARALYZE)
setConditionParam(speed, CONDITION_PARAM_TICKS, 10000)
setConditionFormula(speed, -0.7, 56, -0.7, 56)
setCombatCondition(combat, speed)

local exhaust = createConditionObject(CONDITION_EXHAUST)
setConditionParam(exhaust, CONDITION_PARAM_SUBID, 2)
setConditionParam(exhaust, CONDITION_PARAM_TICKS, 10000)
setCombatCondition(combat, exhaust)

-- Premium
local combat_premium = createCombatObject()
setCombatParam(combat_premium, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat_premium, COMBAT_PARAM_AGGRESSIVE, false)

local condition_premium = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition_premium, CONDITION_PARAM_TICKS, 10000)
setConditionParam(condition_premium, CONDITION_PARAM_SKILL_DISTANCEPERCENT, 160)
setConditionParam(condition_premium, CONDITION_PARAM_BUFF, true)

setCombatCondition(combat_premium, condition_premium)
setCombatCondition(combat_premium, speed)
setCombatCondition(combat_premium, exhaust)

function onCastSpell(cid, var)
  
	local mana = 450
	
	local usedCombat = combat
	
	if(isPremium(cid)) then
	  mana = mana - math.ceil(mana * 0.2)
	  usedCombat = combat_premium
	end
	
        if(getCreatureMana(cid) < mana) then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTENOUGHMANA)
                doSendMagicEffect(pos, CONST_ME_POFF)
                return false
        end  
  
	local ret = doCombat(cid, usedCombat, var)
	
	if(ret) then
	  doCreatureAddMana(cid, -(mana), false)
	  if(not getPlayerFlagValue(cid, PlayerFlag_NotGainMana) and (not getTileInfo(getThingPosition(cid)).hardcore or config.hardcoreManaSpent)) then
		  doPlayerAddSpentMana(cid, (mana))
	  end
	end
  
        return ret
end