local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TARGETCASTERORTOPMOST, true)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
 
local condition = createConditionObject(CONDITION_PARALYZE)
setConditionParam(condition, CONDITION_PARAM_TICKS, 20000)
setConditionFormula(condition, -0.8, 0, -0.8, 0)
setCombatCondition(combat, condition)
 
local paralyze_delay = createConditionObject(CONDITION_EXHAUST)
setConditionParam(paralyze_delay, CONDITION_PARAM_TICKS, getConfigInfo('paralyzeDelay'))
setConditionParam(paralyze_delay, CONDITION_PARAM_SUBID, EXHAUSTED_PARALYZE)
 
function onCastSpell(cid, var)
        if(not doCombat(cid, combat, var)) then
                return false
        end
               
                if isPlayer(variantToNumber(var)) then
                        doAddCondition(variantToNumber(var), paralyze_delay)
                end
               
        doSendMagicEffect(getThingPosition(cid), CONST_ME_MAGIC_GREEN)
        return true
end