local callbacks = {
	
	["/lockhelp"] = function(cid)

		_helpChannel.locked	= true
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Help locked.")
		return true
	end,

	["/unlockhelp"] = function(cid)

		_helpChannel.locked	= true
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Help unlocked.")
		return true
	end
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid)
		return true
	end

	return false
end