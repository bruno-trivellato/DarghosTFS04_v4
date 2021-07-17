local ITEM_DEMON_OAK_LEFT_ARM = 8289
local ITEM_DEMON_OAK_RIGHT_ARM = 8290
local ITEM_DEMON_OAK_BIRD = 8288
local ITEM_DEMON_OAK_FACE = 8291

local demon_oak_pos = { x = 2051, y = 2128, z = 7 } 

local tries = {
	[ITEM_DEMON_OAK_LEFT_ARM] = 0,
	[ITEM_DEMON_OAK_RIGHT_ARM] = 0,
	[ITEM_DEMON_OAK_BIRD] = 0,
	[ITEM_DEMON_OAK_FACE] = 0
}

local completeTries = 0
local reseting = false

local theDemonOak = getGlobalStorageValue(gid.THE_DEMON_OAK)

local theDemonOakYell = {
	onEnter = "EU ESTIVE ESPERANDO POR VOCÊ!!",
	onKill = "COMO FOI POSSIVEL? O MESTRE IRA ESMAGAR VOCÊ!!"
}

local theDemonOakRespawns = {
	-- braço da esquerda
	[ITEM_DEMON_OAK_LEFT_ARM] = {
		{
			{ name = "braindeath", count = 3 },
			{ name = "bone beast", count = 1 },
			--yell = "LEVANTEM ESCRAVOS! LEVANTEM DA ESCURIDÃO!!!"
		},
		{
			{ name = "betrayed wraith", count = 2 },
			--yell = "PEGUEM OS OSSOS E VENHAM ATÉ MIM! VENHAM ATÉ AONDE EU POSSA VER-LOS!!!"
		},
	},
	
	-- braço da direita
	[ITEM_DEMON_OAK_RIGHT_ARM] = {
		{
			{ name = "banshee", count = 3 },
			--yell = "BANSHEES TRAGAM-ME SUAS ALMAS!!"
		},
		{
			{ name = "grim reaper", count = 1 },
			--yell = "ARGGH! O TORTUREM! ACABEM COM ELE LENTAMENTE MEU ESCRAVO!!"
		},	
	},
	
	-- passaro
	[ITEM_DEMON_OAK_BIRD] = {
		{
			{ name = "lich", count = 3 },
			--yell = "MUITA DOR VOCÊ IRA SENTIR PARA OBTER A SUA RECOMPENSA!!!"
		},
		{
			{ name = "dark torturer", count = 1 },
			{ name = "blightwalker", count = 1 },
			--yell = "POR CADA GOLPE VOCÊ PAGARÁ DECADAS DE TORTURA!!"
		},		
	},
	
	-- frente
	[ITEM_DEMON_OAK_FACE] = {
		{
			{ name = "lich", count = 1 },
			{ name = "giant spider", count = 2 },
			--yell = "ENTÃO VOCÊ GOSTA DISSO? O AMALDIÇÕEM!!"
		},
		{
			{ name = "undead dragon", count = 1 },
			{ name = "hand of cursed fate", count = 1 },
			--yell = "SINTA O PESO DA MÃO AMALDIÇOADA!!"
		},		
	}

}

function onUse(cid, item, frompos, item2, topos)

	if(item.actionid == aid.DEMON_OAK_DEAD_TREE) then
		return useOnDeadTree(cid, item, frompos, item2, topos)
	elseif(item.actionid == aid.DEMON_OAK_STONE_COFFIN) then
		return useOnStoneCoffin(cid, item, frompos, item2, topos)
	elseif(theDemonOakRespawns[item2.itemid] ~= nil) then
		return useOnDemonOak(cid, item, frompos, item2, topos)
	end
end

function useOnDemonOak(cid, item, frompos, item2, topos)

	tries[item2.itemid] = tries[item2.itemid] + 1
	
	if(tries[item2.itemid] == 5) then
		--demonOakSpeak(theDemonOakRespawns[item2.itemid][1].yell)
		local respawns = theDemonOakRespawns[item2.itemid][1]
		doCreateRespawnArea(respawns, demon_oak_pos, 5)
		
	elseif(tries[item2.itemid] == 10) then
		if(completeTries == 3) then
			--demonOakSpeak(theDemonOakYell.onKill)
			local respawns = {{ name = "demon", count = 1}}
			doCreateRespawnArea(respawns, demon_oak_pos, 5)	
			reseting = true
			addEvent(resetDemonOak, 1000 * 30)		
		else
			--demonOakSpeak(theDemonOakRespawns[item2.itemid][2].yell)
			local respawns = theDemonOakRespawns[item2.itemid][2]
			doCreateRespawnArea(respawns, demon_oak_pos, 5)	
			completeTries = completeTries + 1		
		end
	elseif(tries[item2.itemid] > 10) then
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
		return true
	else
		if(math.random(1, 100) >= 50) then
			local respawns = {{ name = "bone beast", count = 4}}
			doCreateRespawnArea(respawns, demon_oak_pos, 5)	
		end	
	end
	
	--doCreatureSay(item2.uid, "-krrrak-", TALKTYPE_ORANGE_1)
	doSendMagicEffect(getPlayerPosition(cid), CONST_ME_BIGPLANTS)
	return true
end

function demonOakSpeak(text)
	doCreatureSay(theDemonOak, text, TALKTYPE_ORANGE_1)
end

function resetDemonOak()

	if(getGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE) ~= -1) then
		addEvent(resetDemonOak, 1000 * 10)
		return
	end

	completeTries = 0
	
	tries = {
		[ITEM_DEMON_OAK_LEFT_ARM] = 0,
		[ITEM_DEMON_OAK_RIGHT_ARM] = 0,
		[ITEM_DEMON_OAK_BIRD] = 0,
		[ITEM_DEMON_OAK_FACE] = 0
	}	
	
	reseting = false
	
end

function useOnDeadTree(cid, item, frompos, item2, topos)

	local level = getPlayerLevel(cid)
	if(level < 120) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Você precisa ser level 120 ou superior para atravessar.")
		return true
	end	
	
	local questStatus = getGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE)
	if(questStatus ~= -1) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Outro jogador já está dentro. Aguarde alguns minutos.")
		return true
	end
	
	local taskStatus = getPlayerStorageValue(cid, sid.TASK_KILL_DEMONS)
	if(taskStatus ~= 1) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Antes de entrar você precisa concluir uma tarefa concedida por Oldrak em Plains of Death.")
		return true		
	end
	
	local demonOakStatus = getPlayerStorageValue(cid, sid.KILL_DEMON_OAK)
	if(demonOakStatus == 1) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Você já obteve a sua recompensa.")
		return true		
	end	
	
	if(reseting) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Você não pode entrar agora, por favor, aguarde alguns instantes e tente novamente.")
		return true		
	end
	
	topos.y = topos.y + 1
	
	lockTeleportScroll(cid)
    doTeleportThing(cid, topos, true)
    doSendMagicEffect(topos, CONST_ME_TELEPORT)
    doSendMagicEffect(frompos, CONST_ME_POFF)
    
    setGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE, cid)
    --demonOakSpeak(theDemonOakYell.onEnter)
    return true
end

function useOnStoneCoffin(cid, item, frompos, item2, topos)

	local demonOakStatus = getPlayerStorageValue(cid, sid.KILL_DEMON_OAK)
	if(demonOakStatus == 1) then
		local rewardTeleportPos = getThingPos(uid.THE_DEMON_OAK_REWARD_ROOM)
		
	    doTeleportThing(cid, rewardTeleportPos, true)
	    doSendMagicEffect(topos, CONST_ME_TELEPORT)
	    doSendMagicEffect(frompos, CONST_ME_POFF)		
	end	
	
	return true
end