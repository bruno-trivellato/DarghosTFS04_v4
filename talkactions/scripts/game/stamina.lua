local CODE_EXPIRATION = 5 -- minutes

local codes = {}

local function generateCode(cid)

		local valid = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
		local code = ""

		for i = 1, 5 do
			local rand = math.random(1, #valid)
			code = code .. valid:sub(rand, rand)
		end

		local msg = "Este comando é usado para regenerar completamente a sua stamina ao custo de R$ 10,00 (debitados de seu saldo)."
		msg = msg .. "\nPara confirmar a sua compra, digite o seguinte comando: \"!buystamina " .. code .. "\" (sem as aspas)."

		table.insert(codes, cid, {date = os.time(), value = code})

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
end

function onSay(cid, words, param)
	
	if(param ~= "") then

		local code = codes[cid]

		if(code ~= nil and os.time() < code.date + (60 * CODE_EXPIRATION)) then

			local msg = ""	

			if(code.value == param) then
				if(doPlayerRemoveBalance(cid, 1000)) then
					db.executeQuery("INSERT INTO `wb_changelog` (`type`, `key`, `value`, `time`) VALUES ('stamina', " .. getPlayerGUID(cid) .. ", '" .. code.value .. "', " .. os.time() .. ");")
					msg = "Parabens, você está com sua stamina totalmente regenerada! Divirta-se!"
					doPlayerSetStamina(cid, 42 * 60)
					doSendAnimatedText(getPlayerPosition(cid), "Recuperado!", TEXTCOLOR_PURPLE)
				else
					msg = "Não há saldo disponível em sua conta. Por favor, adicione saldo em sua conta pelo nosso website e tente novamente."	
				end

				codes[cid] = nil
			else
				msg = "Comando digitado errado. Para confirmar, digite \"!buystamina " .. code.value .. "\" (sem as aspas)."
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
