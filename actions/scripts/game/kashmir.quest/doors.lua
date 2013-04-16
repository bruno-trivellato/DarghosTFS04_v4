local function doorEnter(cid, item, toPosition)
	doTransformItem(item.uid, item.itemid + 1)
	doTeleportThing(cid, toPosition)
end

local function doorClose(cid, item, toPosition)
	local newPosition = toPosition
	newPosition.x = newPosition.x + 1
	doTeleportThing(cid, newPosition)
end

function onUse(cid, item, frompos, item2, toPosition)

	if item.actionid == aid.KASHMIR_DOOR_1 then
		if getPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS) >= 0 then
			if item.itemid == 1255 then
				doorEnter(cid, item, toPosition)
			elseif item.itemid == 1256 then
				doorClose(cid, item, toPosition)
			end
		else 
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The door seems to be sealed against unwanted intruders.")
		end
	elseif item.actionid == aid.KASHMIR_DOOR_2 then
		if getPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS) >= 1 then
			if item.itemid == 1255 then
				doorEnter(cid, item, toPosition)
			elseif item.itemid == 1256 then
				doorClose(cid, item, toPosition)
			end
		else 
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The door seems to be sealed against unwanted intruders.")
		end		
	end
	
	return true
end