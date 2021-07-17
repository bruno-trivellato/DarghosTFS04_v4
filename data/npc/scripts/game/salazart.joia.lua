local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
D_CustomNpcModules.parseCustomParameters(keywordHandler, npcHandler)

function onCreatureAppear(cid)                          npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)                       npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)                  npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                                      npcHandler:onThink()                                    end

local AMULET_PIECES = { 8262, 8263, 8264, 8265 } 
local ITEM_KOSHEI_AMULET = 8266

function hasAllPieces(cid, pieces)
	local found = 0
	for k,v in pairs(pieces) do
		if(getPlayerItemCount(cid, v) >= 1) then found = found + 1 end		
	end
	
	return found >= #pieces
end

function takeAllPieces(cid, pieces)
	for k,v in pairs(pieces) do
		if not doPlayerRemoveItem(cid, v, 1) then print('[Warning - ' .. getCreatureName(getNpcId()) .. '] Impossivel remover todas as partes de ' .. getPlayerName(cid) .. '.') return false end
	end
	
	return true
end

function process(cid, message, keywords, parameters, node)
	
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end 
    
    local alreadyHasAmulet = (getPlayerStorageValue(cid, sid.GET_KOSHEI_AMULET) == 1) and true or false
    local amuletDate = getPlayerStorageValue(cid, sid.KOSHEI_AMULET_DATE)
    local hasAllPieces = hasAllPieces(cid, AMULET_PIECES)
    
    if(talkState == 1) then
    	if(not alreadyHasAmulet) then
    		if(hasAllPieces or amuletDate ~= 1) then
    			if(amuletDate == -1) then
    				npcHandler:say("Oooohhh! Quanto tempo eu não via isto? Todas as partes reunidas! Magnifico trabalho! Se você me entregar-las e mais 5000 moedas de ouro para amanha eu lhe entregarei o amuleto do velho Koshei, aceita?", cid)
    			elseif(amuletDate + (60 * 60 * 24) > os.time()) then
    				npcHandler:say("Mas ainda não se passou um dia, o seu amuleto ainda não está pronto! Deixe-me trabalhar ou irá atrazar!", cid)
    				npcHandler:resetNpc(cid)
				else
					local tmp = doCreateItemEx(ITEM_KOSHEI_AMULET, 1)
					if(doPlayerAddItemEx(cid, tmp, true) ~= RETURNVALUE_NOERROR) then
						print('[Warning - ' .. getCreatureName(getNpcId()) .. '] Impossivel adicionar o amuleto a ' .. getPlayerName(cid) .. '.')
						npcHandler:resetNpc(cid)
						return false
					end
					
					setPlayerStorageValue(cid, sid.GET_KOSHEI_AMULET, 1)
							
					npcHandler:say("Que bom lhe ver, por que tanta demora?? Tenho boas noticias! Seu amuleto está pronto! Aqui está! Espero que faça bom aproveito!", cid)
    			end
    		else
    			npcHandler:say("Então quer saber do amuleto? Ohh.. Ok! Estamos falando de um artefato muito poderoso, o amuleto de Koshei, uma criatura que acreditam ser imortal! E eu posso o fazer, você o gostaria?", cid)
    		end		
    	else
    		npcHandler:say("Mas que pena, não conheço outros amuletos especiais além do que já lhe fiz...", cid)
    		npcHandler:resetNpc()
    	end
    elseif(talkState == 2) then
    	if(hasAllPieces) then
    		if(takeAllPieces(cid, AMULET_PIECES)) then
    			doPlayerRemoveMoney(cid, 5000)
    			setPlayerStorageValue(cid, sid.KOSHEI_AMULET_DATE, os.time())
    			npcHandler:say("Otimo, agora mê de um dia para trabalhar na restauração, retorne amanha e lhe entregarei o amuleto!", cid)
			else
				npcHandler:resetNpc()
				return false
    		end
    	else
    		npcHandler:say("Bom, para conseguir-lo não será facil, pois o amuleto foi partido em quatro partes que estão espalhadas por todo deserto de Salazart. Mas eu sei o lugar aproximado em que elas estão, você precisará buscar-las, certo?", cid)
    	end 	
    elseif(talkState == 3) then
    	npcHandler:say("Preste atenção: O paradeiro da primeira parte é uma camara no sub-solo não muito longe daqui ao sudoeste, proximo a entrada para o barco da cidade, procure-o nas raizes do chão. Para a segunda parte siga ao sudeste, procure na proa do barco dos piratas esqueletos.", cid)
    	npcHandler:say("Para a terceira parte siga ao norte, e você encontrará um pequeno oásis, procure nas arvores. E finalmente para a quarta e última parte siga ao noroeste pela margem do oceano, logo quando este der lugar a montanha examine as rochas. Retorne quando estiver com todas as partes.", cid)
    end
    
    return true
end

local node1 = keywordHandler:addKeyword({'amuleto'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 1})
    local node2 = node1:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 2})
   		node2:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 3})   
    	node2:addChildKeyword({'no', 'não', 'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Que pena... Tem algo mais em que eu possa lhe ajudar?', reset = true})
    
    node1:addChildKeyword({'no', 'não', 'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Que pena... Tem algo mais em que eu possa lhe ajudar?', reset = true})

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())