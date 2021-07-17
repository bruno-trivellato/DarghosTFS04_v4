STATE_ACCEPT_REPAIR_ALL 		= 1
STATE_ACCEPT_REPAIR_SLOT 		= 2
STATE_ACCEPT_REPAIR_SPECIFIC 	= 3

REPAIR_COMMON_COST = 2
REPAIR_RARE_COST = 37
REPAIR_EPIC_COST = 365
REPAIR_LEGENDARY_COST = 811

RepairModule = {
	npcHandler = nil
	,talkStates = {}
	,repairSlotTarget = {}
	,repairSpecificTarget = {}
}

function RepairModule.configure(npcHandler)
	RepairModule.npcHandler = npcHandler
end

function RepairModule.parseMessage(cid, message)
	
	if(msgcontains(message, {'yes', 'sim'}) and RepairModule.talkStates[cid]) then
		
		if(RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_SLOT) then
			RepairModule.repairSlot(cid)
		elseif(RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_ALL) then
			RepairModule.repairAll(cid)
		elseif(RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_SPECIFIC) then
			RepairModule.repairSpecific(cid)
		end
	elseif(msgcontains(message, {'no', 'nao'}) and RepairModule.talkStates[cid]) then
		
		RepairModule.npcHandler:say('Certo. Posso lhe ajudar em mais alguma coisa?', cid)
		RepairModule.releaseFocus(cid)
	else
		
		RepairModule.releaseFocus(cid)
		local params = string.explode(message, " ", 1)
		
		if(not msgcontains(params[1], {"repair", "reparar"})) then
			return
		end
		
		local repairTargetStr = params[2]
		
		if(#params >= 2) then
			local item_id = getItemIdByName(repairTargetStr, false)
			if(item_id) then
				RepairModule.repairSpecific(cid, repairTargetStr)
			elseif(msgcontains(repairTargetStr, {"all", "tudo"})) then
				RepairModule.repairAll(cid)
			elseif(msgcontains(repairTargetStr, {"helmet", "capacete", "elmo"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_HEAD)
			elseif(msgcontains(repairTargetStr, {"armor", "armadura", "peito"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_ARMOR)
			elseif(msgcontains(repairTargetStr, {"legs", "pernas"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_LEGS)
			elseif(msgcontains(repairTargetStr, {"boots", "botas"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_FEET)
			elseif(msgcontains(repairTargetStr, {"left", "left hand", "esquerda", "mao esquerda"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_LEFT)
			elseif(msgcontains(repairTargetStr, {"right", "right hand", "direita", "mao direita"})) then
				RepairModule.repairSlot(cid, CONST_SLOT_RIGHT)
			else
				RepairModule.npcHandler:say(repairTargetStr .. '? Nunca ouvi falar neste item...', cid)
			end
		else
			RepairModule.npcHandler:say('Eu sou um experiente ferreiro e possuo conhecimento para reparar os seus equipamentos e armas desgastados durante seus duros combates. Eu posso reparar um item especifico pelo seu nome (ex: {reparar demon helmet}), também posso reparar um item equipado em um lugar especifico de seu inventário (ex: {reparar elmo} ou {reparar peito}). Por fim, se dizer {reparar tudo} também posso reparar todos os seus items em seu inventário ou na sua mochila principal que necessitem de algum reparo.', cid)
		end
	end
end

function RepairModule.onFarewell(cid)
	
	RepairModule.releaseFocus(cid)
end

function RepairModule.releaseFocus(cid)

	RepairModule.repairSlotTarget[cid] = nil
	RepairModule.talkStates[cid] = nil
	RepairModule.repairSpecificTarget[cid] = nil	
end

function RepairModule.getPrice(item)
	
	local _item = getItemInfo(item.itemid)
	local rarity, durability, maxDurability = (not getItemAttribute(item.uid, "rarity") and _item.rarity), getItemAttribute(item.uid, "durability"), getItemAttribute(item.uid, "maxdurability")
	
	if(not maxDurability or maxDurability <= 0) then
		return nil
	end
	
	local repairPoints = maxDurability - durability
	
	if(repairPoints == 0) then
		return nil
	end
	
	local repairRarityCost = REPAIR_COMMON_COST
	
	if(rarity == ITEM_RARITY_RARE) then
		repairRarityCost = REPAIR_RARE_COST
	elseif(rarity == ITEM_RARITY_EPIC) then
		repairRarityCost = REPAIR_EPIC_COST
	elseif(rarity == ITEM_RARITY_LEGENDARY) then
		repairRarityCost = REPAIR_LEGENDARY_COST
	end
	
	local repairPenalty = 1.0
	
	if(durability < maxDurability * 0.25) then
		repairPenalty = 3.5
	elseif(durability < maxDurability * 0.80) then
		repairPenalty = 2.0
	end
	
	return math.floor((repairPenalty * repairPoints) * repairRarityCost)
end

function RepairModule.repairFull(uid)
	doItemSetAttribute(uid, "durability", getItemAttribute(uid, "maxdurability"))
end

function RepairModule.repairSlot(cid, slot)
	
	slot = slot or RepairModule.repairSlotTarget[cid]
	
	local item = getPlayerSlotItem(cid, slot)
	
	if(item.uid == 0) then
		RepairModule.npcHandler:say('Desculpe... Você não possui qualquer item equipado neste lugar!', cid)
		return	
	end
	
	local repairCost = RepairModule.getPrice(item)
	
	if(not repairCost) then
		RepairModule.npcHandler:say('Desculpe... O item neste lugar não necessita de qualquer reparo!', cid)
		return
	end
	
	if(RepairModule.talkStates[cid] and RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_SLOT) then
		if(doPlayerRemoveMoney(cid, repairCost)) then
			RepairModule.repairFull(item.uid)
			
			RepairModule.npcHandler:say('Aqui esta! O seu ' .. getItemNameById(item.itemid) .. ' foi reparado com sucesso!', cid)
		
			RepairModule.repairSlotTarget[cid] = nil
			RepairModule.talkStates[cid] = nil
		else
			RepairModule.npcHandler:say('Você não possui dinheiro suficiente para isto...', cid)
		end		
	else		
		RepairModule.npcHandler:say('Você gostaria de reparar o seu ' .. getItemNameById(item.itemid) .. ' por {' .. repairCost .. '} moedas de ouro?', cid)
		
		RepairModule.talkStates[cid] = STATE_ACCEPT_REPAIR_SLOT
		RepairModule.repairSlotTarget[cid] = slot	
	end
end

function RepairModule.repairAll(cid)
	
	local itemsStr = ""
	local first = true
	local totalCost = 0
	
	local slot = CONST_SLOT_FIRST
	local checkedItems = {}
	
	repeat
		local item = getPlayerSlotItem(cid, slot)
		if(item.uid ~= 0) then		
			local repairCost = RepairModule.getPrice(item)
			
			if(repairCost) then
				table.insert(checkedItems, item)
				totalCost = totalCost + repairCost
				
				if(not first) then
					itemsStr = itemsStr .. ', '
				else
					first = false
				end
				
				itemsStr = itemsStr .. getItemNameById(item.itemid) .. ' (' .. repairCost .. ' gps)'
			end
		end
		
		slot = slot + 1
	until(slot > CONST_SLOT_LAST)
	
	local mainContainer = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if(isContainer(mainContainer.uid)) then
	    for k = (getContainerSize(mainContainer.uid) - 1), 0, -1 do
	        local item = getContainerItem(mainContainer.uid, k)
			if(item.uid ~= 0) then
				local repairCost = RepairModule.getPrice(item)
				
				if(repairCost) then
					table.insert(checkedItems, item)
					
					totalCost = totalCost + repairCost
					
					if(not first) then
						itemsStr = itemsStr .. ', '
					else
						first = false
					end
					
					itemsStr = itemsStr .. getItemNameById(item.itemid) .. ' (' .. repairCost .. ' gps)'
				end
			end
	    end
	end
	
	if(totalCost == 0) then
		RepairModule.npcHandler:say('Desculpe... Você não possui qualquer item que necessite de algum reparo!', cid)
		return
	end
	
	itemsStr = itemsStr .. "."
	
	if(RepairModule.talkStates[cid] and RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_ALL) then
		if(doPlayerRemoveMoney(cid, totalCost)) then
			for _, item in pairs(checkedItems) do
				RepairModule.repairFull(item.uid)
			end
			
			RepairModule.npcHandler:say('Esta pronto! Todos seus items foram reparados e estão novos!', cid)
			RepairModule.talkStates[cid] = nil
		else
			RepairModule.npcHandler:say('Você não possui dinheiro suficiente para isto...', cid)
		end		
	else
		RepairModule.npcHandler:say('Você gostaria de reparar todos os seus items desgastados por {' .. totalCost .. '} moedas de ouro? Eu irei trabalhar na reparação dos seguintes items:', cid)
		RepairModule.npcHandler:say(itemsStr, cid)
		
		RepairModule.talkStates[cid] = STATE_ACCEPT_REPAIR_ALL
	end
end

function RepairModule.repairSpecific(cid, name)
	
	name = name or RepairModule.repairSpecificTarget[cid]
	
	local itemsStr = ""
	local first = true
	local totalCost = 0
	
	local slot = CONST_SLOT_FIRST
	local checkedItems = {}
	
	repeat
		local item = getPlayerSlotItem(cid, slot)
		if(item.uid ~= 0) then		
			local repairCost = RepairModule.getPrice(item)
			
			if(repairCost and msgcontains(getItemName(item.uid), name)) then
				table.insert(checkedItems, item)
				totalCost = totalCost + repairCost
				
				if(not first) then
					itemsStr = itemsStr .. ', '
				else
					first = false
				end
				
				itemsStr = itemsStr .. getItemNameById(item.itemid) .. ' (' .. repairCost .. ' gps)'
			end
		end
		
		slot = slot + 1
	until(slot > CONST_SLOT_LAST)
	
	local mainContainer = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if(isContainer(mainContainer.uid)) then
	    for k = (getContainerSize(mainContainer.uid) - 1), 0, -1 do
	        local item = getContainerItem(mainContainer.uid, k)
			if(item.uid ~= 0) then
				local repairCost = RepairModule.getPrice(item)
				
				if(repairCost and msgcontains(getItemName(item.uid), name)) then
					table.insert(checkedItems, item)
					
					totalCost = totalCost + repairCost
					
					if(not first) then
						itemsStr = itemsStr .. ', '
					else
						first = false
					end
					
					itemsStr = itemsStr .. getItemNameById(item.itemid) .. ' (' .. repairCost .. ' gps)'
				end
			end
	    end
	end
	
	if(totalCost == 0) then
		RepairModule.npcHandler:say('Desculpe, mas você não possui qualquer ' .. name .. ' que precise ser reparado...', cid)
		return
	end
	
	itemsStr = itemsStr .. "."
	
	if(RepairModule.talkStates[cid] and RepairModule.talkStates[cid] == STATE_ACCEPT_REPAIR_SPECIFIC) then
		if(doPlayerRemoveMoney(cid, totalCost)) then
			for _, item in pairs(checkedItems) do
				RepairModule.repairFull(item.uid)
			end
			
			RepairModule.npcHandler:say('Aqui está! ' .. (#checkedItems > 1 and 'Todos os seus ' or 'O seu ') .. name .. ' foi reparado e está novo em folha!', cid)
			RepairModule.talkStates[cid] = nil
		else
			RepairModule.npcHandler:say('Você não possui dinheiro suficiente para isto...', cid)
		end		
	else
		RepairModule.npcHandler:say('Você gostaria de reparar todos os seus ' .. name .. ' por ' .. totalCost .. ' moedas de ouro? Eu irei trabalhar na reparação dos seguintes items:', cid)
		RepairModule.npcHandler:say(itemsStr, cid)
		
		RepairModule.repairSpecificTarget[cid] = name
		RepairModule.talkStates[cid] = STATE_ACCEPT_REPAIR_SPECIFIC
	end
end