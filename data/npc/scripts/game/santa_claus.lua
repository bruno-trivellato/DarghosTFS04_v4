local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

local confirmPattern = {'yes', 'sim'}
local negationPattern = {'no', 'não', 'nao'}

local TALK_MISSION = {
	NONE = 0,
	YES = 1,
}

local TALK_STATE = TALK_MISSION.NONE

function npcSystemHeader(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end
	
	return true
end

function noCallback(cid, message, keywords, parameters, node)

	local messages = {
		"Feliz natal ho ho ho!"
	}

	local rand = math.random(1, #messages)
	local npcHandler = parameters.npcHandler
	npcHandler:say(messages[rand], cid)
	
	npcHandler:resetNpc(cid)
	return true
end

function confirmCallback(cid, message, keywords, parameters, node)

	if(not npcSystemHeader(cid, message, keywords, parameters, node)) then
		return false
	end

	if parameters.talkState == TALK_MISSION.YES then
		local npcHandler = parameters.npcHandler

		setPlayerStorageValue(cid, sid.SANTA_CLAUS_MISSION, 0)
		npcHandler:say("Retorne aqui quando terminar para receber seu presente!", cid)
		npcHandler:resetNpc(cid)
	else
		parameters.talkState = TALK_MISSION.NONE
		return true
	end
	
	return true
end

function missionCallback(cid, message, keywords, parameters, node)

	if(not npcSystemHeader(cid, message, keywords, parameters, node)) then
		return false
	end
	
	local npcHandler = parameters.npcHandler

	local questStatus = getPlayerStorageValue(cid, sid.SANTA_CLAUS_MISSION)
	
	if(questStatus == -1) then
		npcHandler:say("Ho Ho Ho! " .. getPlayerName(cid) .. ", você quer um presente de natal? Mas primeiro você precisa provar que é um bom Darghoniano! O malvado Grynch Goblin deseja atrapalhar a festa natalina e não podemos deixar isto acontecer! <...>", cid)
		npcHandler:say("O bom velinho precisa que você dê uma lição no Grynch Goblin. Você o encontará em uma montanha ao sul perto daqui. Você aceita a missão?", cid)

		parameters.talkState = TALK_MISSION.YES
		node:addChildKeyword(confirmPattern, confirmCallback, parameters)
		node:addChildKeyword(negationPattern, noCallback, parameters)

		--npcHandler:resetNpc(cid)
		
	elseif(questStatus == 0) then
		npcHandler:say("Ainda não derrotou o Grynch Goblin?? Apresse-se! O natal corre perigo!", cid)		
		npcHandler:resetNpc(cid)
		
	elseif(questStatus == 1) then
		npcHandler:say("Ho Ho Ho! Feliz natal " .. getPlayerName(cid) .. ", aqui está o seu presente por ter me ajudado!", cid)
		setPlayerStorageValue(cid, sid.SANTA_CLAUS_MISSION, 2)

		local backpack = doCreateItemEx(11263, 1)

		local inside = {
			{ 6512, 1 }
			,{ 6502, 1}
			,{ 2688, 10}
		}

		local addon_common = { 1, 5, 10, 14, 16, 17, 18, 20 }
		local addon_rare = { 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 15, 19, 21, 22, 23 }
		local known_addons = {}
		local is_rare = false
		local found = false
		local outfit_id = 0

		if getPlayerLevel(cid) >= 80 then
			if math.random(1, 100) >= 95 then
				outfit_id = addon_rare[math.random(1, #addon_rare)]
			else
				outfit_id = addon_common[math.random(1, #addon_common)]
			end
		else
			outfit_id = 1
		end

		for k,v in pairs(inside) do
			local tmp_item = doCreateItemEx(v[1], v[2])

			local ret = doAddContainerItemEx(backpack, tmp_item)
			if(ret ~= RETURNVALUE_NOERROR) then
				error("Canot add item to backpack")
			end
		end

		-- addon ticket
		local tmp_item = doCreateItemEx(12691, 1)
		doItemSetActionId(tmp_item, outfit_id)

		local ret = doAddContainerItemEx(backpack, tmp_item)
		if(ret ~= RETURNVALUE_NOERROR) then
			error("Canot add item to backpack")
		end		

		if(doPlayerAddItemEx(cid, backpack, false) ~= RETURNVALUE_NOERROR) then
			error("Cannot add Santa Claus present to player #" .. getPlayerName(cid))
		end	

		npcHandler:resetNpc(cid)
	else
		npcHandler:say("Ho Ho Ho, tenha um feliz natal, e obrigado por ajudar com o Grynch Goblin!", cid)
		npcHandler:resetNpc(cid)
	end
	
	return true
end

local node = keywordHandler:addKeyword({'mission', 'missão', 'missao', 'present'}, missionCallback, {npcHandler = npcHandler, onlyFocus = true, talkState = TALK_MISSION.NONE})

npcHandler:addModule(FocusModule:new())

