local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

keywordHandler:addKeyword({'twist of fate', 'pvp bless'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, ispvp = true, cost = 50000})
keywordHandler:addKeyword({'job', 'trabalho', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'The newscomer sometimes need a help, I do that. I can give you {blessings} also {twist of fate} to protect your regular blessings. How can I help you?'})
keywordHandler:addKeyword({'bless', 'bençao', 'blessings'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, isall = true, baseCost = 10000, levelCost = 1000, startLevel = 30, endLevel = 120})

npcHandler:addModule(FocusModule:new())