local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- OTServ event handling functions start
function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) 	npcHandler:onCreatureSay(cid, type, msg) end
function onThink() 						npcHandler:onThink() end
-- OTServ event handling functions end
    
boatDestiny.addAracura(keywordHandler, npcHandler)
boatDestiny.addAaragon(keywordHandler, npcHandler)
boatDestiny.addNorthrend(keywordHandler, npcHandler)
boatDestiny.addSalazart(keywordHandler, npcHandler)
        
npcHandler:setMessage(MESSAGE_GREET, "Greetings |PLAYERNAME|. I can take you to {aracura}, {aaragon} and {northrend} also {salazart}. Which of these places you wold like to travel?.")
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I\'m the ship captain!'})

-- Makes sure the npc reacts when you say hi, bye etc.
npcHandler:addModule(FocusModule:new())