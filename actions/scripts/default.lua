function onUse(cid, item, fromPosition, itemEx, toPosition)

	local ret = defaultActions(cid, item, fromPosition, itemEx, toPosition)
	if(ret) then
		return true
	end

	local item = getItemInfo(item.itemid)
	if(item.weaponType == WEAPON_SWORD or item.weaponType == WEAPON_CLUB or item.weaponType == WEAPON_AXE) then
		return destroyItem(cid, itemEx, toPosition)
	end

	return false
end