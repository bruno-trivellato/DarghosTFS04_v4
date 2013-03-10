function onStepIn(cid, item, position, fromPosition)
	
	local eventState = getGlobalStorageValue(gid.EVENT_MINI_GAME_STATE)
	
	local msg = nil
	
	if(eventState == EVENT_STATE_END) then
		msg = "Infelizmente o evento já foi concluido hoje! Mas se lembre! O Warmaster está aberto todas as terças-feiras e domingos a partir de 15:00!"
	end
	
	if(eventState == EVENT_STATE_NONE) then
		msg = "Este evento só é aberto as terças feiras e domingos a partir das 15:00."
	end
	
	if(msg ~= nil) then
		doTeleportThing(cid, fromPosition, false)
		doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)	
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, msg)
	end
	
	return true
end
