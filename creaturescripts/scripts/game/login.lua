function onLogin(cid)

	--print("Custom login done!")

	--Register the kill/die event
	registerCreatureEvent(cid, "CustomPlayerDeath")
	registerCreatureEvent(cid, "CustomStages")
	registerCreatureEvent(cid, "Inquisition")
	registerCreatureEvent(cid, "CustomPlayerTarget")
	registerCreatureEvent(cid, "CustomPlayerCombat")
	registerCreatureEvent(cid, "CustomBonartesTasks")
	registerCreatureEvent(cid, "onKill")
	registerCreatureEvent(cid, "lookItem")
	registerCreatureEvent(cid, "onMoveItem")
	registerCreatureEvent(cid, "PrepareDeath")
	registerCreatureEvent(cid, "onTradeAccept")
	registerCreatureEvent(cid, "onTradeRequest")

	local replaceUids = {
		[2500] = 2041
		,[2501] = 2042
		,[2502] = 2043
		,[2503] = 2045
		,[2504] = 2046
		,[2505] = 2047
		,[2506] = 2048
		,[2507] = 2049
		,[2508] = 2050
		,[2509] = 2079
	}

	for k,v in pairs(replaceUids) do
		local t = getPlayerStorageValue(cid, k)
		if t ~= -1 then
			setPlayerStorageValue(cid, v, t)
		end
	end

	-- giving pve bless to players that has completed inquisition quest
	if(getPlayerStorageValue(cid, 3617) == 1 and not getPlayerPVEBlessing(cid)) then
		doPlayerSetPVEBlessing(cid)
	end

	--if(tasks.hasStartedTask(cid)) then
		registerCreatureEvent(cid, "CustomTasks")
	--end
	
	registerCreatureEvent(cid, "Hacks")
	registerCreatureEvent(cid, "GainStamina")
	registerCreatureEvent(cid, "onPush")
	
	playerRecord()
	runPremiumSystem(cid)
	OnKillCreatureMission(cid)
	--Dungeons.onLogin(cid)
	--defineFirstItems(cid)
	--restoreAddon(cid)
	onLoginNotify(cid)
	--playerAutoEat(cid)
	--customStaminaUpdate(cid)
	
	if(getPlayerStorageValue(cid, sid.FIRSTLOGIN_ITEMS) ~= 1) then
		defineFirstItems(cid)
		
		if(getPlayerTown(cid) ~= towns.ISLAND_OF_PEACE) then		
			doPlayerEnablePvp(cid)
		else
			doPlayerDisablePvp(cid)
		end
		
		doPlayerAddBlessing(cid, 1)
		doPlayerAddBlessing(cid, 2)
		doPlayerAddBlessing(cid, 3)
		doPlayerAddBlessing(cid, 4)
		doPlayerAddBlessing(cid, 5)		
	end	
	
	--event
	setPlayerStorageValue(cid, sid.DOUBLE_EXP_EVENT, -1)
	--[[if(not playerHistory.hasAchievement(cid, PH_ACH_MISC_GOT_LEVEL_100)) then
		setPlayerStorageValue(cid, sid.DOUBLE_EXP_EVENT, 1)
	end]]

	setStagesOnLogin(cid)

	local itemShop = itemShop:new()
	itemShop:onLogin(cid)
	
	Auctions.onLogin(cid)	
	
	--doPlayerOpenChannel(cid, CUSTOM_CHANNEL_PVP)
	
	-- premium test
	if(canReceivePremiumTest(cid)) then
		addPremiumTest(cid)
	end	
	
	if(not hasValidEmail(cid)) then	
		notifyValidateEmail(cid)
	end	
	
	local notifyPoll = hasPollToNotify(cid)
	if(notifyPoll) then
		local message = "Caro " .. getCreatureName(cid) ..",\n\n"
		
		message = message .. "Uma nova e importante enquete está disponivel para votação em nosso website e\n"
		message = message .. "reparamos que você ainda não votou nesta enquete. No Darghos nos fazemos enquetes\n"
		message = message .. "periodicamente e elas são uma forma dos jogadores participarem do desenvolvimento e \n"
		message = message .. "melhorias do servidor.\n\n"
		
		message = message .. "Não deixe de participar! A sua opinião é muito importante para para o Darghos!\n"
		message = message .. "Para votar basta acessar acessar nosso website informado abaixo, e ir na categoria\n"
		message = message .. "'Comunidade' -> 'Enquetes' (requer login na conta).\n\n"
		
		message = message .. "www.darghos.com.br\n\n"
		
		message = message .. "Obrigado e tenha um bom jogo!"
		doPlayerPopupFYI(cid, message)
	end

	local arr = { access.GOD, access.GAME_MASTER, access.COMMUNITY_MANAGER }
	if(isInArray(arr, getPlayerAccess(cid))) then
		addAllOufits(cid)
	end
	
	--Give basic itens after death
	if getPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH) == 1 then	
		if getPlayerSlotItem(cid, CONST_SLOT_BACKPACK).uid == 0 then
			local item_backpack = doCreateItemEx(1988, 1) -- backpack
			
			doAddContainerItem(item_backpack, 2120, 1) -- rope
			doAddContainerItem(item_backpack, 2554, 1) -- shovel
			doAddContainerItem(item_backpack, 2666, 4) -- meat
			--doAddContainerItem(item_backpack, CUSTOM_ITEMS.TELEPORT_RUNE, 1) -- teleport rune
			
			doPlayerAddItemEx(cid, item_backpack, FALSE, CONST_SLOT_BACKPACK)
		end
		setPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH, -1)
	end
	
	-- Bless for low levels
	if getPlayerStorageValue(cid, sid.GIVE_BLESS_AFTER_DEATH) == 1 then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você morreu, mas não desanime! Você recebeu todas as blessings de graça. Este benefício continuará até que você chegue no nível 80. Tome mais cuidado! Bom jogo!")
	
		doPlayerAddBlessing(cid, 1)
		doPlayerAddBlessing(cid, 2)
		doPlayerAddBlessing(cid, 3)
		doPlayerAddBlessing(cid, 4)
		doPlayerAddBlessing(cid, 5)
		
		setPlayerStorageValue(cid, sid.GIVE_BLESS_AFTER_DEATH, -1)
	end
	
	setPlayerStorageValue(cid, sid.TRAINING_SHIELD, 0)
	--setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.HACKS_LIGHT, LIGHT_NONE)
	setPlayerStorageValue(cid, sid.HACKS_DANCE_EVENT, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.HACKS_CASTMANA, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, STORAGE_NULL)
	
	setPlayerStorageValue(cid, sid.LOGIN_LEVEL, getPlayerLevel(cid))
	setPlayerStorageValue(cid, sid.LOGIN_EXPERIENCE, getPlayerExperience(cid))
	
	-- Map Marks
	local hasMapMarks = getPlayerStorageValue(cid, sid.FIRST_LOGIN_MAPMARKS) == 1
	if not hasMapMarks then
		if(uid.MM_TICK) then
			addMapMarksByUids(cid, uid.MM_TICK, MAPMARK_TICK)
		end
		
		if(uid.MM_QUESTION) then
			addMapMarksByUids(cid, uid.MM_QUESTION, MAPMARK_QUESTION)
		end
		
		if(uid.MM_EXCLAMATION) then
			addMapMarksByUids(cid, uid.MM_EXCLAMATION, MAPMARK_EXCLAMATION)
		end
		
		if(uid.MM_STAR) then
			addMapMarksByUids(cid, uid.MM_STAR, MAPMARK_STAR)
		end
		
		if(uid.MM_CROSS) then
			addMapMarksByUids(cid, uid.MM_CROSS, MAPMARK_CROSS)
		end
		
		if(uid.MM_TEMPLE) then
			addMapMarksByUids(cid, uid.MM_TEMPLE, MAPMARK_TEMPLE)
		end
		
		if(uid.MM_KISS) then
			addMapMarksByUids(cid, uid.MM_KISS, MAPMARK_KISS)
		end
		
		if(uid.MM_SHOVEL) then
			addMapMarksByUids(cid, uid.MM_SHOVEL, MAPMARK_SHOVEL)
		end
		
		if(uid.MM_SWORD) then
			addMapMarksByUids(cid, uid.MM_SWORD, MAPMARK_SWORD)
		end
		
		if(uid.MM_FLAG) then
			addMapMarksByUids(cid, uid.MM_FLAG, MAPMARK_FLAG)
		end
		
		if(uid.MM_LOCK) then
			addMapMarksByUids(cid, uid.MM_LOCK, MAPMARK_LOCK)
		end
		
		if(uid.MM_BAG) then
			addMapMarksByUids(cid, uid.MM_BAG, MAPMARK_BAG)
		end
		--[[ debuga o client
		if(uid.MM_SKULL) then
			addMapMarksByUids(cid, uid.MM_SKULL, MAPMARK_SKULL)
		end
		]]
		if(uid.MM_DOLLAR) then
			addMapMarksByUids(cid, uid.MM_DOLLAR, MAPMARK_DOLLAR)
		end
		
		if(uid.MM_RED_NORTH) then
			addMapMarksByUids(cid, uid.MM_RED_NORTH, MAPMARK_REDNORTH)
		end
		
		if(uid.MM_RED_SOUTH) then
			addMapMarksByUids(cid, uid.MM_RED_SOULTH, MAPMARK_REDSOUTH)
		end
		
		if(uid.MM_RED_EAST) then
			addMapMarksByUids(cid, uid.MM_RED_EAST, MAPMARK_REDEAST)
		end
		
		if(uid.MM_RED_WEST) then
			addMapMarksByUids(cid, uid.MM_RED_WEST, MAPMARK_REDWEST)
		end
		
		if(uid.MM_GREEN_NORTH) then
			addMapMarksByUids(cid, uid.MM_GREEN_NORTH, MAPMARK_GREENNORTH)
		end
		
		if(uid.MM_GREEN_SOUTH) then
			addMapMarksByUids(cid, uid.MM_GREEN_SOUTH, MAPMARK_GREENSOUTH)
		end
		
		setPlayerStorageValue(cid, sid.FIRST_LOGIN_MAPMARKS, 1)
	end
	
	if(isInTunnel(cid)) then
 		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Voce está conectado através do Darghos Tunnel!")
 	end	
	
	return TRUE
end

function addMapMarksByUids(cid, uids, type)

	for k,v in pairs(uids) do
		local uid = 12000 + v.uid
		if(getThing(uid).uid ~= 0) then
			local pos = getThingPosition(12000 + v.uid)
			doPlayerAddMapMark(cid, pos, type, v.description)
		else
			std.clog("Cannot find object to the map mark uid: " .. uid)
		end
	end
end

function onLoginNotify(cid)

	--[[
	local today = os.date("*t").wday
	
	local msg = nil
	
	if(isInArray({WEEKDAY.SUNDAY, WEEKDAY.TUESDAY}, today)) then
		local eventState = getStorage(gid.EVENT_MINI_GAME_STATE)
	
		if(isInArray({EVENT_STATE_NONE, EVENT_STATE_INIT}, eventState)) then
		
			msg = (eventState == EVENT_STATE_INIT) and "Evento do dia (ABERTO!!):\n\n" or "Evento do dia:\n\n"			
			msg = msg .. "Não se esqueça que hoje é dia do evento semanal Warmaster a partir das 15:00 PM! \n\n"
			msg = msg .. "O Warmaster é um evento de PvP que acontece as terça-feiras e domingos e o vencedor é premiado com um ticket para o Warmaster Outfit. \n"
			msg = msg .. "A entrada do evento fica no deserto ao oeste de Quendor, em uma estrutura com teleports.\n"
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
			msg = ""
			msg = msg .. "Dentro do evento tudo é Hardcore PvP e se você morrer não perderá nada. O objetivo é simplesmente destruir os obstaculos e se manter vivo!\n"
			msg = msg .. "Na ultima sala existirá o boss que ao ser derrotado dropará o premio!\n"
		end
	end
	
	if(today == WEEKDAY.SATURDAY) then
	
		local eventState = getStorage(gid.EVENT_DARK_GENERAL)
		
		if(isInArray({EVENT_STATE_NONE, EVENT_STATE_INIT}, eventState)) then
			msg = (eventState == EVENT_STATE_INIT) and "Invasão do dia (INICIADA!!):\n\n" or "Invasão do dia:\n\n"	
			msg = msg .. "Informantes de Ordon anunciaram que Quendor precisará se unir para mais um desafio! Dark General e a Armada Negra marcham diretamente para a cidade! \n\n"
			msg = msg .. "O Dark General é uma invasão especial e desafiadora que ocorre todos sábados as 16:00, durante o evento todas as penalidades em mortes são desativadas. \n"
			msg = msg .. "Os jogadores deverão se preparar para enfrentar os poderosos seguidores da Armada Negra, como Dark Warrior, Dark Archer, Dark Mage, Dark Summoner,\n"
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
			msg = ""
			msg = msg .. "Dark Priestess além de seu lider, o Dark General!\n"
			msg = msg .. "A invasão é uma otima oportunidade para conseguir items raros nas criaturas derrotadas assim como expêriencia, além de muita diversão! Participe!\n"			
		end
	end
	
	if(today == darghos_weecly_change_day and getPlayerLevel(cid) >= darghos_weecly_change_max_level_any_day) then
	
		msg = "Lembrete do dia:\n\n"
		msg = msg .. "Hoje é " .. WEEKDAY_STRING[darghos_weecly_change_day] .. " e o barco que faz viagens entre Quendor (area para agressivos) e Island of Peace (area para pacificos) está disponivel caso você deseje mudar seu personagem de area! \n"
		msg = msg .. "Pense bem e lembre-se que caso seja feita a mudança você precisará permanecer na area escolhida ao menos até a proxima " .. WEEKDAY_STRING[darghos_weecly_change_day] .. "!\n"
	end
	
	if(msg ~= nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
	end
	]]
end
