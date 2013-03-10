--- Private vars
itemShop = {
	count = 0,
	receive_list = nil,
	not_received_list = nil,
	cid = nil
}

function itemShop:new()

	local obj = {}
	obj.cid = nil
	obj.receive_list = {}
	obj.not_received_list = {}
	
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function itemShop:log(msg, log_id)

	local log_str = (log_id ~= nil) and "| LogID " .. log_id .. " " or ""
	
	local out = os.date("%X") .. " | Player [" .. getPlayerName(self.cid) .. "] " .. log_str .. "| " .. msg .. "."
	
	local date = os.date("*t")
	local fileStr = date.day .. "-" .. date.month .. ".log"
	local patch = getConfigValue("logsDirectory") .. "itemshop/"
	local file = io.open(patch .. fileStr, "a+")
	
	file:write(out .. "\n")
	file:close()
end

function itemShop:markReceived(log_id)
	db.executeQuery("UPDATE `wb_itemshop_log` SET `received` = 1 WHERE `id` = " .. log_id .. ";")
end

function itemShop:notify()

	local msg = ""
	
	if(self.count == #self.receive_list and #self.not_received_list == 0) then
		msg = msg .. "Todas as suas " .. #self.receive_list .. " compras obtidas no Item Shop foram entregues com sucesso em sua backpack principal!\n\n"
		msg = msg .. "Tenha um bom jogo!"
	elseif(#self.not_received_list > 0 and #self.not_received_list < #self.receive_list) then
		local receivedItems = #self.receive_list - #self.not_received_list
		msg = msg .. "Parte de suas compras (" .. receivedItems .. ") obtidas no Item Shop foram entregues com sucesso em sua backpack principal!\n\n"
		msg = msg .. "Obs:\n"
		msg = msg .. "Ainda há " .. #self.not_received_list .." compra(s) pendentes para serem entregue(s), por favor, certifique-se de possuir capacidade para carregar e slots livres em sua backpack principal e re-faça o login para receber as compras. Obrigado."
	elseif(#self.not_received_list == #self.receive_list) then
		msg = msg .. "Há " .. #self.receive_list .. "  compra(s) no Item Shop pendentes para serem entregue(s), por favor, certifique-se de possuir capacidade para carregar e slots livres em sua backpack principal e re-faça o login para receber a(s) compra(s). Obrigado."	
	else
		self:log("Problema ilogico não previsto: Total de itens " .. self.count .. ", Itens não recebidos " .. #self.not_received_list .. ", Itens a Receber " .. #self.receive_list .. ".")
		return
	end

	doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
end

function itemShop:giveList()

	self.not_received_list = table.copy(self.receive_list)

	for _, item in pairs(self.receive_list) do
		if(self:giveItem(item)) then
			self:markReceived(item.log_id)
			self.not_received_list[_] = nil
		else
			self:log("Impossivel adicionar mais itens, processo abortado. Itens restantes : " .. json.encode(self.not_received_list) .. "")
			break
		end
	end
end

function doItemSetItemShopLogId(uid, log_id)
	return doItemSetAttribute(uid, "itemShopLogId", log_id)
end

function itemShop:giveItem(data)

	local usePresent = data.use_present

	local PRESENT_BOX, main, subitem = 1990, nil, nil

	if(usePresent) then
		main = doCreateItemEx(PRESENT_BOX, 1)
		subitem = doCreateItemEx(data.item_id, data.item_count)	
	else
		main = doCreateItemEx(data.item_id, data.item_count)	
	end

	if(data.item_action_id ~= nil) then
		doItemSetActionId((usePresent and subitem or main), data.item_action_id)
	end
	
	doItemSetItemShopLogId((usePresent and subitem or main), data.log_id)
	
	if(usePresent and doAddContainerItemEx(main, subitem) ~= RETURNVALUE_NOERROR) then
		self:log("Impossivel colocar em container " .. json.encode(data) .. "")
		return false
	end
	
	if(doPlayerAddItemEx(self.cid, main, false) == RETURNVALUE_NOERROR) then
		self:log("Item Data Entregue com sucesso: " .. json.encode(data) .. "")
		return true
	end	
	
	self:log("Impossivel colocar no inventario " .. json.encode(data) .. "")
	return false
end

-- Verifica se o player possui um item no shop a receber
-- Usado em creaturescripts/login.lua
function itemShop:onLogin(cid)

	local result = db.getResult("SELECT `shop`.`name`, `shop`.`params`, `log`.`id` FROM `wb_itemshop_log` `log` LEFT JOIN `wb_itemshop` `shop` ON `log`.`shop_id` = `shop`.`id` WHERE `log`.`player_id` = " .. getPlayerGUID(cid) .. " AND `log`.`received` = 0;")
	
	local totalWeight = 0
	
	if(result:getID() ~= -1) then
	
		self.cid = cid
		self.count = result:getRows(false)
		self:log("Processando " .. self.count .. " itens a entregar...")
			
		repeat
			local json = require("json")
			local item_params = json.decode(result:getDataString("params"))
			local item_action_id = item_params["item_action_id"] or 0
			
			totalWeight = totalWeight + getItemWeightById(tonumber(item_params["item_id"]), tonumber(item_params["item_count"]))
			
			if(getPlayerFreeCap(cid) > totalWeight) then
						
				local usePresentBox = true
				if(item_params["use_present"] and not getBooleanFromString(item_params["use_present"])) then
					usePresentBox = false
				end
						
				table.insert(self.receive_list, {
					log_id = result:getDataInt("id"), 
					use_present = usePresentBox,
					item_id = tonumber(item_params["item_id"]), 
					item_count = tonumber(item_params["item_count"]), 
					item_name = result:getDataString("name"), 
					item_action_id = item_action_id
				})
				
				self:log("Item Data: " .. json.encode(self.receive_list[#self.receive_list]) .. "")
			else
				self:log("Capacidade esgotada, entregando os itens previamente processados.")
				break
			end
					
		until not(result:next())
		result:free()
		
		self:giveList()
		self:notify()
		
		self:log("Processo concluido. Resultado: Total de itens " .. self.count .. ", Itens não recebidos " .. #self.not_received_list .. ", Itens a Receber " .. #self.receive_list .. ".")
		self:log("--------------------------------------")
	end
end