local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
setCombatParam(combat, COMBAT_PARAM_CREATEITEM, 1499)

function onCastSpell(cid, var)

	if getPlayerStorageValue(cid, sid.ENT_INSIDE) == 1 then
		doPlayerSendCancel(cid, "Runa não permitida dentro do evento.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)		
		return false
	end

	return doCombat(cid, combat, var)
end