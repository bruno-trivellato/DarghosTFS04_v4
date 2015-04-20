local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

local confirmPattern = {'yes', 'sim'}
local negationPattern = {'no', 'năo', 'nao'}

local TALK_MISSION = {
	NONE = 0,
	FIRST_START = 1,
	FIRST_FINISH = 2,
	SECOND_START = 3,
	SECOND_FINISH = 4,
	THIRD_START = 5,
	THIRD_FINISH = 6
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
		"Como back later!",
		"Dont worry about that...",
		"What more I can do for you?",
		"Shit!"
	}

	local rand = math.random(1, #messages)
	local npcHandler = parameters.npcHandler
	npcHandler:say(messages[rand], cid)
	
	if(parameters.talkState ~= nil) then
		parameters.talkState = TALK_MISSION.NONE
	end
	
	npcHandler:resetNpc(cid)
	return true
end

function yesCallback(cid, message, keywords, parameters, node)

	local talkState = parameters.talkState
	
	local ret = true
	
	--[[if(talkState == TALK_MISSION.FIRST_START) then
		ret = startFirstMissionCallback(cid, message, keywords, parameters, node)
	elseif(talkState == TALK_MISSION.FIRST_FINISH) then
		ret = finishFirstMissionCallback(cid, message, keywords, parameters, node)
	elseif(talkState == TALK_MISSION.SECOND_START) then
		ret = startSecondMissionCallback(cid, message, keywords, parameters, node)
	elseif(talkState == TALK_MISSION.SECOND_FINISH) then
		ret = finishSecondMissionCallback(cid, message, keywords, parameters, node)
	else]]if(talkState == TALK_MISSION.THIRD_START) then
		ret = startThirdMissionCallback(cid, message, keywords, parameters, node)
	elseif(talkState == TALK_MISSION.THIRD_FINISH) then
		ret = finishThirdMissionCallback(cid, message, keywords, parameters, node)
	end
	
	talkState = TALK_MISSION.NONE
	return ret
end

function startThirdMissionCallback(cid, message, keywords, parameters, node)

	if(not npcSystemHeader(cid, message, keywords, parameters, node)) then
		return false
	end

	local npcHandler = parameters.npcHandler

	local ITEMS_SPECIAL_FLASK = 7494
	
	local tmp = doCreateItemEx(ITEMS_SPECIAL_FLASK, 1)
	
	if(getPlayerFreeCap(cid) < getItemWeightById(ITEMS_SPECIAL_FLASK, 1) or doPlayerAddItemEx(cid, tmp, false) ~= RETURNVALUE_NOERROR) then
		npcHandler:say("To start the Inquisition mission I need give you an item. But you dont have free capacity enough to this.", cid)
		
		npcHandler:resetNpc()
		return true	
	end

	setPlayerStorageValue(cid, sid.INQ_KILL_UNGREEZ, 1)
	setPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_SHADOW_NEXUS, 0)
	npcHandler:say("Here is the holy water. Now you can go on the portal and be prepared to face some of the most fearful creatures in this world. On the last room (Shadow Nexus) you will find a magic pillar that sustain all the demoniac power. Use the holly water on this until the demoniac power be weakened.", cid)
	
	npcHandler:resetNpc()
	return true
end

function finishThirdMissionCallback(cid, message, keywords, parameters, node)

	if(not npcSystemHeader(cid, message, keywords, parameters, node)) then
		return false
	end

	local npcHandler = parameters.npcHandler
	local wall = (getPlayerStorageValue(cid, sid.INQ_DONE_MWALL) == 1) and true or false

	if(not wall) then
		npcHandler:say("The demoniac forces still are strong here. The Inquisition must go on!", cid)
		npcHandler:resetNpc()
		
		return true
	end	

	setPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_OUTFIT, 1)
	setPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_FIRST_ADDON, 1)
	setPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_SHADOW_NEXUS, 1)
	doPlayerAddOutfitId(cid, 20, 0)
	doPlayerAddOutfitId(cid, 20, 1)
	doPlayerAddOutfitId(cid, 20, 2)
	
	npcHandler:say("Thank you. Your help has unestimated value. To find the reward room go down on the stairs on the and chose one of the items. Also I conced to you the Inquisitor's outfit with all Addons.", cid)
	
	npcHandler:resetNpc()	
	return true
end

function missionCallback(cid, message, keywords, parameters, node)

	if(not npcSystemHeader(cid, message, keywords, parameters, node)) then
		return false
	end
	
	local npcHandler = parameters.npcHandler

	local questStatus = getPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_SHADOW_NEXUS)
	
	if(questStatus == -1) then
		npcHandler:say("After portal a very dangerous place will be found, and some the most darkness creatures in the world is living here. We need your help on the Inquisition battle. Can you help us?", cid)

		parameters.talkState = TALK_MISSION.THIRD_START
		node:addChildKeyword(confirmPattern, yesCallback, parameters)
		node:addChildKeyword(negationPattern, noCallback, parameters)
		
		return true
	elseif(questStatus == 0) then
		npcHandler:say("Good to see you " .. getCreatureName(cid) .. ". Have any progress in the Inquisition?", cid)
		
		parameters.talkState = TALK_MISSION.THIRD_FINISH
		node:addChildKeyword(confirmPattern, yesCallback, parameters)
		node:addChildKeyword(negationPattern, noCallback, parameters)	
		
		return true
	end
	
	npcHandler:say("Thank you for help us with the Inquisition against the demoniac forces! Your name will always be remembered!", cid)
	npcHandler:resetNpc()	
	
	return true
end

local node = keywordHandler:addKeyword({'mission', 'missăo', 'missao'}, missionCallback, {npcHandler = npcHandler, onlyFocus = true, talkState = TALK_MISSION.NONE})

local node1 = keywordHandler:addKeyword({'bless', 'bençăo', 'blessings'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'A bravos guerreiros que tiverem ajudado no combate as forças demoniacas eu posso conceder todas bençőes de uma vez porem custando um pouco mais caro, vocę gostaria?'})
	node1:addChildKeyword(confirmPattern, D_CustomNpcModules.inquisitionBless, {npcHandler = npcHandler, premium = true, baseCost = 40000, aditionalCostMultipler = 0.80, levelCost = 0, startLevel = 30, endLevel = 120})
	node1:addChildKeyword(negationPattern, noCallback, {npcHandler = npcHandler, onlyFocus = true})
npcHandler:addModule(FocusModule:new())