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
boatDestiny.addQuendor(keywordHandler, npcHandler)      
boatDestiny.addKashmir(keywordHandler, npcHandler)       
boatDestiny.addSeaSerpentArea(keywordHandler, npcHandler)
        
npcHandler:setMessage(MESSAGE_GREET, "Greetings |PLAYERNAME|. I can take you to {aracura}, {quendor}, {kashmir} and {aaragon} also some {hunting places}. Which of these places you wold like to travel?.")
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I am the captain of this ship.'})
keywordHandler:addKeyword({'hunting places', 'hunt'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can take you to the open sea, where you can found the {sea serpent} area.'})

-- Makes sure the npc reacts when you say hi, bye etc.
npcHandler:addModule(FocusModule:new())