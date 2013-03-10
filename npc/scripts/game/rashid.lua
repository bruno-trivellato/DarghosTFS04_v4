local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
D_CustomNpcModules.parseCustomParameters(keywordHandler, npcHandler)

function onCreatureAppear(cid)                          npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)                       npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)                  npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                                      npcHandler:onThink()                                    end
function onPlayerEndTrade(cid)                          npcHandler:onPlayerEndTrade(cid)                        end
function onPlayerCloseChannel(cid)                      npcHandler:onPlayerCloseChannel(cid)            		end

function greetCallback(cid)
	
	if(not isPremium(cid)) then
		npcHandler:say('Eu compro uma grande variedade de armas e equipamentos por um bom preço! Mas somente negocio com jogadores que disponham de uma Conta Premium...', cid)
		npcHandler:resetNpc(cid)
		return false		
	end
	
	npcHandler:say('Olá! Eu compro uma grande variedade de itens.', cid)
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:addModule(FocusModule:new())
