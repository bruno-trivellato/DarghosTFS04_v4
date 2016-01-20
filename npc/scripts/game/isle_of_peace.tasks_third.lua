local dialog = NpcDialog:new()
local npcSys = _NpcSystem:new()
npcSys:setDialog(dialog)

local npcTask = NpcTasks:new(npcSys)
npcTask:registerTask(CAP_ONE.ISLAND_OF_PEACE.FOURTH)
--npcTask:setNpcSystem(npcSys)
npcTask:setDialog(dialog)

function addRewardDelay(task)
	task:doPlayerAddReward()
end

function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)
	npcTask:setPlayer(cid)
	local distance = getDistanceTo(cid) or -1
	if((distance < npcSys:getTalkRadius()) and (distance ~= -1)) then
		if((msg == "hi" or msg == "hello" or msg == "ola") and not (npcSys:isFocused(cid))) then
		
			dialog:say(getCreatureName(cid) .."! Welcome to the training academy. I have some training {tasks}!", cid)
			npcSys:addFocus(cid)		
		elseif(npcSys:isFocused(cid) and (msg == "tarefa" or msg == "missão" or msg == "missao" or msg == "task" or msg == "mission")) then
		
			local task = Task:new()
			task:setNpcName(getNpcName())	
			task:loadById(CAP_ONE.ISLAND_OF_PEACE.FOURTH)
			task:setPlayer(cid)
			
			if(task:checkPlayerRequirements()) then
				if(task:getState() == taskStats.COMPLETED) then
					dialog:say("Talk with the people on the city. Maybe someone has more tasks for you!", cid);
				else
					dialog:say("Allright! Hector has sent a mail about you! I will teach you a special training then you will be ready to face harder challengers...", cid)
					addEvent(addRewardDelay, 1000 * 2, task)
					task:setCompleted()
					dialog:say("Done! Now you are ready to face the challengers out of town. Find Mereus! Him will give you the next instructions!", cid)				
				end
			else
				dialog:say("You first need complete the tasks of Mereus and Hector. Come back here after that.", cid)
			end
		elseif((npcSys:isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya" or msg == "adeus")) then
			dialog:say("Goodbye! Come here always you want!", cid)
			npcSys:removeFocus(cid)		
		end
	end
end

function onCreatureDisappear(cid) npcSys:onCreatureDisappear(cid) end
function onPlayerCloseChannel(cid) npcSys:onPlayerCloseChannel(cid) end
function onThink() npcSys:onThink() end