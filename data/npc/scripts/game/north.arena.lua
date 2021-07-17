local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

function greenhornCallback(cid, message, keywords, parameters, node)
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end
	
	local arenaLevel = getPlayerStorageValue(cid, sid.CAN_ENTER_ARENA)
	if(arenaLevel ~= -1) then
		npcHandler:say("Sorry, you already pay the fee to enter in an arena! Go face the arena gladiators!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	if(not doPlayerRemoveMoney(cid, 1000)) then
		npcHandler:say("Sorry, you must have 1.000 gold coins to pay the fee to enter in the greenhorn arena!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	setPlayerStorageValue(cid, sid.ARENA_LEVEL, ARENA_LEVEL_GREENHORN)
	setPlayerStorageValue(cid, sid.CAN_ENTER_ARENA, 1)
	setPlayerStorageValue(cid, sid.CURRENT_ARENA, -1)
	
	npcHandler:say("All right! I think that this will not be very hard for you! Go downstairs and passtrough the arena door and enter in the magic portal to face the first greenhorn gladiator: the frostfur!", cid)
	return true
end

function scrapperCallback(cid, message, keywords, parameters, node)
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end
	
	local arenaLevel = getPlayerStorageValue(cid, sid.CAN_ENTER_ARENA)
	if(arenaLevel ~= -1) then
		npcHandler:say("Sorry, you already pay the fee to enter in an arena! Go face the arena gladiators!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	local hasGreenhornMode = getPlayerStorageValue(cid, sid.ARENA_GREENHORN_DOOR) == 1
	if(not hasGreenhornMode) then
		npcHandler:say("Sorry, to enter in the scrapper arena mode you must first won the greenhorn mode!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	if(not doPlayerRemoveMoney(cid, 5000)) then
		npcHandler:say("Sorry, you must have 5.000 gold coins to pay the fee to enter in the scrapper arena!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	setPlayerStorageValue(cid, sid.ARENA_LEVEL, ARENA_LEVEL_SCRAPPER)
	setPlayerStorageValue(cid, sid.CAN_ENTER_ARENA, 1)
	setPlayerStorageValue(cid, sid.CURRENT_ARENA, -1)
	
	npcHandler:say("It's good! Scrapper is not very hard but some of the gladiators will give some work to you! Go downstairs and passtrough the arena door and enter in the magic portal to face the first scrapper gladiator: the avalanche!", cid)
	return true	
end

function warlordCallback(cid, message, keywords, parameters, node)
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end
	
	local arenaLevel = getPlayerStorageValue(cid, sid.CAN_ENTER_ARENA)
	if(arenaLevel ~= -1) then
		npcHandler:say("Sorry, you already pay the fee to enter in an arena! Go face the arena gladiators!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	local hasGreenhornMode, hasScrapperMode = getPlayerStorageValue(cid, sid.ARENA_GREENHORN_DOOR) == 1, getPlayerStorageValue(cid, sid.ARENA_SCRAPPER_DOOR) == 1
	if(not hasGreenhornMode or not hasScrapperMode) then
		npcHandler:say("Sorry, to enter in the warlord arena mode you must first won the greenhorn and scrapper modes!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	if(not doPlayerRemoveMoney(cid, 10000)) then
		npcHandler:say("Sorry, you must have 10.000 gold coins to pay the fee to enter in the warlord arena!", cid)
		npcHandler:resetNpc(cid)
		
		return true
	end
	
	setPlayerStorageValue(cid, sid.ARENA_LEVEL, ARENA_LEVEL_WARLORD)
	setPlayerStorageValue(cid, sid.CAN_ENTER_ARENA, 1)
	setPlayerStorageValue(cid, sid.CURRENT_ARENA, -1)
	
	npcHandler:say("You will need luck guy! You will face the best arena gladiators in warlord mode! Go downstairs and passtrough the arena door and enter in the magic portal to face the first warlord gladiator: the webster!", cid)
	return true		
end
	
local node1 = keywordHandler:addKeyword({'fight'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Oh yeah! We have three dificulty levels for arena: {greenhorn} is the more easy and the entrance fee is 1.000 gold coins, {scrapper} is the medium and the entrance fee is 5.000 gold coins and {warlord} is the hard mode and the entrance fee is 10.000 gold coins! Please, say me which of these modes you want challenge?'})
	node1:addChildKeyword({'greenhorn'}, greenhornCallback, {npcHandler = npcHandler, onlyFocus = true, reset = true})
	node1:addChildKeyword({'scrapper'}, scrapperCallback, {npcHandler = npcHandler, onlyFocus = true, reset = true})
	node1:addChildKeyword({'warlord'}, warlordCallback, {npcHandler = npcHandler, onlyFocus = true, reset = true})
	
npcHandler:addModule(FocusModule:new())