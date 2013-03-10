-----------
-- SUMMONER ADDON
-----------

addonSummoner = {}

function addonSummoner.changeTicket(keywordHandler, npcHandler)

	local params = {
		npcHandler = npcHandler,
		neededItems = {
			{anyOf = {{id = 7636}, {id = 7635}, {id = 7634}}, count = 100}
		},	
		receiveItems = {
			{id = 5957}
		},
		fail = "Sorry but if you want a lottery ticket you need give me 100 vials and you not have this...",
		success = "Great! I've signed you up for our bonus system. From now on, you will have the chance to win the potion belt addon!"
	}

	local node = keywordHandler:addKeyword({'ticket'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Would you like to get a lottery ticket instead of the deposit for your vials?'})
	node:addChildKeyword({'yes'}, D_CustomNpcModules.addonTradeItems, params)
	node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function harounForgeItems(keywordHandler, npcHandler)

	local params = {
		npcHandler = npcHandler,
		neededItems = {
			{name = "fire sword", count = 3}
		},	
		receiveItems = {
			{id = 5904} -- magic sulphur
		},
		fail = "Sorry, you not have 3 fire swords. And without this items I can't forge an magic sulphur...",
		success = "Here are your magic sulphur! Good luck!"
	}

	local node = keywordHandler:addKeyword({'magic sulphur'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can forge the magic sulphur, but for this I need 3 fire swords. You want it?'})
	node:addChildKeyword({'yes'}, D_CustomNpcModules.addonTradeItems, params)
	node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Ok, tell me if you need something else!'})
	
	params = {
		npcHandler = npcHandler,
		neededItems = {
			{name = "warrior helmet", count = 4}
		},	
		receiveItems = {
			{id = 5885} -- warrior sweat
		},
		fail = "Sorry, you not have 4 warrior helmets. And without this items I can't forge an warrior sweat...",
		success = "Here are your warrior sweat! Good luck!"
	}
	
	node = keywordHandler:addKeyword({'warrior sweat'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can forge the warrior sweat, but for this I need 4 warrior helmet. You want it?'})
	node:addChildKeyword({'yes'}, D_CustomNpcModules.addonTradeItems, params)
	node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Ok, tell me if you need something else!'})	

	params = {
		npcHandler = npcHandler,
		neededItems = {
			{name = "royal helmet", count = 2}
		},	
		receiveItems = {
			{id = 5884} -- fighting spirit
		},
		fail = "Sorry, you not have 2 royal helmets. And without this items I can't forge an fighting spirit...",
		success = "Here are your fighting spirit! Good luck!"
	}
	
	node = keywordHandler:addKeyword({'fighting spirit'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can forge the fighting spirit, but for this I need 2 royal helmet. You want it?'})
	node:addChildKeyword({'yes'}, D_CustomNpcModules.addonTradeItems, params)
	node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Ok, tell me if you need something else!'})	

	params = {
		npcHandler = npcHandler,
		neededItems = {
			{name = "boots of haste"}
		},	
		receiveItems = {
			{id = 5891} -- enchanted chicken wing
		},
		fail = "Sorry, you not have a boots of haste. And without this items I can't forge an enchanted chicken wing...",
		success = "Here are your enchanted chicken wing! Good luck!"
	}	
	
	node = keywordHandler:addKeyword({'enchanted chicken wing'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can forge the enchanted chicken wing, but for this I need an boots of haste. You want it?'})
	node:addChildKeyword({'yes'}, D_CustomNpcModules.addonTradeItems, params)
	node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Ok, tell me if you need something else!'})	
end

ADDON_ITEMS = {
	["summoner_changeticket"] = addonSummoner.changeTicket,
	["haroun_forge"] = harounForgeItems
}