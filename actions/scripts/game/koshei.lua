statues = { 2, 2 }
statuesId = { 3697, 3698 }
ITEM_STAIR = 4835
ITEM_GROUND = 407
ITEM_KOSHEI_AMULET = 8266
event = nil
kosheiSummoned = false

function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	if(item.itemid == ITEM_KOSHEI_AMULET) then
		return onUseKosheiAmulet(cid, item, fromPosition, itemEx, toPosition)
	end
	
	local statue_id = (uid.KOSHEI_STATUE_2 - item.uid) + 1
	local now = statues[statue_id]
	local new = (now == 2) and 1 or 2
	statues[statue_id] = new
	
	local ret = getBooleanFromString(statues[statue_id] - 1)
	
	if(ret) then
		doTransformItem(item.uid, statuesId[new])
	else
		doTransformItem(item.uid, statuesId[new])
	end
	
	local statue1, statue2 = getBooleanFromString(statues[1] - 1), getBooleanFromString(statues[2] - 1)
	
	if(not statue1 and not statue2) then
		doTransformItem(uid.KOSHEI_STAIR, ITEM_STAIR)
		event = addEvent(restartState, 1000 * 60, true)
		
		local hasDefeatKoshei = (getPlayerStorageValue(cid, sid.KILL_KOSHEI) == 1) and true or false
		
		if(not kosheiSummoned and not hasDefeatKoshei) then
			local pos = getThingPos(uid.KOSHEI_POS)
			local koshei = doSummonCreature("Koshei the Deathless", pos)
			registerCreatureEvent(koshei, "monsterDeath")
			kosheiSummoned = true
		end
	else
		if(event ~= nil) then
			stopEvent(event)
			event = nil
		end
		restartState()
		doSendAnimatedText(getThingPos(item.uid), "tick!", COLOR_ORANGE)
	end
	
	return true
end

function restartState(restartStatues)

	restartStatues = restartStatues or false
	
	doTransformItem(uid.KOSHEI_STAIR, ITEM_GROUND)
	
	if(restartStatues) then
		statues = { 2, 2 }
		doTransformItem(uid.KOSHEI_STATUE_1, statuesId[2])
		doTransformItem(uid.KOSHEI_STATUE_2, statuesId[2])
	end
	
	event = nil
end

function onUseKosheiAmulet(cid, item, fromPosition, itemEx, toPosition)

	local kosheiDeathDate = getItemAttribute(itemEx.uid, "kosheiDeathDate")
		
	if(kosheiDeathDate ~= nil and kosheiDeathDate + 3 < os.time()) then
		setGlobalStorageValue(gid.KOSHEI_DEATH, 1)
		doSayInPosition(getThingPos(itemEx.uid), "Arrrrggghhh! Este verme descobriu minha fraqueza!! Eu ainda retornarei!!", TALKTYPE_ORANGE_1)
		doRemoveItem(itemEx.uid)
		doRemoveItem(item.uid)
		kosheiSummoned = false
		setPlayerStorageValue(cid, sid.KILL_KOSHEI, 1)
	end
	
	return true
end