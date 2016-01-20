local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)                  npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)               npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)          npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                              npcHandler:onThink()                                    end

function task(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
            return false
    end

	task = Task:new()
	task:loadById(CAP_ONE.ISLAND_OF_PEACE.EIGHTH)
	task:setPlayer(cid)
	task:setNpcName(getNpcName())
	
	if(task:getState() ~= taskStats.COMPLETED and task:checkPlayerRequirements()) then
		if(task:removeRequiredItems()) then
			if(getPlayerVocation(cid) <= 4 and isPremium(cid)) then
				setPlayerPromotionLevel(cid, 1)
				npcHandler:say("Oh, how you know about the missing royal relic? This is a very valuable artifact! You are worthy to receive the promotion!", cid)
			else
				doPlayerAddMoney(cid, 20000)
				
				if(isPremium(cid)) then
					npcHandler:say("Oh, how you know about the missing royal relic? This is a very valuable artifact! You could receive the promotion, however you already are promoted. Then I give you 20.000 gold coins!", cid)
				else
					npcHandler:say("Oh, how you know about the missing royal relic? This is a very valuable artifact! You could receive the promotion, however you are not a premium account. Then I give you 20.000 gold coins!", cid)
				end
			end
			
			task:setCompleted()
		else
			npcHandler:say("The minotaurs stealed a valuable artifact from the palace. The guards belive that they are on the east, on the sand... We need some adventurer ready to recover the relic missed.",cid)
		end
	else
		npcHandler:say("Talk about tasks with the people on the town. Some of then should need your services.",cid)
	end

    return true
end

keywordHandler:addKeyword({'tarefa', 'task'}, task, nil)

D_CustomNpcModules.addPromotionHandler(keywordHandler, npcHandler)

--[[
local node2 = keywordHandler:addKeyword({'epic'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can epicize you for 200000 gold coins. Do you want me to epicize you?'})
        node2:addChildKeyword({'yes'}, StdModule.promotePlayer, {npcHandler = npcHandler, cost = 200000, level = 120, promotion = 2, text = 'Congratulations! You are now epicized.'})
        node2:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then, come back when you are ready.', reset = true})
]]--

npcHandler:addModule(FocusModule:new())