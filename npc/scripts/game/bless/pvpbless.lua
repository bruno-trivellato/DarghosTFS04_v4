local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

keywordHandler:addKeyword({'bless', 'benção', 'bencao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'A você posso conceder a {primeira}, {segunda}, {terceira}, {quarta} e {quinta} benção. Você também pode se interessas em obter {todas} as benções.'})

keywordHandler:addKeyword({'primeira'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 1, premium = false, baseCost = 40000, levelCost = 0, startLevel = 30, endLevel = 120})
keywordHandler:addKeyword({'segunda'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 2, premium = false, baseCost = 40000, levelCost = 0, startLevel = 30, endLevel = 120})
keywordHandler:addKeyword({'terceira'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 3, premium = false, baseCost = 40000, levelCost = 0, startLevel = 30, endLevel = 120})
keywordHandler:addKeyword({'quarta'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 4, premium = true, baseCost = 40000, levelCost = 0, startLevel = 30, endLevel = 120})
keywordHandler:addKeyword({'quinta'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, number = 5, premium = true, baseCost = 40000, levelCost = 0, startLevel = 30, endLevel = 120})

keywordHandler:addKeyword({'todas'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, isall = true, premium = true, baseCost = 200000, levelCost = 0, startLevel = 30, endLevel = 120})

--keywordHandler:addKeyword({'job', 'trabalho', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu ajudo os novatos que passam por aqui. Eu também sou autorizado a abençoar com a {twist of fate}, a benção para o {pvp}.'})


npcHandler:addModule(FocusModule:new())
