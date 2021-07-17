function onStepIn(cid, item, position, fromPosition)
	if getCreatureStorage(cid, sid.KASHMIR_QUEST_PROGRESS) == 0 then
		doCreatureSay(cid, "Parece que ao derrotar Azerus você impediu que o seu exército invadisse o Darghos! É melhor sair desse lugar medonho para sempre.", TALKTYPE_MONSTER_YELL, false, cid)
		doCreatureSetStorage(cid, sid.KASHMIR_QUEST_PROGRESS, 1)
	elseif getCreatureStorage(cid, sid.KASHMIR_QUEST_PROGRESS) == -1 then
		doPlayerSendTextMessage(cid, 22, "Você não tem acesso à Kashmir Quest, como você veio parar aqui? ...")
	end
	return TRUE
end

