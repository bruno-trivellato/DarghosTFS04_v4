local cannotContinue = {}
local _done = false
local _hasCreature = false

local function doTeleportPlayerBack(cid, position)

	local playerLookTo = getPlayerLookDir(cid)
	local destPos = {}
	
	if(playerLookTo == NORTH) then
		destPos = {x = position.x, y = position.y + 1, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, SOUTH)
	elseif(playerLookTo == SOUTH) then
		destPos = {x = position.x, y = position.y - 1, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, NORTH)
	elseif(playerLookTo == EAST) then
		destPos = {x = position.x - 1, y = position.y, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, WEST)
	elseif(playerLookTo == WEST) then
		destPos = {x = position.x + 1, y = position.y, z = position.z, stackpos = 0}
		doSetCreatureDirection(cid, EAST)
	end
	
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
end

--Esta função atribui que o tile que o jogador não poderá passar é o tile que estiver 1 sqm na frente da direção que o NPC estiver olhando.
local function doSetCannotContinue()

	local npcName = getNpcName()
	local npcPos = getNpcPos()

	if(npcName == "Eric, o Guarda") then
		table.insert(cannotContinue, {x = npcPos.x, y = npcPos.y + 1, z = npcPos.z})
		table.insert(cannotContinue, {x = npcPos.x, y = npcPos.y, z = npcPos.z})
	elseif(npcName == "Teudon, o Guarda") then
		table.insert(cannotContinue, {x = npcPos.x, y = npcPos.y - 1, z = npcPos.z})
		table.insert(cannotContinue, {x = npcPos.x, y = npcPos.y, z = npcPos.z})
	end
end

function onCreatureMove(creature, oldPos, newPos)
	
	if(isPlayer(creature) == TRUE) then		
	
		if(getPlayerLevel(creature) < 100) then
	
			for k,v in pairs(cannotContinue) do
				if(doComparePositions(newPos, v)) then
					selfSay("O Rei determinou que somente guerreiros que já tiverem atingido o level 120 poderão passar por aqui!")
					doTeleportPlayerBack(creature, newPos)

					break			
				end
			end
		end
	end
end 

function onCreatureAppear(creature)
	
	_hasCreature = true
end 

function onCreatureDisappear(id)

	_hasCreature = false
end

function onThink()

	if(not _done) then
		doSetCannotContinue()
		_done = true
	end
	
	local npcName = getNpcName()
	
	if(npcName == "Guarda de Quendor") then
		
		if(_hasCreature) then
			
			if(math.random(1, 100000) <= 1200) then
			
				local talkRandom = math.random(1, 3)
			
				if(talkRandom == 1) then
					selfSay("Cuidado com as seguidores de Ariadne! Elas pretendem invadir Quendor! Fique atento para não ser pego de surpresa!")
				elseif(talkRandom == 2) then
					selfSay("Já viu o que aconteceu com a princesa Elione? Que horror...")
				elseif(talkRandom == 3) then
					selfSay("Ariadne é uma criatura macabra, somente guerreiros muito habilidosos poderão vence-la!")
				end
			end			
		end
	end
end 