local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

keywordHandler:addKeyword({'bless', 'benção', 'bencao'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 3, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})

npcHandler:addModule(FocusModule:new())
