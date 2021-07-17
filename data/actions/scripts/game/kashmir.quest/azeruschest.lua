function onUse(cid, item, frompos, item2, topos)
	
	if getPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS) == 1 then
		if item.actionid == aid.KASHMIR_REWARD_CHEST_MASK then
			doPlayerSendTextMessage(cid, 22, "You have found an Yalahari Mask.")
			doPlayerAddItem(cid, 9778, 1)
			setPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS, 2)
		elseif item.actionid == aid.KASHMIR_REWARD_CHEST_ARMOR then
			doPlayerSendTextMessage(cid,22,"You have found an Yalahari Armor.")
			doPlayerAddItem(cid,9776,1)
			setPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS, 2)
		elseif item.actionid == aid.KASHMIR_REWARD_CHEST_LEGS then
			doPlayerSendTextMessage(cid,22,"You have found an Yalahari Leg Piece.")
			doPlayerAddItem(cid,9777,1)
			setPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS, 2)
		end
	elseif getPlayerStorageValue(cid,sid.KASHMIR_QUEST_PROGRESS) == 2 then
		doPlayerSendTextMessage(cid, 22, "Não há nada aqui.")
	else
		doPlayerSendTextMessage(cid, 22, "Você precisa fazer a quest para pegar a recompensa.")
	end

	return true
end  