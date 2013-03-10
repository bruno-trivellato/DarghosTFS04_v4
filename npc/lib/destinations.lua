-----------
-- BOATS
-----------

boatDestiny = {
	pvpChangedList = {}
}

function boatDestiny.addQuendor(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'quendor'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to quendor for 110 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = false, level = 0, cost = 110, destination = BOAT_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addAracura(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'aracura'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to aracura for 160 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 160, destination = BOAT_DESTINY_ARACURA, pvpEnabledOnly = true})
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addAaragon(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'aaragon'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to aaragon for 130 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 130, destination = BOAT_DESTINY_AARAGON })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addSalazart(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'salazart'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to salazart for 130 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 130, destination = BOAT_DESTINY_SALAZART })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addNorthrend(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'northrend'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to northrend for 240 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 240, destination = BOAT_DESTINY_NORTHREND })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addKashmir(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'kashmir'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to kashmir for 150 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 150, destination = BOAT_DESTINY_KASHMIR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addThaun(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'thaun'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to island of thaun for 110 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 110, destination = BOAT_DESTINY_THAUN })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addSeaSerpentArea(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'sea serpent', 'sea serpent area'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to be taken to sea serpent area for 800 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, cost = 800, destination = BOAT_DESTINY_SEA_SERPENT_AREA })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addIslandOfPeace(keywordHandler, npcHandler)

	local function onAsk(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(darghos_world_configuration == WORLD_CONF_CHANGE_ALLOWED) then
			if(doPlayerIsPvpEnable(cid)) then
				npcHandler:say('Desculpe, mas você é um jogador agressivo! Torne-se um jogadores pacificos primeiro se quiser viajar para Island of Peace!', cid)
				npcHandler:resetNpc(cid)
				return false
			end
			
			npcHandler:say('Você gostaria de pagar 200 moedas de ouro pela passagem de volta a tranquilidade de Island of Peace?', cid)
		elseif(darghos_world_configuration == WORLD_CONF_WEECLY_CHANGE) then
			
			if(getPlayerLevel(cid) <= darghos_weecly_change_max_level_any_day) then
				npcHandler:say('Você gostaria de se mudar para Island of Peace? Lembre-se que ate atingir o nivel ' .. (darghos_weecly_change_max_level_any_day + 1) .. ' você podera fazer essa viagem a qualquer instante e de graça!', cid)
			elseif(getPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP) == -1) then
				npcHandler:say('Você gostaria de se mudar para Island of Peace e se tornar um jogador pacifico?', cid)
			elseif(getPlayerPremiumDays(cid) > 0) then
				npcHandler:say('Você gostaria de se mudar para Island of Peace e se tornar um jogador pacifico? PRESTE ATENÇÃO: PARA O SEU NÍVEL {ESTA MUDANÇA IRA CONSUMIR ' .. getChangePvpPrice(cid) .. ' DIAS DE SUA CONTA PREMIUM}! VOCÊ TEM CERTEZA QUE REALMENTE DESEJA ISTO?', cid)
			else
				npcHandler:say('Para efetuar uma mudança para Island of Peace e se tornar um jogador pacifico em seu nível é necessario possuir dias de conta premium.', cid)
				npcHandler:resetNpc(cid)
				return false				
			end
		end
		
		
		return true
	end
	
	local function onAccept(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(darghos_world_configuration == WORLD_CONF_CHANGE_ALLOWED) then	
			if(not doPlayerRemoveMoney(cid, parameters.cost)) then
				npcHandler:say('Oh, infelizmente você não possui o dinheiro necessario para embarcar...', cid)
				npcHandler:resetNpc(cid)
				return true
			end
		elseif(darghos_world_configuration == WORLD_CONF_WEECLY_CHANGE) then
			
			local price = getChangePvpPrice(cid)
			
			if(getPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP) == -1) then
				setPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP, 1)			
			elseif(price > 0) then
				if(getPlayerPremiumDays(cid) < price) then
					npcHandler:say('Desculpe, mas esta mudança consome ' .. price .. ' dias de premium de sua conta, e você não possui isto!', cid)
					npcHandler:resetNpc(cid)
					return true				
				end
			
				doPlayerAddPremiumDays(cid, -price)
			end
			
			doPlayerSetTown(cid, towns.ISLAND_OF_PEACE)
			doPlayerDisablePvp(cid)
		end
		
		npcHandler:say('Seja bem vindo de volta a Island of Peace caro ' .. getPlayerName(cid) .. '!', cid)
		doTeleportThing(cid, parameters.destination, false)
		doSendMagicEffect(parameters.destination, CONST_ME_TELEPORT)
		return true		
	end

	local travelNode = keywordHandler:addKeyword({'island of peace', 'isle of peace'}, onAsk, {npcHandler = npcHandler, onlyFocus = true})
	travelNode:addChildKeyword({'yes', 'sim'}, onAccept, {npcHandler = npcHandler, cost = 200, destination = BOAT_DESTINY_ISLAND_OF_PEACE })
	travelNode:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Mas que pena... Mas tenha um bom dia!!'})
end

function boatDestiny.addQuendorFromIslandOfPeace(keywordHandler, npcHandler)

	local function onAsk(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(darghos_world_configuration == WORLD_CONF_CHANGE_ALLOWED) then
			local hasFirstChangePvpArea = getPlayerStorageValue(cid, sid.FIRST_CHANGE_PVP_AREA) == 1
			
			if(not hasFirstChangePvpArea) then
				npcHandler:say('Vejo que você nunca viajou para Quendor, este barco pode levar-lo para lá, por ser sua primeira viagem, não lhe será cobrado nada, porém saiba que fora de Island of Peace você poderá ativar ou desativar <...>', cid)
				npcHandler:say('a habilidade de entrar em combate com outros jogadores, isto é, seu pvp. Inicialmente o seu pvp está desativado, caso você deseje o ativar converse com o NPC\'s que ficam no templo de todas cidades. <...>', cid)
				npcHandler:say('Saiba também que somente é permitido voltar para Island of Peace jogadores que estiverem com seu pvp desativado, se você o ativar-lo, não poderá voltar. <...>', cid)			
				npcHandler:say('E então, deseja mesmo embarcar para Quendor?', cid)
				
				return true
			end
			
			npcHandler:say('Você gostaria de pagar 200 moedas de ouro para viajar para Quendor?', cid)
		elseif(darghos_world_configuration == WORLD_CONF_WEECLY_CHANGE) then
			
			if(getPlayerLevel(cid) <= darghos_weecly_change_max_level_any_day) then
				npcHandler:say('Você gostaria de se mudar para Quendor? Lembre-se que ate atingir o nivel ' .. (darghos_weecly_change_max_level_any_day + 1) .. ' você podera fazer essa viagem a qualquer instante e de graça!', cid)
			elseif(getPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP) == -1) then
				npcHandler:say('Você gostaria de se mudar para Quendor e se tornar um jogador agressivo?', cid)			
			elseif(getPlayerPremiumDays(cid) > 0) then
				npcHandler:say('Você gostaria de se mudar para Quendor e se tornar um jogador agressivo? PRESTE ATENÇÃO: PARA O SEU NÍVEL {ESTA MUDANÇA IRA CONSUMIR ' .. getChangePvpPrice(cid) .. ' DIAS DE SUA CONTA PREMIUM}! VOCÊ TEM CERTEZA QUE REALMENTE DESEJA ISTO?', cid)
			else
				npcHandler:say('Para efetuar uma mudança para Quendor e se tornar um jogador agressivo em seu nível é necessario possuir dias de conta premium.', cid)
				npcHandler:resetNpc(cid)
				return false	
			end
		elseif(darghos_world_configuration == WORLD_CONF_AGRESSIVE_ONLY) then
			npcHandler:say('Quendor é uma maravilhosa cidade! Mais saiba que por lá e por todo o resto do mundo do Darghos o seu PvP e de todos outras é sempre ativo, assim você poderá  <...>', cid)
			npcHandler:say('atacar e ser atacado por outras pessoas... Também esteja ciente que uma vez abandonando esta ilha você se tornará cidadão de Quendor não será mais possivel retornar <...>', cid)
			npcHandler:say('E então, deseja mesmo embarcar para Quendor?', cid)		
		end
		
		return true
	end
	
	local function onAccept(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(darghos_world_configuration == WORLD_CONF_CHANGE_ALLOWED) then
			local hasFirstChangePvpArea = getPlayerStorageValue(cid, sid.FIRST_CHANGE_PVP_AREA) == 1
			
			if(hasFirstChangePvpArea and not doPlayerRemoveMoney(cid, parameters.cost)) then
				npcHandler:say('Oh, infelizmente você não possui o dinheiro necessario para embarcar...', cid)
				npcHandler:resetNpc(cid)
				return true
			end	
			
			if(not hasFirstChangePvpArea) then
				npcHandler:say('Seja bem vindo a Quendor caro ' .. getPlayerName(cid) .. '! Para chegar na cidade, siga para o sul e tenha cuidado com as criatura!', cid)		
				setPlayerStorageValue(cid, sid.FIRST_CHANGE_PVP_AREA, 1)
			else		
				npcHandler:say('Seja bem vindo de volta a Quendor caro ' .. getPlayerName(cid) .. '!', cid)
			end
			
			if(getConfigInfo("worldId") == WORLD_AARAGON) then
				doPlayerSetTown(cid, towns.QUENDOR)
				doPlayerEnablePvp(cid)
				setStageOnChangePvp(cid)
			end
		elseif(darghos_world_configuration == WORLD_CONF_WEECLY_CHANGE) then
			
			local price = getChangePvpPrice(cid)
			
			if(getPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP) == -1) then
				setPlayerStorageValue(cid, sid.TEMP_TEN_DAYS_FREE_CHANGE_PVP, 1)
			elseif(price > 0) then
				if(getPlayerPremiumDays(cid) < price) then
					npcHandler:say('Desculpe, mas esta mudança consome ' .. price .. ' dias de premium de sua conta, e você não possui isto!', cid)
					npcHandler:resetNpc(cid)
					return true				
				end
			
				doPlayerAddPremiumDays(cid, -price)
			end			
			
			doPlayerSetTown(cid, towns.QUENDOR)
			doPlayerEnablePvp(cid)
			
			npcHandler:say('Seja bem vindo de volta a Quendor caro ' .. getPlayerName(cid) .. '!', cid)
		elseif(darghos_world_configuration == WORLD_CONF_AGRESSIVE_ONLY) then
			doPlayerSetTown(cid, towns.QUENDOR)
			doPlayerEnablePvp(cid)
			setStageOnChangePvp(cid)
			
			npcHandler:say('Seja bem vindo a Quendor caro ' .. getPlayerName(cid) .. '!', cid)
		end
		
		doTeleportThing(cid, parameters.destination, false)
		doSendMagicEffect(parameters.destination, CONST_ME_TELEPORT)		
		return true
	end

	local travelNode = keywordHandler:addKeyword({'quendor'}, onAsk, {npcHandler = npcHandler, onlyFocus = true})
	travelNode:addChildKeyword({'yes', 'sim'}, onAccept, {npcHandler = npcHandler, cost = 200, destination = BOAT_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Mas que pena... Mas tenha um bom dia!!'})
end

-----------
-- CARPETS
-----------

carpetDestiny = {}

function carpetDestiny.addAaragon(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'aaragon'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Aaragon for 60 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 60, destination = CARPET_DESTINY_AARAGON })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function carpetDestiny.addHills(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'hills'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Hills for 60 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 60, destination = CARPET_DESTINY_HILLS })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function carpetDestiny.addSalazart(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'salazart'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Salazart for 40 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 40, destination = CARPET_DESTINY_SALAZART })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

-----------
-- TRAINS
-----------

trainDestiny = {}

function trainDestiny.addQuendor(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'quendor'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to entrain and go to Quendor for 100 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = false, level = 0, cost = 100, destination = TRAIN_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function trainDestiny.addThorn(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'thorn'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to entrain and go to Thorn for 100 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = false, level = 0, cost = 100, destination = TRAIN_DESTINY_THORN })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

