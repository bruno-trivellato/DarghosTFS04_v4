local dialog = NpcDialog:new()
local npcSys = _NpcSystem:new()
npcSys:setDialog(dialog)

local npcTask = NpcTasks:new(npcSys)
npcTask:registerTask(CAP_ONE.ISLAND_OF_PEACE.FIRST)
npcTask:registerTask(CAP_ONE.ISLAND_OF_PEACE.SECOND)
--npcTask:setNpcSystem(npcSys)
npcTask:setDialog(dialog)

function onCreatureAppear(cid)
	firstLoginEvent(cid)
end

function firstLoginEvent(cid)

	if(isPlayer(cid) == FALSE) then
		return
	end

	local distance = getDistanceTo(cid)
	if(distance == -1) then
		return
	end
	
	if(getPlayerStorageValue(cid, sid.FIRSTLOGIN_ITEMS) == 1) then
		return
	end	
	
	if(getPlayerStorageValue(cid, CAP_ONE.ISLAND_OF_PEACE.FIRST) == taskStats.NONE) then
	
		npcSys:addFocus(cid)	
		
		if(distance ~= -1 and distance > 1) then
			moveToCreature(cid)
			dialog:delay(1)
		end
		
		dialog:say("Be welcome " .. getCreatureName(cid) .. "! I am " .. getNpcName() .. " and my job is assist begginers on the game like you! [...]", cid)
		dialog:say("I will start giving you some basic equipments to you began your journey! [...]", cid, 6)
		addEvent(defineFirstItems, 1000 * 8, cid)
		dialog:say("We are having some challanges with the Trolls. They alive on the underground and their poppulation are comming to be out of control [...]", cid, 6)
		dialog:say("We need decimate some of the trolls to keep everthing right. You should want this {task}!", cid, 6)
	end	
end

function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)
	npcTask:setPlayer(cid)
	local distance = getDistanceTo(cid) or -1
	if((distance < npcSys:getTalkRadius()) and (distance ~= -1)) then
		if((msg == "hi" or msg == "hello" or msg == "ola") and not (npcSys:isFocused(cid))) then
		
			local task = Task:new()
			task:setNpcName(getNpcName())
			task:loadById(CAP_ONE.ISLAND_OF_PEACE.FOURTH)
			task:setPlayer(cid)		
		
			if(task:getState() == taskStats.COMPLETED) then
				dialog:say("Look that! Is ".. getCreatureName(cid) .." here! You now is stronger then last time I've seen you! You have done some tasks, I'm right?", cid)
				npcSys:setTopic(cid, 5)
			else
				dialog:say("Hello ".. getCreatureName(cid) ..". You want start a {task} for me?", cid)
			end
			
			npcSys:addFocus(cid)					
		elseif(npcSys:isFocused(cid) and (msg == "tarefa" or msg == "missão" or msg == "missao" or msg == "mission" or msg == "task")) then
			npcTask:responseTask(cid)
		elseif(npcSys:isFocused(cid) and (msg == "não" or msg == "nao" or msg == "no")) then
			dialog:say("Allright. Can I help you with anything?", cid)
			npcSys:setTopic(cid, 0)			
		elseif(npcSys:isFocused(cid) and (msg == "sim" or msg == "yes")) then
		
			if(npcSys:getTopic(cid) == 2) then
				npcTask:sendTaskObjectives()
				npcSys:setTopic(cid, 3)
			elseif(npcSys:getTopic(cid) == 3) then
				npcTask:sendTaskStart()
				npcSys:setTopic(cid, 0)
			elseif(npcSys:getTopic(cid) == 4) then
				npcTask:onCompleteConfirm()
			elseif(npcSys:getTopic(cid) == 5) then
				dialog:say("It's good! You come here waiting for some tasks right? Sadly I dont have any tasks for you anymore but follow to east from here and you will reach the exit of the city and find the Winston, the guard [...]", cid)
				dialog:say("Last time I've talk with Winston he say me about some problems that he is facing! Talk with him. Good luck! ", cid, 6)
			end
		elseif((npcSys:isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya" or msg == "adeus")) then
			dialog:say("Goodbye!", cid)
			npcSys:removeFocus(cid)	
		end
	end
end

function onCreatureDisappear(cid) npcSys:onCreatureDisappear(cid) end
function onPlayerCloseChannel(cid) npcSys:onPlayerCloseChannel(cid) end
function onThink() npcSys:onThink() end
