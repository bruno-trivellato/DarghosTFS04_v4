local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- OTServ event handling functions start
function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) 	npcHandler:onCreatureSay(cid, type, msg) end
function onThink() 						npcHandler:onThink() end
-- OTServ event handling functions end

boatDestiny.addQuendorFromIslandOfPeace(keywordHandler, npcHandler)
        
local text = 'Meu navio pode levar-lo ocasionamente a {quendor}.'      
        
keywordHandler:addKeyword({'passage', 'travel', 'passagem', 'viajar', 'cidades'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = text})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu sou o Capitão deste navio.'})

-- Makes sure the npc reacts when you say hi, bye etc.
npcHandler:addModule(FocusModule:new())