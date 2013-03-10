local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)                          npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)                       npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)                  npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                                      npcHandler:onThink()                                    end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'holy tible'}, 1970, 1000, 1, 'holy tible')

local ITEM_HALLOWED_AXE = 8293
local ITEM_AXE = 2386
local MONEY = 1000

local TASK_DEMONS_KILL = 6666

function tradeHallowedAxe(cid, message, keywords, parameters, node)

    if(not npcHandler:isFocused(cid)) then
        return false
    end
    
    if(getPlayerItemCount(cid, ITEM_AXE) < 1 or getPlayerMoney(cid) < MONEY) then
    	npcHandler:say("Você não possui os itens solicitados, retorne aqui quando os possuir!", cid)
    	npcHandler:resetNpc(cid)
    	return true
    end
    
    if(doPlayerRemoveItem(cid, ITEM_AXE, 1) and doPlayerRemoveMoney(cid, MONEY)) then
		local tmp = doCreateItemEx(ITEM_HALLOWED_AXE, 1)
		if(doPlayerAddItemEx(cid, tmp, true) ~= RETURNVALUE_NOERROR) then
			error('Impossivel adicionar o item ao jogador')
			return false
		else
	    	npcHandler:say("Aqui está o seu hallowed axe! Boa sorte!", cid)
	    	npcHandler:resetNpc(cid)
	    	return true			
		end
    end
end

function onAskTask(cid, message, keywords, parameters, node)

    if(not npcHandler:isFocused(cid)) then
        return false
    end
    
    local taskStatus = getPlayerStorageValue(cid, sid.TASK_KILL_DEMONS)
    
    if(taskStatus == -1) then
     	npcHandler:say("Estamos com problemas com o exesso de Demônios, e precisamos de toda ajuda possivel! Você poderia nos ajudar derrotando" .. TASK_DEMONS_KILL .. " demônios?", cid)	
    	return true
	elseif(taskStatus == 0) then
     	npcHandler:say("Você completou a sua tarefa de derrotar " .. TASK_DEMONS_KILL .. " demônios?", cid)
    	return true 	
	elseif(taskStatus == 1) then
     	npcHandler:say("Infelizmente não possuo mais nenhuma tarefa para você...", cid)
     	npcHandler:resetNpc(cid)
    	return true 	
    end
end

function onAcceptTask(cid, message, keywords, parameters, node)

    if(not npcHandler:isFocused(cid)) then
        return false
    end
    
    local taskStatus = getPlayerStorageValue(cid, sid.TASK_KILL_DEMONS)
    
    if(taskStatus == 1) then
    	npcHandler:say("Infelizmente não possuo mais nenhuma tarefa para você...", cid)
    	npcHandler:resetNpc(cid)
    	return true
    end
    
    if(taskStatus == -1) then
    	setPlayerStorageValue(cid, sid.TASK_KILL_DEMONS, 0)
     	npcHandler:say("Sua ajuda será muito valiosa " .. getPlayerName(cid) .. "! Me procure quando tiver concluido sua tarefa,", cid)
    	npcHandler:resetNpc(cid)
    	return true   	
    end
    
    if(taskStatus == 0) then
    	local slainDemons = getPlayerStorageValue(cid, sid.TASK_KILLED_DEMONS) or 0
    	
    	if(slainDemons >= TASK_DEMONS_KILL) then
    		setPlayerStorageValue(cid, sid.TASK_KILL_DEMONS, 1)
	      	npcHandler:say("Como você esteve empenhado! Seremos eternamente gratos pela sua contribuição! Como recompensa você agora tem permissão para entrar na area infectada aonde fica o The Demon Oak.", cid)
	    	npcHandler:resetNpc(cid)
	    	return true      	
    	else	
  	      	npcHandler:say("Ainda resta que você derrote mais " .. TASK_DEMONS_KILL - slainDemons .." demônios para concluir a sua tarefa.", cid)
	    	npcHandler:resetNpc(cid)
	    	return true        	
    	end
    end    
end

function onAskDemonOak(cid, message, keywords, parameters, node)

    if(not npcHandler:isFocused(cid)) then
        return false
    end
    
    local killDemonOak = getPlayerStorageValue(cid, sid.KILL_DEMON_OAK)
    
    if(killDemonOak == -1) then
    
  		npcHandler:say("Ele está localizao ao leste daqui, em uma area infectada, não muito longe. Há rumores que os que o derrotaram ganharam valiosas recompensas.", cid)
	    npcHandler:resetNpc(cid)
	    return true     
    elseif(killDemonOak == 1) then
    
  		npcHandler:say("Parabens! Você derrotou o Demon Oak! Você agora poderá acessar a valiosa recompensa! Siga para o sul da area infectada e procure o tumulo de Yesim Adeit.", cid)
	    npcHandler:resetNpc(cid)
	    return true        
    end   
end

local node1 = keywordHandler:addKeyword({'hallowed axe'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu posso fazer um para você! Para isso preciso de ' .. MONEY .. ' moedas de ouro além de um machado. Você possui estes items?'})
    node1:addChildKeyword({'yes', 'sim'}, tradeHallowedAxe, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node1:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Oaaah...', reset = true})
    
local node2 = keywordHandler:addKeyword({'mission', 'task'}, onAskTask, {npcHandler = npcHandler, onlyFocus = true})
    node2:addChildKeyword({'yes', 'sim'}, onAcceptTask, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node2:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Espero que um dia retorne para nos  ajudar...', reset = true})    

keywordHandler:addKeyword({'demon oak', 'the demon oak'}, onAskDemonOak, {npcHandler = npcHandler, onlyFocus = true})

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())