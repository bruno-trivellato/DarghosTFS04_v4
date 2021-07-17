local INTERVAL_TO_RESET = 15
local INTERVAL_NEXT_LEVER_TO_RESET = 30
local STONE_ID = 1304

local FIRST_LEVER = uid.POI_LEVER_1
local LAST_LEVER = uid.POI_LEVER_15

local leversEvent = nil
local lastLevers = 15
leversState_T = {

	[uid.POI_LEVER_1] = false,
	[uid.POI_LEVER_2] = false,
	[uid.POI_LEVER_3] = false,
	[uid.POI_LEVER_4] = false,
	[uid.POI_LEVER_5] = false,
	[uid.POI_LEVER_6] = false,
	[uid.POI_LEVER_7] = false,
	[uid.POI_LEVER_8] = false,
	[uid.POI_LEVER_9] = false,
	[uid.POI_LEVER_10] = false,
	[uid.POI_LEVER_11] = false,
	[uid.POI_LEVER_12] = false,
	[uid.POI_LEVER_13] = false,
	[uid.POI_LEVER_14] = false,
	[uid.POI_LEVER_15] = false
}

local function resetLevers(onlyLevers)

	onlyLevers = onlyLevers or false
	
	for k,v in pairs(leversState_T) do
	
		local leverPos = getThingPosition(k)
		leverPos.stackpos = 1
		
		local lever = getTileThingByPos(leverPos)
		
		if((lever ~= nil) and (lever.itemid == 1946)) then
			doTransformItem(lever.uid, 1945)
		end
		
		leversState_T[k] = false
	end	
	
	lastLevers = 15
	
	if(not onlyLevers) then
		local pos_stone_1 = getThingPosition(uid.POI_STONE_1)
		local pos_stone_2 = getThingPosition(uid.POI_STONE_2)

		pos_stone_1.stackpos = 1
		pos_stone_2.stackpos = 1	
		
		doCreateItem(STONE_ID, 1, pos_stone_1)
		doCreateItem(STONE_ID, 1, pos_stone_2)
		doTransformItem(uid.POI_LEVER_MAIN, 1945)
	end
end

local function finishLevers()

	local pos_stone_1 = getThingPosition(uid.POI_STONE_1)
	local pos_stone_2 = getThingPosition(uid.POI_STONE_2)

	pos_stone_1.stackpos = 1
	pos_stone_2.stackpos = 1
	
	local stone_1 = getTileThingByPos(pos_stone_1)
	local stone_2 = getTileThingByPos(pos_stone_2)
	
	
	if(stone_1 ~= nil and stone_2 ~= nil) then
		doRemoveItem(stone_1.uid, 1)
		doRemoveItem(stone_2.uid, 1)
		addEvent(resetLevers, INTERVAL_TO_RESET * 60 * 1000)
	end
	
end


function onUse(cid, item, fromPosition, itemEx, toPosition)

	
	if(item.itemid == 1945) then
		local wrongSeq = false
		
		if(item.uid == uid.POI_LEVER_MAIN) then	
		
			if(lastLevers == 0) then
				finishLevers()
				doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "A passagem foi aberta por algum tempo!")
			else		
				wrongSeq = true
			end
		else	
			local done = true
	
			for x = FIRST_LEVER, (item.uid - 1), 1 do
				if(not leversState_T[x]) then
					done = false
					break
				end
			end
			
			if(done) then
				if(leversEvent) then
					stopEvent(leversEvent)
				end
				
				lastLevers = lastLevers - 1
				leversState_T[item.uid] = true
				doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Alavanca ativada com sucesso! " .. ((lastLevers == 0) and "Não resta mais nenhuma alavanca!" or "Você precisa ativar a proxima alavanca nos proximos 30 minutos ou todas alavancas serão reiniciadas. Restam mais " .. lastLevers .. " alavanca (s)!"))
				
				if(lastLevers ~= 0) then
					leversEvent = addEvent(resetLevers, INTERVAL_NEXT_LEVER_TO_RESET * 60 * 1000, true)
				end
			else
				wrongSeq = true
			end
		end
		
		if(wrongSeq) then
			doPlayerSendCancel(cid, "Esta alavanca não funcionará enquanto uma sequencia de outras alavancas não forem ativas na ordem correta.")
			return true
		end
	else
		if(item.uid == uid.POI_LEVER_MAIN) then
			doPlayerSendCancel(cid, "A passagem já está aberta! Atravesse pois ela irá se fechar em breve!")
			return true
		else
			doPlayerSendCancel(cid, "Esta alavanca ja foi ativada, procurem pela proxima alavanca! Sejam rápidos!")
			return true
		end
	end
	
	return false
end
