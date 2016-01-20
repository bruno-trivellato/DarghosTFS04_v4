-- empty file --
function tasks.findMonster(name, task)
	
	local monsters = task:getMonsters()

	for k,v in pairs(monsters) do
		if(v.name == name) then	
			return v
		end
	end
	
	consoleLog(T_LOG_WARNING, "creatureEvent", "tasks:findMonster", "Monster details not found.", {monster=name})
	return nil
end

function tasks.processKill(cid, list, name, isparty)
	if(tasks.hasStartedTask(cid) and list ~= nil) then
		
		local taskid = tasks.getStartedTask(cid)
		
		if(isInArray(list, taskid) == FALSE) then
			return nil
		end		
		
		local task = Task:new()		
		task:setNpcName("creatureEvent")
		
		if(not(task:loadById(taskid))) then
			-- Erro: avisar que a task salva no jogador nao foi encontrada...
			consoleLog(T_LOG_WARNING, "creatureEvent", "tasks:onKill", "The player task can not be loaded.", {player=getCreatureName(cid), taskid=taskid})
			return
		end
		
		task:setPlayer(cid)		
			
		local monster = tasks.findMonster(name, task)
		
		if(monster ~= nil) then
			
			if(tasksList[taskid].requirePoints == nil) then
				local monsterPos = taskid + monster.storagePos
				local killscount = task:getPlayerKillsCount(monsterPos) + 1
				
				if(killscount == monster.amount) then
					-- player matou a qtd necessaria de monstros
					local str = "Congratulations! You completed the mission defeating " .. monster.amount .. " " .. name .. "'s!"

					if(isparty) then
						str = str .. " Sharing task progress with party members ENABLED!"
					end

					task:sendKillMessage(str)
					--task:setFinished()
				elseif(killscount < monster.amount) then
					--print("[LOG] Mensagem")
					local str = "You must defeat more " .. (monster.amount - killscount) .. " " .. name .. "'s to complete your mission."

					if(isparty) then
						str = str .. " Sharing task progress with party members ENABLED!"
					end					

					task:sendKillMessage(str)	
				else
					return
				end
				
				task:setPlayerKillsCount(monsterPos, killscount)	
			else
				local requirePoints = tasksList[taskid].requirePoints
				local monsterPoints = monster.points
				local playerpoints = task:getPlayerKillsCount(taskid + 1)
				local newplayerpoints = playerpoints + monsterPoints
								
				if(newplayerpoints >= requirePoints) then
					local str = "Congratulations! You completed the mission reaching " .. requirePoints .. " points!"
				
					if(isparty) then
						str = str .. " Sharing task progress with party members ENABLED!"
					end				

					task:sendKillMessage(str)		
				elseif(newplayerpoints < requirePoints) then
					local str = "You got " .. monsterPoints .. " points by defeat an " .. name .. "! You still must reach " .. (requirePoints - newplayerpoints) .. " points to complete your mission."
					
					if(isparty) then
						str = str .. " Sharing task progress with party members ENABLED!"
					end

					task:sendKillMessage(str)	
				else
					if(playerpoints == requirePoints) then
						return	
					end
					
					newplayerpoints = requirePoints									
				end
				
				task:setPlayerKillsCount(taskid + 1, newplayerpoints)	
			end	
		end
	end
end

tasks.partyKillsHistory = {}

function tasks.getKillHistory(cid, name)
	if(tasks.partyKillsHistory[cid] == nil) then
		return nil
	end

	if(tasks.partyKillsHistory[cid][name] == nil) then
		return nil
	end

	return tasks.partyKillsHistory[cid][name]
end

function tasks.setKillHistory(cid, name)
	if(tasks.partyKillsHistory[cid] == nil) then
		table.insert(tasks.partyKillsHistory, cid, { [name] = os.time() })
		return
	end

	if(tasks.partyKillsHistory[cid][name] == nil) then
		table.insert(tasks.partyKillsHistory[cid], os.time(), name)
		return
	end

	tasks.partyKillsHistory[cid][name] = os.time()
end

function tasks.canMemberBeProccessed(cid, pid, name)

	if(cid == pid) then
		tasks.setKillHistory(cid, name)
		return true
	end

	if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(pid)) >= 40) then
		return false
	end

	local partyHistory = tasks.getKillHistory(pid, name)
	if(partyHistory == nil) then
		tasks.setKillHistory(pid, name)
		return true
	elseif(os.time() <= (partyHistory + (60 * 3))) then
		return true
	end

	return false
end

function tasks.onKill(cid, target)
	
	local name = string.lower(getCreatureName(target))
	local list = taskMonsters[name]

	local leader = getPlayerParty(cid)
	if(leader ~= nil) then
		local party = getPartyMembers(leader)
		for i, pid in ipairs(party) do
			if(tasks.canMemberBeProccessed(cid, pid, name)) then
				tasks.processKill(pid, list, name, true)
			end		
		end
	else
		tasks.processKill(cid, list, name, false)
	end
	
	--print("Criatura: " .. name)
end