function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)

	if item.uid == uid.KASHMIR_TP_IN then
		if getStorage(gid.KASHMIR_QUEST_RUNNING) == -1 then
			doTeleportThing(cid, KASHMIR_TP_IN_DESTINATION, TRUE)
			doSendMagicEffect(KASHMIR_TP_IN_DESTINATION,CONST_ME_TELEPORT)
		else
			doTeleportThing(cid, lastPosition, true)
		end
	elseif item.uid == uid.KASHMIR_TP_OUT then
		if getStorage(gid.KASHMIR_QUEST_RUNNING) == -1 then
			doTeleportThing(cid, KASHMIR_TP_OUT_DESTINATION, TRUE)
			doSendMagicEffect(KASHMIR_TP_OUT_DESTINATION,CONST_ME_TELEPORT)
		else
			doTeleportThing(cid, lastPosition, true)
		end
	end
	
    return TRUE
    
end  