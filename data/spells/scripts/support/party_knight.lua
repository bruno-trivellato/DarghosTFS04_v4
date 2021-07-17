local combat = createCombatObject()
local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_SUBID, 1)
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
setConditionParam(condition, CONDITION_PARAM_TICKS, 2 * 60 * 1000)
setConditionParam(condition, CONDITION_PARAM_SKILL_MELEE, 3)
setConditionParam(condition, CONDITION_PARAM_SKILL_DISTANCE, 3)

local baseMana = 60

function onCastSpell(cid, var)
        local position = getCreaturePosition(cid)
        local membersList = getPartyMembers(cid)
        if not membersList then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOPARTYMEMBERSINRANGE)
                doSendMagicEffect(position, CONST_ME_POFF)
                return false
        end

        if membersList == nil or type(membersList) ~= 'table' or #membersList <= 1 then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOPARTYMEMBERSINRANGE)
                doSendMagicEffect(position, CONST_ME_POFF)
                return false
        end

        local affectedList = {}
        for _, targetPlayer in ipairs(membersList) do
                if(getDistanceBetween(getCreaturePosition(targetPlayer), position) <= 36) then
                        affectedList[#affectedList + 1] = targetPlayer
                end
        end

        local count = #affectedList
        if count <= 1 then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOPARTYMEMBERSINRANGE)
                doSendMagicEffect(position, CONST_ME_POFF)
                return false
        end

        local mana = math.ceil((0.9 ^ (count - 1) * baseMana) * count)
        if(getCreatureMana(cid) < mana) then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTENOUGHMANA)
                doSendMagicEffect(pos, CONST_ME_POFF)
                return false
        elseif(not doCombat(cid, combat, var)) then
                doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
                doSendMagicEffect(pos, CONST_ME_POFF)
                return false
        end

        doCreatureAddMana(cid, baseMana - mana, false)
        doPlayerAddSpentMana(cid, mana - baseMana)

        for _, pid in ipairs(affectedList) do
                doAddCondition(pid, condition)
        end
        return true
end