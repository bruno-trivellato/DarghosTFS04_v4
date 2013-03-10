local rustyItems = {
	 -- Rusty armor
	[9808] = {
		{name = "plate armor", chance = 10}
		, {name = "brass armor", chance = 30}
		, {name = "scale armor", chance = 50}
		, {name = "chain armor", chance = 70}
	},
	[9809] = {
		{ name = "crown armor", chance = 2}
		, {name = "paladin armor", chance = 4}
		, {name = "knight armor", chance = 10}
		, {name = "plate armor", chance = 20}
		, {name = "scale armor", chance = 50}
		, {name = "brass armor", chance = 50}
		, {name = "chain armor", chance = 100}
	},
	[9810] = {
		{name = "golden armor", chance = 5}
		, {name = "crown armor", chance = 15}
		, {name = "paladin armor", chance = 15}
		, {name = "knight armor", chance = 40}
		, {name = "plate armor", chance = 60}
		, {name = "brass armor", chance = 50}
		, {name = "chain armor", chance = 50}
		, {name = "scale armor", chance = 100}
	},

	-- Rusty legs
	[9811] = {
		{name = "plate legs", chance = 10}
		, {name = "brass legs", chance = 25}
		, {name = "chain legs", chance = 25}
		, {name = "studded legs", chance = 33}
	},
	[9812] = {
		{name = "crown legs", chance = 5}
		, {name = "knight legs", chance = 10}
		, {name = "plate legs", chance = 40}
		, {name= "brass legs", chance = 50}
		, {name = "chain legs", chance = 50}
		, {name = "studded legs", chance = 100}
	},
	[9812] = {
		{name = "golden legs", chance = 5}
		, {name = "crown legs", chance = 25}
		, {name = "knight legs", chance = 60}
		, {name = "plate legs", chance = 80}
		, {name = "brass legs", chance = 100}
	}
}

function onUse(cid, item, frompos, item2, topos)

	if rustyItems[item2.itemid] == nil then
		return false
	end

	for k,v in pairs(rustyItems[item2.itemid]) do
		local chance = math.random(1, 100)
		
		if(chance <= v.chance) then
			local revealedItem = getItemIdByName(v.name)
			if(revealedItem) then
				doTransformItem(item2.uid, revealedItem)
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você removeu as ferrugens, revelando um(a) " .. getItemName(item2.uid) .. ".")
				doRemoveItem(item.uid, 1)
				
				return true
			end
		end
	end
	
	-- break
	doRemoveItem(item.uid, 1)
	doRemoveItem(item2.uid)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você o quebrou...")
	
	return true
end