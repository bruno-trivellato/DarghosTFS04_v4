local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local tellingAStory
 
function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)        npcHandler:onCreatureSay(cid, type, msg) end
function onThink() if #npcHandler.focuses == 0 then selfTurn(WEST) end                npcHandler:onThink() end
 
function greetCallback(cid)
	talkState[cid] = 0
	tellingAStory = 0
	return true
end

local messagesTable = {
	mission_firstTalk = {
		"Você deve ter ouvido sobre os problemas que estamos enfrentando aqui em Kashmir. Nossas forças são limitadas e precisamos de ajuda externa.",
		"Quer saber o que está acontecendo?",
	},
	mission_secondTalk = {
		"Bom, o nosso maior problema é o meu superior. Um dos nobres mais ricos e poderosos de Kashmir, seu nome é Azerus. Ele vem agindo de forma muita estranha ultimamente e percebi que a situação chegou a um nível crítico.",
		"Muitos nobres com quem ele disputava o poder e as riquezas de Kashmir foram mortos. E as explicações todas muito suspeitas. Algumas explosões foram ouvidas vindo do esgoto, inclusive tremores contínuos à noite.",
		"Em alguns de meus sonhos vi criaturas malignas nunca antes vistas...",
		"Pelo que pude concluir Azerus está formando um exército para tomar a cidade, e depois todo o Darghos! O seu último passo parece que é algum tipo de ritual para invocar os últimos e mais poderoso demônios.",
		"O mecanismo usado para a invocação deve ficar no {centro} do seu 'laboratório' e necessita de muita energia. Preciso que você invada seu laboratório antes que ele comece a invocação e enfrente-o!",
		"Entenda que será muito perigoso, Azerus possui muitos poderes e é por isso que precisamos de sua ajuda. Então, posso contar com você?",
	},
	mission_thirdTalk = {
		"Graças aos deuses! Mas antes de ir você precisa saber de duas coisas {muito importantes}. Primeiro, preciso ter certeza que você obteve êxito, ou seja, tenha {visto com} {seus próprios olhos} que o exército de Azerus foi impedido de entrar no nosso mundo.",
		"Segundo, Azerus carrega consigo um tipo de {dispositivo teleportador} que provavelmente o teleporta para o lugar onde ele está reunindo seu exército.",
		"Lembre-se que preciso ter certeza de que você obteve êxito, caso contrário {não} poderei lhe dar acesso à sala de recompensa.",
		"Pronto! Te dei permissão para acessar o palácio. Leve outros com você porque {sozinho não conseguirá derrotá-lo}! Vá, Kashmir depende de você!",
	},
}

local function sayMessages(messageTable, delay, config, currentMessageIndex, endTalkState, changeStorage)
	if not npcHandler:isFocused(config.cid) then
		return false
	else
		doCreatureSay(config.npcCid, messageTable[currentMessageIndex], TALKTYPE_PRIVATE_NP, false, config.cid, config.npcPos)		
		if currentMessageIndex < table.getn(messageTable) then
			currentMessageIndex = currentMessageIndex + 1
			addEvent(sayMessages, delay, messageTable, delay, config, currentMessageIndex, endTalkState, changeStorage)
		elseif currentMessageIndex == table.getn(messageTable) then
			if endTalkState ~= nil then -- opção para usar a função sem mudar o talkState
				talkState[config.cid] = endTalkState
			end
			if changeStorage ~= nil then
				setPlayerStorageValue(config.cid, changeStorage.id, changeStorage.value)
			end
			tellingAStory = 0
		end
	end
end

local function npcMessagesWithDelay(cid, messagesTable, delay, endTalkState, changeStorage) -- messagesTable é o caminho para a tabela secundária desejada que contém as mensagens de certa parte da história. Delay é o tempo entre uma mensagem e outra. Pars é uma tabela que deve conter os seguintes valores: cid (do player), npcCid (cid do npc) e npcPos (posição do npc).
	
	local currentMessageIndex = 1
	local config = {cid=cid, npcCid=getNpcCid(), npcPos=getNpcPos()}
	tellingAStory = 1
	
	sayMessages(messagesTable, delay, config, currentMessageIndex, endTalkState, changeStorage)
	
	return true
end

function creatureSayCallback(cid, type, msg)
	
	if not npcHandler:isFocused(cid) then
		return false
	elseif tellingAStory == 0 then
		if  talkState[cid] == 0 then
			if msgcontains(msg, {'mission', 'missao', 'missão', 'ajuda'}) then
				if getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) == -1 then
					npcMessagesWithDelay(cid, messagesTable.mission_firstTalk, 4000, 1, {id=sid.KASHMIR_QUEST_PROGRESS})
				elseif getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) == 0 then
					selfSay("Já lhe dei permissão para acessar a sala. Vá e impeça-o enquanto há tempo!", cid)
					talkState[cid] = 0
				elseif getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) >= 1 then
					if canPlayerWearOutfitId(cid, 21) then
						selfSay("Não tenho palavras para agradecer, mas posso lhe dar mais uma recompensa: uma {vestimenta} digna de um cidadão de Kashmir!", cid)
					else
						selfSay("Você salvou Kashmir! Seremos eternamente gratos!", cid)
					end
					talkState[cid] = 0
				end
			elseif msgcontains(msg, {'outfit', 'outfits', 'vestimenta', 'vestes'}) then
				if getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) >= 1 then 
					if getPlayerStorageValue(cid, sid.KASHMIR_QUEST_OUTFIT) ~= 1 then
						selfSay("Aqui está! Para que se lembre que Kashmir sempre lembrará da sua bravura.", cid)
						doPlayerAddOutfitId(cid, 21, 3)
						setPlayerStorageValue(cid, sid.KASHMIR_QUEST_OUTFIT, 1)
					else
						selfSay("Você já possui as vestes de Kashmir! Use-as com orgulho!", cid)
					end
				elseif getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) < 1 then
					selfSay("Você não merece essa recompensa... Mas Kashmir precisa de {ajuda}, se você se juntar a nossa causa talvez eu mude de ideia.", cid)
				end
				talkState[cid] = 0
			elseif msgcontains(msg, {'addon'}) then
				selfSay("Não sei nada sobre addons... mas posso lhe dar como recompensa {vestes} especiais.", cid)
				talkState[cid] = 0
			end
		elseif talkState[cid] == 1 then
			if msgcontains(msg, {'yes', 'sim'}) then
				npcMessagesWithDelay(cid, messagesTable.mission_secondTalk, 8000, 2)
			elseif (msgcontains(msg, {'no', 'não', 'nao'}) and getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS) == -1) then
				selfSay("Caso mude de ideia estarei aqui.", cid)
				talkState[cid] = 0
			else
				selfSay("Não entendi o que você disse.", cid)
				talkState[cid] = 0
			end
		elseif talkState[cid] == 2 then
			if msgcontains(msg, {'yes', 'sim'}) then
				npcMessagesWithDelay(cid, messagesTable.mission_thirdTalk, 8000, 0, {id=sid.KASHMIR_QUEST_PROGRESS, value=0})
			elseif msgcontains(msg, {'no', 'não', 'nao'}) then
				selfSay("É uma pena. Kashmir precisa de sua ajuda, mas não posso forçá-lo...", cid)
				talkState[cid] = 0
			else
				selfSay("Não entendi o que você disse.", cid)
				talkState[cid] = 0
			end
		end
	end
	return true
end
	
			
			
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
