local items = {
	[2164] = { sid = sid.EXHAUSTED_ITEM_MIGHT_RING, exhausted = 60},
	[2197] = { sid = sid.EXHAUSTED_ITEM_STONE_SKIN_AMULET, exhausted = 60}
}

function onEquip(cid, item, slot, boolean)

	if(items[item.itemid] == nil) then
		return true
	end
	
	local item_conf = items[item.itemid]
	
	local lastEquipDate = getPlayerStorageValue(cid, item_conf.sid) or false
	
	if(not lastEquipDate or os.time() > lastEquipDate + item_conf.exhausted) then
		setPlayerStorageValue(cid, item_conf.sid, os.time())
		return true
	elseif(lastEquipDate == os.time()) then
		return true
	end

	doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Você deve aguardar " .. (lastEquipDate + item_conf.exhausted) - os.time() .. " segundos para equipar outro item deste tipo.")
	return false
end
