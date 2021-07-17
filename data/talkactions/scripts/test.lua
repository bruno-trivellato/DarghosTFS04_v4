local messagesTable = {
	mission_firstTalk = {
		"Primeira Mensagem da mission_firstTalk",
		"Segunda Mensagem da mission_firstTalk",
	},
	mission_secondTalk = {
		"Primeira msg da mission_secondTalk",
		"Segunda msg da mission_secondTalk",
		"Terceira msg da mission_secondTalk",
	},
}


function onSay(cid, words, param, channel)
	local test = {id=sid.KASHMIR_QUEST_PROGRESS, value=-1}
	if test == nil then
		setPlayerStorageValue(cid, test.id, test.value)
	end
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "KASHMIR Quest Progress: " .. getPlayerStorageValue(cid, sid.KASHMIR_QUEST_PROGRESS))
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "KASHMIR Quest Running: " .. getStorage(gid.KASHMIR_QUEST_RUNNING))

	--doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "História: " .. messagesTable.history[1])
	return true
end
