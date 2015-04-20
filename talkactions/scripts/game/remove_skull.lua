local CODE_EXPIRATION = 5 -- minutes

local codes = {}

local function generateCode(cid)

		local valid = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
		local code = ""

		for i = 1, 5 do
			local rand = math.random(1, #valid)
			code = code .. valid:sub(rand, rand)
		end

		local msg = "Este comando é usado para remover red e black skull que você esteja no momento ao custo de R$ 5,00 (debitados de seu saldo)."
		msg = msg .. "\nPara confirmar a sua compra, digite o seguinte comando: \"!removeskull " .. code .. "\" (sem as aspas)."

		table.insert(codes, cid, {date = os.time(), value = code})

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
end

function onSay(cid, words, param)
	
	if(param ~= "") then

		local code = codes[cid]

		if(code ~= nil and os.time() < code.date + (60 * CODE_EXPIRATION)) then

			local msg = ""	
			local skull = getCreatureSkull(cid)
			if(skull == SKULL_NONE or skull == SKULL_GREEN or skull == SKULL_WHITE or skull == SKULL_YELLOW) then	
				msg = "Somente red e black skulls podem ser removidas."	
				codes[cid] = nil
			elseif(isPlayerPzLocked(cid)) then
				msg = "Você não pode efetuar esta compra enquanto estiver com protection zone block."	
				codes[cid] = nil				
			elseif(code.value ~= param) then
				msg = "Comando digitado errado. Para confirmar, digite \"!removeskull " .. code.value .. "\" (sem as aspas)."
			else
				if(doPlayerRemoveBalance(cid, 1000)) then
					db.executeQuery("INSERT INTO `wb_changelog` (`type`, `key`, `value`, `time`) VALUES ('skull', " .. getPlayerGUID(cid) .. ", '" .. code.value .. "', " .. os.time() .. ");")
					msg = "Parabens, Todas skulls foram removidas com sucesso!"
					doPlayerSetSkullEnd(cid, 0, skull)
					doUpdateDBPlayerSkull(cid)
					doSendAnimatedText(getPlayerPosition(cid), "Skull removida!", TEXTCOLOR_PURPLE)
				else
					msg = "Não há saldo disponível em sua conta. Por favor, adicione saldo em sua conta pelo nosso website e tente novamente."	
				end

				codes[cid] = nil
			end

			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)			
		else
			generateCode(cid)
		end
	else
		generateCode(cid)
	end

	return TRUE
end
