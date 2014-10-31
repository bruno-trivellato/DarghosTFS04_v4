local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 10000)
setConditionParam(condition, CONDITION_PARAM_SKILL_MELEEPERCENT, 135)
setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELDPERCENT, -100)
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
setCombatCondition(combat, condition)

-- Premium
local combat_premium = createCombatObject()
setCombatParam(combat_premium, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat_premium, COMBAT_PARAM_AGGRESSIVE, false)

local condition_premium = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition_premium, CONDITION_PARAM_TICKS, 10000)
setConditionParam(condition_premium, CONDITION_PARAM_SKILL_MELEEPERCENT, 145)
setConditionParam(condition_premium, CONDITION_PARAM_SKILL_SHIELDPERCENT, -100)
setConditionParam(condition_premium, CONDITION_PARAM_BUFF, true)
setCombatCondition(combat_premium, condition_premium)

function onCastSpell(cid, var)
	local mana = 290
	
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
  
        return doCombat(cid, usedCombat, var)
end