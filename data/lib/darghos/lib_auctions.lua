Auctions = {}

function Auctions.onLogin(cid)
	
	local result = db.getResult("SELECT `auction`.`id`, `bid`.`bid` FROM `wb_auctions` `auction` LEFT JOIN `wb_auction_bids` `bid` ON `auction`.`current_bid` = `bid`.`id` WHERE `auction`.`received` = 0 AND `bid`.`player_id` = " .. getPlayerGUID(cid) .. " AND UNIX_TIMESTAMP() > `auction`.`end`;")

	if(result:getID() == -1) then
		return true
	end
	
	local auction_id = result:getDataInt("id")
	local auction_bid = result:getDataInt("bid")
	result:free()
	
	local itemsResult = db.getResult("SELECT `itemtype`, `count`, `attributes` FROM `wb_auction_items` WHERE `auction_id` = " .. auction_id .. ";")
	
	if(itemsResult:getID() == -1) then
		error("Auction#" .. auction_id .. " não possui items?")
		return true
	end
	
	local json = require("json")
	local items, sumWeight, hasCap = {}, 0, true
	
	local backpacks = {1988, 1998, 1999, 2000, 2001, 2002, 2003, 2004}
	if(auction_bid > 100) then
		backpacks = {10518, 10521, 10522, 11119, 11241, 11243, 11244, 11263}
	end
	
	local BACKPACK = backpacks[math.random(1, #backpacks)]
	local PRESENT_BOX = 1990
	
	sumWeight = sumWeight + getItemWeightById(PRESENT_BOX, 1)
	sumWeight = sumWeight + getItemWeightById(BACKPACK, 1)
	
	repeat
	
		local attr = itemsResult:getDataString("attributes") ~= "" and json.decode(itemsResult:getDataString("attributes")) or nil
	
		local item = {
			itemtype = itemsResult:getDataInt("itemtype")
			,count = itemsResult:getDataInt("count")
			,attributes = attr
		}
		table.insert(items, item)
		
		sumWeight = sumWeight + getItemWeightById(item.itemtype, item.count)
		
		if(getPlayerFreeCap(cid) < sumWeight) then
			hasCap = false
			break
		end
	until not(itemsResult:next())
	
	if(not hasCap) then
		-- TODO: alertamos o jogador que ele nÃ£o possui cap sulficiente para carregar os itens...
		doPlayerPopupFYI(cid, "Você possui items ganhos em um leilão a receber entretanto não possui capacidade sulficiente\npara carregar todos os itens. Certifique-se de possuir ao menos " .. sumWeight .. " oz livres e\nfaça novamente um login para receber os items.")
		return true
	end	
	
	local container = doCreateItemEx(PRESENT_BOX, 1)
	local backpack = doCreateItemEx(BACKPACK, 1)
	
	if(doAddContainerItemEx(container, backpack) ~= RETURNVALUE_NOERROR) then
		error("Impossivel colocar backpack no main container.")
		return true
	end
	
	for _,item in pairs(items) do
		if(isItemStackable(item.itemtype)) then
			local tmp_item = doCreateItemEx(item.itemtype, item.count)
			
			if(item.attributes and item.attributes["action_id"] ~= nil) then
				doItemSetActionId(tmp_item, item.attributes["action_id"])
			end
			
			local ret = doAddContainerItemEx(backpack, tmp_item)
			if(ret ~= RETURNVALUE_NOERROR) then
				error("Ret# " .. ret ..  " | Impossivel colocar item na backpack " .. json.encode(item) .. "")
				return true
			end			
		else
			local i = item.count
			repeat
				local tmp_item = doCreateItemEx(item.itemtype)
				
				if(item.attributes and item.attributes["action_id"] ~= nil) then
					doItemSetActionId(tmp_item, item.attributes["action_id"])
				end
				
				local ret = doAddContainerItemEx(backpack, tmp_item)
				if(ret ~= RETURNVALUE_NOERROR) then
					error("Ret# " .. ret ..  " | Impossivel colocar item na backpack " .. json.encode(item) .. "")
					return true
				end
					
				i = i - 1
			until (i == 0)
		end
	end
	
	if(doPlayerAddItemEx(cid, container, false) ~= RETURNVALUE_NOERROR) then
		error("Falhou a entregar os items do leilão #" .. auction_id)
		return true
	end		
	
	db.executeQuery("UPDATE `wb_auctions` SET `received` = 1 WHERE `id` = " .. auction_id .. ";")
	
	local msg = ""
	msg = msg .. "Você recebeu em sua backpack os items ganhos em um de nossos Leilões recentemente! Parabens!\n"
	msg = msg .. "Tenha um bom jogo!"
	
	doSendMagicEffect(getPlayerPosition(cid), CONST_ME_FIREWORK_RED)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
	
	return true
end