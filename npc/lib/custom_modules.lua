-- Custom Modules do Darghos para o NPC System padrÃ£o do Jiddo

D_CustomNpcModules = {}

function D_CustomNpcModules.addonTradeItems(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local foundAll = true

	local itemsToRemove = {}

	for _,item in pairs(parameters.neededItems) do
	
		local count = item.count or 1
	
		if(item.anyOf ~= nil) then
		
			local found = false
		
			for _,sub in pairs(item.anyOf) do
			
				count = sub.count or count
				
				if(sub.id == nil and sub.name == nil) then
					print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - An value of sub-item table not have both id and name.')
					return false
				end
				
				local itemtype = sub.id or getItemIdByName(sub.name)
				
				if(not itemtype) then
					print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Can not found a id for an sub-item called ' .. item.name .. '.')
					return false			
				end				
			
				if(getPlayerItemCount(cid, itemtype) >= count) then
					found = true
					table.insert(itemsToRemove, {id = itemtype, count = count})
					break
				end			
			end
			
			if(not found) then
				foundAll = false
				break
			end		
		else	
			if(item.id == nil and item.name == nil) then
				print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - An value of item table not have both id and name.')
				return false
			end
			
			local itemtype = item.id or getItemIdByName(item.name)
			
			if(not itemtype) then
				print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Can not found a id for an item called ' .. item.name .. '.')
				return false			
			end
		
			if(getPlayerItemCount(cid, itemtype) >= count) then
				table.insert(itemsToRemove, {id = itemtype, count = count})
			else
				foundAll = false
				break
			end			
		end
	end
	
	if(not foundAll) then		
		local msg = parameters.fail or "Sorry but you not have all needed items..."
		npcHandler:say(msg, cid)
		npcHandler:resetNpc(cid)
		return true
	end
	
	local neededCap = 0
	
	for _,item in pairs(parameters.receiveItems) do
	
		neededCap = neededCap + getItemWeightById(item.id, item.count)
	end		
	
	if(getPlayerFreeCap(cid) < neededCap) then
		npcHandler:say("You do not have enough capacity for all items.", cid)
		npcHandler:resetNpc(cid)
		return true	
	end
	
	for k,v in pairs(itemsToRemove) do
		if(not doPlayerRemoveItem(cid, v.id, v.count)) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Impossible to remove an previously checked item, aborted. Details:', '{player=' .. getCreatureName(cid) .. ', item_id=' .. v.id .. ', count=' .. v.count .. '}', 'Added items: ' .. table.show(addedItems))
			return false
		end
	end	
	
	local addedItems = {}
	
	for _,item in pairs(parameters.receiveItems) do
	
		local count = item.count or 1
	
		local tmp = doCreateItemEx(item.id, count)
		if(doPlayerAddItemEx(cid, tmp, true) ~= RETURNVALUE_NOERROR) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Impossible to give an item, aborted. Details:', '{player=' .. getCreatureName(cid) .. ', item_id=' .. v.id .. ', count=' .. v.count .. '}', 'Added items: ' .. table.show(addedItems))
			return false
		else
			table.insert(addedItems, {id = item.id, count = item.count})
		end
	end		
	
	local msg = parameters.success or "Thanks! Here it is! I hope you are happy!"
	npcHandler:say(msg, cid)
	npcHandler:resetNpc(cid)
	return true	
end

function D_CustomNpcModules.pvpBless(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.bless - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local price
	
	if(parameters.cost) then
		price = parameters.cost
	else
		price = parameters.baseCost
		if(getPlayerLevel(cid) > parameters.startLevel) then
			price = (price + ((math.min(parameters.endLevel, getPlayerLevel(cid)) - parameters.startLevel) * parameters.levelCost))
		end
	end

	if(getPlayerPVPBlessing(cid)) then
		npcHandler:say("De novo? Os deuses já lhe abençoaram!", cid)
	elseif(getCreatureSkull(cid) >= SKULL_WHITE) then
		npcHandler:say("Você tem sangue em suas mãos! Caia fora daqui!", cid)
	elseif(not doPlayerRemoveMoney(cid, price)) then
		npcHandler:say("Você não tem moedas sulficientes para a benção...", cid)
	else
		npcHandler:say("Agora suas benções normais estão protegidas contra mortes para outros jogadores! Boa sorte!", cid)
		doPlayerSetPVPBlessing(cid)
	end

	npcHandler:resetNpc(cid)
	return true
end

function D_CustomNpcModules.inquisitionBless(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('StdModule.bless called without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	--[[local questStatus = getPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_SHADOW_NEXUS)
	
	if(questStatus ~= 1) then
		npcHandler:say('Você precisa completar todas as missões no combate as forças demoniacas para que eu possa lhe abençoar.', cid)
		npcHandler:resetNpc(cid)
		
		return true	
	end]]

	if(isPlayerPremiumCallback(cid) or not getBooleanFromString(getConfigValue('blessingsOnlyPremium')) or not parameters.premium) then
		local price = parameters.baseCost
		if(getPlayerLevel(cid) > parameters.startLevel) then
			price = (price + ((math.min(parameters.endLevel, getPlayerLevel(cid)) - parameters.startLevel) * parameters.levelCost))
		end
		
		price = (price * 5) * parameters.aditionalCostMultipler

		if(getPlayerBlessing(cid, 1) or getPlayerBlessing(cid, 2) or getPlayerBlessing(cid, 3) or getPlayerBlessing(cid, 4) or getPlayerBlessing(cid, 5)) then
			npcHandler:say("Você já possui uma ou mais benções, eu somente posso abençoar quem não foi abençoado por nenhum Deus.", cid)
		elseif(getCreatureSkull(cid) >= SKULL_WHITE) then
			npcHandler:say("Você tem sangue em suas mãos! Caia fora daqui!", cid)				
		elseif(not doPlayerRemoveMoney(cid, price)) then
			npcHandler:say("Você não tem dinheiro sulficiente. Em seu level, são necessarios " .. price .. " gold coins.", cid)		
		else
			npcHandler:say("Você recebeu todas as benções! Você esta completamente protegido!", cid)
			
			doPlayerAddBlessing(cid, 1)
			doPlayerAddBlessing(cid, 2)
			doPlayerAddBlessing(cid, 3)
			doPlayerAddBlessing(cid, 4)
			doPlayerAddBlessing(cid, 5)
		end
	else
		npcHandler:say('Eu somente posso abençoar jogadores com uma premium account.', cid)
	end

	npcHandler:resetNpc(cid)
	return true
end

function D_CustomNpcModules.getBlessPrice(cid, params)

	if(params.cost ~= 0) then
		return params.cost
	end
	
	if(getCreatureSkull(cid) >= SKULL_WHITE) then
		params.levelCost = params.levelCost * 1.5
	end

	local levels = math.max(params.startLevel, math.min(params.endLevel, getPlayerLevel(cid))) - params.startLevel
	return params.baseCost + (levels * params.levelCost)
end

function D_CustomNpcModules.offerBlessing(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.bless - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end
	
	local blessParams = {baseCost = parameters.baseCost, levelCost = parameters.levelCost, startLevel = parameters.startLevel, endLevel = parameters.endLevel, cost = parameters.cost or 0}
	
	local func = nil
	
	local pvpbless = parameters.ispvp or false
	if(pvpbless) then
		func = D_CustomNpcModules.pvpBless
		npcHandler:say('Saiba que a benção do PvP (twist of fate) não irá reduzir a penalidade quando você morre como as benções normais, mas ao invez disto, irá previnir que você perca as proprias benções normais quando você for derrotado por outro jogador (apénas jogadores!). Para adquirir-la você precisará sacrificar ' .. D_CustomNpcModules.getBlessPrice(cid, blessParams) .. ' moedas de ouro. Quer fazer isto em troca de proteção?', cid)
	else
		func = StdModule.bless
		npcHandler:say('Ao obter uma benção as penalidades na proxima vez que você morrer serão reduzidas, você gostaria de obter uma benção? Para o seu level isto lhe custará o sacrificio de ' .. D_CustomNpcModules.getBlessPrice(cid, blessParams) .. ' moedas de ouro.', cid)	
	end

	node:getParent():addChildKeyword({'yes', 'sim'}, func, parameters)
	node:getParent():addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Volte quando for necessário!'})	
end

function D_CustomNpcModules.addTradeList(shopModule, tradelist_name)

	local list = trade_lists[tradelist_name]
	
	if(list == nil) then
		print("[Warning] D_CustomNpcModules.addTradeList - Trade list with name " .. tradelist_name .. " not found.")
		return
	end	
	
	for k,v in pairs(list) do
	
		local error = false
	
		if(v.name == nil) then
			print("[Warning] D_CustomNpcModules.addTradeList - Invalid item without name found on " .. tradelist_name .. " trade list.")
			error = true
		elseif(v.sell_for == nil and v.buy_for == nil) then
			print("[Warning] D_CustomNpcModules.addTradeList - Item name " .. v.name .. " without buy or sell at " .. tradelist_name .. " trade list.")
			error = true
		end
	
		local itemtype = v.itemtype or getItemIdByName(v.name)
		
		if(not itemtype) then
			print("[Warning] D_CustomNpcModules.addTradeList - Item id not defined and not found by name " .. v.name .. " on " .. tradelist_name .. " trade list.")
		end
	
		if(not error) then
			
			-- lembrando que as funções no Jiddo são nomeadas da perspectiva do player...
			-- mas por se tratar de um NPC, vamos inverter, e partir da perspectiva deste
					
			if(v.sell_for ~= nil) then
				shopModule:addBuyableItem(nil, itemtype, v.sell_for, v.subtype, v.name)
			end
			
			if(v.buy_for ~= nil) then
				shopModule:addSellableItem(nil, itemtype, v.buy_for, v.name)
			end
		end
	end
	
	if(changeItemsPriceCallback[tradelist_name] ~= nil) then
		shopModule:addChangePriceCallback(changeItemsPriceCallback[tradelist_name])
	end
end

function D_CustomNpcModules.parseCustomParameters(keywordHandler, npcHandler)
	local trade_lists = NpcSystem.getParameter("use_trade_lists")
	if(trade_lists ~= nil) then
		local shopModule = ShopModule:new()
		npcHandler:addModule(shopModule)
		D_CustomNpcModules.parseTradeLists(shopModule, trade_lists)
	end
	
	local addon_item = NpcSystem.getParameter("call_addon_item")
	if(addon_item ~= nil) then
		local addon_func = ADDON_ITEMS[addon_item]
		addon_func(keywordHandler, npcHandler)
	end
	
	local zone_id = tonumber(NpcSystem.getParameter("daily_zone"))
	if(zone_id ~= nil) then
		local quest_id = tonumber(NpcSystem.getParameter("daily_quest"))
		if((quest_id) ~= nil) then
			local dailyModule = DailyModule:new(npcHandler, keywordHandler, zone_id, quest_id)
			dailyModule:build()
		end
	end	
end

function D_CustomNpcModules.parseTradeLists(shopModule, trade_lists)

	local lists = string.explode(trade_lists, ";")
	
	for k,v in pairs(lists) do
		D_CustomNpcModules.addTradeList(shopModule, v)
	end
end

function D_CustomNpcModules.addPromotionHandler(keywordHandler, npcHandler)
	keywordHandler:addKeyword({'promotion', 'promote', 'promoção'}, D_CustomNpcModules.callbackPromote, {npcHandler = npcHandler, onlyFocus = true})
	
	function callbackPromotionDesc(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler

		if(not npcHandler:isFocused(cid)) then
			return false
		end
		
		local desc = {
			"Os beneficios obtidos ao se promover são: a velocidade que você regenera a sua vida e sua mana serão aumentadas, você também ganhará novas habilidades para usar e também terá pequena chance de causar danos criticos além de possui penalidades nas mortes reduzidas."
		}
		
		if(desc[getPlayerPromotionLevel(cid)] ~= nil) then
			npcHandler:say(desc[getPlayerPromotionLevel(cid) + 1], cid)
		end
		
		return true
	end
	
	keywordHandler:addKeyword({'beneficios', 'benefícios'}, callbackPromotionDesc, {npcHandler = npcHandler, onlyFocus = true})
end

function D_CustomNpcModules.callbackPromote(cid, message, keywords, parameters, node)
	
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state

    if(not npcHandler:isFocused(cid)) then
        return false
    end
	
	local promotionNames = {
		{ "master sorcerer", "elder druid", "royal paladin", "elite knight" }
	}
	
	local promotions = {
		{
			message = "Com uma promoção você se tornaria um " .. promotionNames[1][getPlayerBaseVocation(cid)] .. " e também ganharia alguns {benefícios}. Para isto você deverá sacrificar 20 000 moedas de ouro. Voce quer receber esta promoção?"
			, params = {npcHandler = npcHandler, premium = true, cost = 20000, level = 20, promotion = 1, text = 'Parabens! Agora você esta promovido!', reset = true}
		}
	}
	
	local promo = promotions[getPlayerPromotionLevel(cid) + 1]
	
	if(promo == nil) then
		npcHandler:say("Desculpe, mas você ja possui todas as promoções possiveis...", cid)
	else
		npcHandler:say(promo.message, cid)
		
		-- Precisamos limpar os nodes filhos para não haver conflitos...
		node:clearChildrenNodes()
		
		node:addChildKeyword({'yes', 'sim'}, StdModule.promotePlayer, promo.params)
		node:addChildKeyword({'no','não','nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Tudo bem, posso lhe ajudar em algo mais?', reset = true})
	end
	
	return true
end
