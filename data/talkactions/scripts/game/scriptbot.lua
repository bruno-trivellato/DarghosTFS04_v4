local looping = false
local recording = false

local callbacks = {
	
	["/scriptbot"] = function(cid, param)

		if param == "stop" then
			if recording then
				if looping then
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot looping stoped.")
					botScriptEndLoop()
					looping = false
				end

				botScriptFinished()
				setPlayerStorageValue(cid, sid.SCRIPTBOT_RECORDING, -1)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot recording stoped.")
				recording = false
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot not recording.")
			end
		elseif param == "loop" then
			if recording then
				if not looping then
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot looping started.")
					botScriptStartLoop()
					looping = true
				else
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot looping stoped.")
					botScriptEndLoop()
					looping = false				
				end
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot not recording.")
			end
		else
			local name = getPlayerName(cid)
			if param ~= "" then
				name = param
			end

			if not recording then
				botScriptRegisterNew(name)
				botScriptStartPosition(getPlayerPosition(cid))
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot recording.")
				setPlayerStorageValue(cid, sid.SCRIPTBOT_RECORDING, 1)
				recording = true
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Scriptbot already recording, please stop before start a new.")
			end
		end

		return true
	end
}

function onSay(cid, words, param)	

	if(callbacks[words] ~= nil) then
		callbacks[words](cid, param)
		return true
	end

	return false
end