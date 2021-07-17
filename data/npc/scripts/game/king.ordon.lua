local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)                  npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)               npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)          npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                              npcHandler:onThink()                                    end

STATE_NONE = -1
STATE_ACCEPT = 0

EVENT_ITEMS = {
	2743, -- heaven blossom
	2680, -- strawberrys
	1746, -- treasure chest
	2472, -- magic plate armor
	3967 -- tribal mask
}

function facebookEventCallback(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state

    if(not npcHandler:isFocused(cid)) then
        return false
    end
	
	if(getStorage(gid.FACEBOOK_ORDON_EVENT_WINNER) ~= -1) then
		return false
	end
	
	local state = getPlayerStorageValue(cid, sid.FACEBOOK_EVENT_STATE)
	if(talkState == 0) then
		if(state == STATE_NONE) then
			npcHandler:say("O Dark General roubou alguns de meus mais valiosos pertences e os escondeu nos lugares mais remotos de Darghos. Você gostaria de ajudar procurando os pertences roubados?", cid)
			
			node:clearChildrenNodes()
			
			node:addChildKeyword({'sim', 'yes'}, facebookEventCallback, {npcHandler = npcHandler, talk_state = 1})
			node:addChildKeyword({'não', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = "Que rude! Tu não deverias fazer parte deste reino!", reset = true})
		elseif(state == STATE_ACCEPT) then
			npcHandler:say("Seja bem vindo de volta " .. getPlayerName(cid).. "! Eu estava ancioso por noticias suas. E então, conseguiu encontrar meus pertences?" , cid)
		
			node:clearChildrenNodes()
			
			node:addChildKeyword({'sim', 'yes'}, facebookEventCallback, {npcHandler = npcHandler, talk_state = 2})
			node:addChildKeyword({'não', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = "Oh, que pena... Seja breve! Tenho pressa em recuperar-los!", reset = true})
		end
	elseif(talkState == 1) then
		
		npcHandler:say("Otimo! Como dito, os pertences foram escondidos pelo Darghos, sua missão será encontrar-los, juntar-los e trazer-los para mim. Por motivos de segurança informações sobre os items serão divulgados fora do jogo, no website: www.darghos.com.br! Boa sorte!", cid)
		setPlayerStorageValue(cid, sid.FACEBOOK_EVENT_STATE, STATE_ACCEPT)
	elseif(talkState == 2) then
		
		local foundAllItems = true
		
		for _,v in pairs(EVENT_ITEMS) do
			if(getPlayerItemCount(cid, v) == 0) then
				foundAllItems = false
				break
			end
		end
		
		if (not foundAllItems) then
			npcHandler:say("Algo esta errado, você não possui os meus pertences, volte aqui quando estiver com todos meus pertences!", cid)
			npcHandler:resetNpc(cid)
			return false
		else
			for _,v in pairs(EVENT_ITEMS) do
				if(not doPlayerRemoveItem(cid, v, 1)) then
					error("Cannot remove item: " .. v .. " of player " .. getPlayerName(cid))
					break
				end
			end
			
			npcHandler:say("Bravo guerreiro, tenho certeza que você vagou muito pelas terras Darghonianas para conseguir os meus pertences de volta! Você foi corajoso e valente, e como prova de minha gratidão, aceite meu presente.", cid)
			
			local vocationName = "sorcerer"
			
			if (isDruid(cid)) then
				vocationName = "druid"
			elseif(isPaladin(cid)) then
				vocationName = "paladin"
			elseif(isKnight(cid)) then
				vocationName = "knight"
			end
			
			doBroadcastMessage("Rei Ordon: Meus pertences finalmente foram encontrados pelo bravo e valente " .. vocationName .. " chamado " .. getPlayerName(cid) .. " e ele receberá a minha generosa recompensa! Obrigado a todos Darghonianos que prestaram a sua ajuda nesta missão!", MESSAGE_EVENT_ADVANCE)
			doPlayerAddItem(cid, CUSTOM_ITEMS.ORDON_DESTRUCTION_AMULET)
			
			doSetStorage(gid.FACEBOOK_ORDON_EVENT_WINNER, getPlayerGUID(cid))
			
			npcHandler:resetNpc(cid)
		end
	end
	
	return true
end

talkState = {}

--keywordHandler:addKeyword({'pertences'}, facebookEventCallback, {npcHandler = npcHandler, talk_state = 0, nlyFocus = true})

D_CustomNpcModules.addPromotionHandler(keywordHandler, npcHandler)

keywordHandler:addKeyword({'ajuda', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'A jogadores que já tiverem atingido level 20 e possuirem uma Conta Premium eu posso conceder a {promoção}!'})

npcHandler:addModule(FocusModule:new())
