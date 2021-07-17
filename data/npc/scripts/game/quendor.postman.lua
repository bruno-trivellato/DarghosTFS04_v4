local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()                        end

function task(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
            return false
    end

	task = Task:new()
	task:loadById(CAP_ONE.QUENDOR.TRAVELER_IOP)
	task:setPlayer(cid)
	task:setNpcName(getNpcName())
	
	if(task:getState() ~= taskStats.COMPLETED and task:checkPlayerRequirements()) then
		npcHandler:say("Oh, yes, of course! Mesth'zaros talk about you, the young Dragon's slayer. This is the reward by all the work you have done on Island of Peace:",cid)
		task:doPlayerAddReward()			
		task:setCompleted()
		npcHandler:say("Well, is a valuable reward and fair by all your dedication. If you see Mesth'zaros give you hi by me. Have good luck on your adventure from here!",cid)
	else
		npcHandler:say("Always talk with citizens about tasks and missions, sometimes they can give alot of rewards!",cid)
	end

    return true
end

keywordHandler:addKeyword({'task', 'tarefa', 'mission'}, task, nil)

npcHandler:addModule(FocusModule:new())