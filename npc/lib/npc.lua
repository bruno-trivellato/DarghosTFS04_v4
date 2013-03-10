-- Include external classes.
dofile(getDataDir() .. 'npc/lib/destinations.lua')
dofile(getDataDir() .. 'npc/lib/npc_dialog.lua')
dofile(getDataDir() .. 'npc/lib/npc_tasks.lua')
dofile(getDataDir() .. 'npc/lib/npc_system.lua')
dofile(getDataDir() .. 'npc/lib/custom_modules.lua')
dofile(getDataDir() .. 'npc/lib/repair.lua')
dofile(getDataDir() .. 'npc/lib/addonItems.lua')
dofile(getDataDir() .. 'npc/lib/trade.lua')

function selfIdle()
	following = false
	attacking = false

	selfAttackCreature(0)
	target = 0
end

function selfSayChannel(cid, message)
	return selfSay(message, cid, false)
end

function selfMoveToCreature(id)
	if(not id or id == 0) then
		return
	end

	local t = getCreaturePosition(id)
	if(not t.x or t.x == nil) then
		return
	end

	selfMoveTo(t.x, t.y, t.z)
	return
end

function getNpcDistanceToCreature(id)
	if(not id or id == 0) then
		selfIdle()
		return nil
	end

	local c = getCreaturePosition(id)
	if(not c.x or c.x == 0) then
		return nil
	end

	local s = getCreaturePosition(getNpcId())
	if(not s.x or s.x == 0 or s.z ~= c.z) then
		return nil
	end

	return math.max(math.abs(s.x - c.x), math.abs(s.y - c.y))
end

function doMessageCheck(message, keyword)
	if(type(keyword) == "table") then
		--return table.isStrIn(keyword, message)
		return table.isStrIn(message, keyword)
	end

	local a, b = message:lower():find(keyword:lower())
	if(a ~= nil and b ~= nil) then
		return true
	end

	return false
end

function doNpcSellItem(cid, itemid, amount, subType, ignoreCap, inBackpacks, backpack)
	local amount, subType, ignoreCap, inBackpacks, backpack  = amount or 1, subType or 0, ignoreCap or false, inBackpacks or false, backpack or 592

	local item, a = nil, 0
	if(inBackpacks) then
		local custom, stackable = 1, isItemStackable(itemid)
		if(stackable) then
			custom = math.max(1, subType)
			subType = 100
		end

		local container, b = doCreateItemEx(backpack, 1), 1
		for i = 1, amount * custom do
			item = doAddContainerItem(container, itemid, subType)
			if(itemid == ITEM_PARCEL) then
				doAddContainerItem(item, ITEM_LABEL)
			end

			if(isInArray({(getContainerCapById(backpack) * b), amount}, i)) then
				if(doPlayerAddItemEx(cid, container, ignoreCap) ~= RETURNVALUE_NOERROR) then
					b = b - 1
					break
				end

				a = i
				if(amount > i) then
					container = doCreateItemEx(backpack, 1)
					b = b + 1
				end
			end
		end

		if(not stackable) then
			return a, b
		end

		return (a * subType / custom), b
	end

	if(isItemStackable(itemid)) then
		a = amount * math.max(1, subType)
		-- fix darghos
		local amountBrought = 1
		repeat
			local tmp = math.min(100, a)
			item = doCreateItemEx(itemid, tmp)
			if(doPlayerAddItemEx(cid, item, ignoreCap) ~= RETURNVALUE_NOERROR) then
				return amountBrought, 0
			end

			a = a - tmp
			amountBrought = amountBrought + 1
		until a == 0
		return amount, 0
	end

	for i = 1, amount do
		item = doCreateItemEx(itemid, subType)
		if(itemid == ITEM_PARCEL) then
			doAddContainerItem(item, ITEM_LABEL)
		end

		if(doPlayerAddItemEx(cid, item, ignoreCap) ~= RETURNVALUE_NOERROR) then
			break
		end

		a = i
	end

	return a, 0
end

function doRemoveItemIdFromPos(id, n, position)
	local thing = getThingFromPos({x = position.x, y = position.y, z = position.z, stackpos = 1})
	if(thing.itemid ~= id) then
		return false
	end

	doRemoveItem(thing.uid, n)
	return true
end

function getNpcName()
	return getCreatureName(getNpcId())
end

function getNpcPos()
	return getCreaturePosition(getNpcId())
end

function selfGetPosition()
	local t = getNpcPos()
	return t.x, t.y, t.z
end

msgcontains = doMessageCheck
moveToPosition = selfMoveTo
moveToCreature = selfMoveToCreature
selfMoveToPosition = selfMoveTo
selfGotoIdle = selfIdle
isPlayerPremiumCallback = isPremium
doPosRemoveItem = doRemoveItemIdFromPos
doNpcBuyItem = doPlayerRemoveItem
doNpcSetCreatureFocus = selfFocus
getNpcCid = getNpcId
getDistanceTo = getNpcDistanceTo
getDistanceToCreature = getNpcDistanceToCreature
