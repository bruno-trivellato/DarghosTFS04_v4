function onLeaveChannel(cid, channel, users)

	if(isPlayer(cid) and channel == CUSTOM_CHANNEL_PVP) then
		doPlayerSendCancel(cid, "Não é permitido fechar este canal.")
		addEvent(reopenChannel, 150, cid, CUSTOM_CHANNEL_PVP)
		return true
	end
	
	return true
end

function reopenChannel(cid, channel) return ((isPlayer(cid)) and doPlayerOpenChannel(cid, CUSTOM_CHANNEL_PVP) or nil) end