--NPC_TRADETYPE_SHOP = 0 not yet implemented
NPC_TRADETYPE_SHOP = 1
NPC_TRADETYPE_HONOR = 2

NpcShop = {
	type = nil,
	itemLists = nil,
	dialog = nil,
	intentions = nil
}

--[[
ItemList struct (for openShopWindow):
{ id, subType, buy, sell, name }
--]]

function NpcShop:new(dialog, type)

	local list = {}

	type = type or NPC_TRADETYPE_SHOP

	local obj = {}
	obj.itemLists = list
	obj.type = type
	obj.dialog = dialog
	obj.intentions = {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function NpcShop:addNegotiableItemByName(item_name, buy, sell, subtype, rating, list_id)
	local item_id = getItemIdByName(item_name)
	
	if(item_id) then
		self:addNegotiableItem(item_id, buy, sell, subtype, item_name, rating, list_id)
        else
            print("Cannot find item id for " .. item_name)
	end
end

function NpcShop:addNegotiableItem(item_id, buy, sell, subtype, name, rating, list_id)
    
        if(self.itemLists[list_id] == nil) then
            table.insert(self.itemLists, list_id, {}) 
        end
    
	table.insert(self.itemLists[list_id], {id = item_id, subType = subtype or -1, buy = buy, sell = sell, name = name, requireRating = rating})
end

function NpcShop:addNegotiableListItems(list_id, list)
	for k,v in pairs(list) do
	
		if(v.name == nil and v.id == nil) then
			error("The negotiable list items must have item name or item id.")
		else
		
			if(not v.id) then
				self:addNegotiableItemByName(v.name, v.buy, v.sell, v.subType, v.requireRating, list_id)
			else
				local item_name = v.name or getItemInfo(v.id).name
				self:addNegotiableItem(v.id, v.buy, v.sell, v.subType, item_name, v.requireRating, list_id)
			end
		end	
	end
end

function NpcShop:getNegotiableItem(list_id, itemid)

	local item = nil

	for k,v in pairs(self.itemLists[list_id]) do
		if(v.id == itemid) then
			item = v
			break
		end
	end
	
	return item
end

function NpcShop:onPlayerBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id)
	
	local item = self:getNegotiableItem(list_id, itemid)
	
	if(self.type == NPC_TRADETYPE_HONOR) then
		
		local ratingStr = ""
		if(item.requireRating) then
			ratingStr = " Obs: para comprar este item é necessario ter atingido " .. item.requireRating .. " pontos de classificação (rating) em Battlegrounds."
		end
		self.dialog:say("Você quer comprar " .. amount * math.max(1, subType) .. "x " .. getItemInfo(itemid).name .. " por " .. (item.buy * amount) .. " de seus pontos de honra?" .. ratingStr, cid)
		table.insert(self.intentions, cid, 
		    {callback = function(...) self:onPlayerConfirmBuyCallback(...) end, args = {cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id}})
	elseif(self.type == NPC_TRADETYPE_SHOP) then
		self.dialog:say("Not yet implemented...", cid)
	end
end

function NpcShop:onPlayerDeclineBuy(cid)
	if(self.intentions[cid]) then
		self.intentions[cid] = nil
		self.dialog:say("Oh, então posso lhe ajudar em algo mais?", cid)
	end
	
	return nil	
end

function NpcShop:onPlayerConfirmBuy(cid)

	if(self.intentions[cid]) then
		return self.intentions[cid].callback(self.intentions[cid].args)
	end
	
	return nil
end

function NpcShop:onPlayerConfirmBuyCallback(args)

	local cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id = args[1], args[2], args[3], args[4], args[5], args[6], args[7]
  
	local item = self:getNegotiableItem(list_id, itemid)
	
	local honor = getPlayerBattlegroundHonor(cid)
	local totCost = item.buy * amount
	
	if(honor < totCost) then
		local honorStr = (honor > 0) and "possui " .. honor or "não possui"
		self.dialog:say("Desculpe, você " .. honorStr .. " pontos de honra e são necessários " .. (amount * item.buy) .. " pontos para comprar isto!", cid)
		return false
	end
	
	if(item.requireRating and getPlayerBattlegroundRating(cid) < item.requireRating) then
		local ratingStr = (getPlayerBattlegroundRating(cid) > 0) and "possui apénas " .. getPlayerBattlegroundRating(cid) .. " pontos" or "não possui nenhum ponto"
		self.dialog:say("Desculpe, para comprar este item você precisa ter conquistado " .. item.requireRating .. " pontos classificação (rating) e você " .. ratingStr .. ". Vença algumas partidas na Battleground e retorne quando tiver isto.", cid)
		return false
	end

	local a, b = doNpcSellItem(cid, itemid, amount, subType, ignoreCap, false, 1988)
	if(a < amount) then
		local msg = "Libere algum espaço! Você não consegue carregar mais nada!"
		if(a > 0) then
			msg = "Você pode carregar apénas " .. a .. "x " .. getItemInfo(itemid).name ..". Se desejar carregar mais libere algum espaço e retorne!"
		end
		
		self.dialog:say(msg, cid)
		if(a > 0) then
			changePlayerBattlegroundHonor(cid, -(a * item.buy))	
			return true
		end	
		
		return false	
	end
	
	changePlayerBattlegroundHonor(cid, -totCost)
	self.dialog:say("Aqui está! Posso lhe ajudar em algo mais?", cid)
	return true
end

function NpcShop:onPlayerSell(cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id)

end

function NpcShop:onPlayerRequestTrade(list_id, cid)

	local itemList = {}
	
	if(self.type == NPC_TRADETYPE_HONOR) then
		for k,v in pairs(self.itemLists[list_id]) do
			table.insert(itemList, {id = v.id, subType = math.max(1, v.subType), buy = 1, sell = nil, name = v.name})
		end
	elseif(self.type == NPC_TRADETYPE_SHOP) then
		itemList = table.copy(self.itemList)
	end
	
	addEvent(openShopWindow, NPC_DIALOG_INTERVAL, cid, itemList, 
		function(cid, itemid, subType, amount, ignoreCap, inBackpacks) self:onPlayerBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id) end
		, function(cid, itemid, subType, amount, ignoreCap, inBackpacks) self:onPlayerSell(cid, itemid, subType, amount, ignoreCap, inBackpacks, list_id) end)	
end
