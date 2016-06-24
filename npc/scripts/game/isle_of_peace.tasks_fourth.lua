local dialog = NpcDialog:new()
local npcSys = _NpcSystem:new()
npcSys:setDialog(dialog)

local npcTask = NpcTasks:new(npcSys)
npcTask:registerTask(CAP_ONE.ISLAND_OF_PEACE.SIXTH)
npcTask:registerTask(CAP_ONE.ISLAND_OF_PEACE.SEVENTH)
--npcTask:setNpcSystem(npcSys)
npcTask:setDialog(dialog)

function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)
	
	--local kingTask = Task:new()
	--kingTask:loadById(CAP_ONE.ISLAND_OF_PEACE.EIGHTH)
	--kingTask:setPlayer(cid)	
	--kingTask:setNpcName(getNpcName())		
	
	npcTask:setPlayer(cid)
	local distance = getDistanceTo(cid) or -1
	if((distance < npcSys:getTalkRadius()) and (distance ~= -1)) then
		if((msg == "hi" or msg == "hello" or msg == "ola") and not (npcSys:isFocused(cid))) then
		
			dialog:say("Hello ".. getCreatureName(cid) .."! How can I help you? Be fast! I cant distract me!", cid)
			npcSys:addFocus(cid)
		elseif(npcSys:isFocused(cid) and (msg == "tarefa" or msg == "missão" or msg == "missao" or msg == "task" or msg == "mission")) then
		
			--if(kingTask:getState() ~= taskStats.COMPLETED and kingTask:checkPlayerRequirements()) then	
				--dialog:say("Eu não tenho mais nenhuma tarefa para você, mas sei de algo que talvez lhe interesse, e envolve ajudar o Rei, quer saber mais?", cid)
				--npcSys:setTopic(cid, 5)
			--else
				npcTask:responseTask(cid)
			--end	
		elseif(npcSys:isFocused(cid) and (msg == "não" or msg == "nao" or msg == "no")) then
			dialog:say("So sad. Can I help you?", cid)
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
				dialog:say( getCreatureName(cid) ..", the King will be happy! Follow to south until you find the sand and the pyramid. Your mission is [...]", cid)
				dialog:say("go to the lower floor of this pyramid. Be carefull. This mission is dagerous and you need face all kind of minotaurs [...]", cid, 6)
				dialog:say("On the last mission of the Kronus mines you receive a stealth ring as reward. Using the ring you can avoid some of the minotaurs [...]", cid, 6)
				dialog:say("But be carefull with the Minotaur Mage, they are not affected by the stealth ring. You will need defeath then. And be faster you can. The ring remains just be 15 minutes! [...]", cid, 6)
				dialog:say("When you reach the lower floor open the right reward chest and you will find the King's relic. Take her to the King on the town.", cid, 6)
				dialog:say("Have a good luck with this task!", cid, 6)
				kingTask:setStarted()
			end
		elseif((npcSys:isFocused(cid)) and (msg == "bye" or msg == "goodbye" or msg == "cya" or msg == "adeus")) then
			dialog:say("Always be carefull!", cid)
			npcSys:removeFocus(cid)		
		end
	end
end

function onCreatureDisappear(cid) npcSys:onCreatureDisappear(cid) end
function onPlayerCloseChannel(cid) npcSys:onPlayerCloseChannel(cid) end
function onThink() npcSys:onThink() end
