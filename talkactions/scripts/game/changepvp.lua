local CODE_EXPIRATION = 5 -- minutes

local codes = {}

local function generateCode(cid)

		local valid = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
		local code = ""

		for i = 1, 5 do
			local rand = math.random(1, #valid)
			code = code .. valid:sub(rand, rand)
		end

		local msg = "Este comando é usado para ativar ou desativar o seu PvP ao custo de R$ 20,00 (debitados de seu saldo)."
		msg = msg .. "\nPara confirmar a sua compra, digite o seguinte comando: \"!changepvp " .. code .. "\" (sem as aspas)."

		table.insert(codes, cid, {date = os.time(), value = code})

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
end

function onSay(cid, words, param)
	
	if(param ~= "") then

		local code = codes[cid]

		if(code ~= nil and os.time() < code.date + (60 * CODE_EXPIRATION)) then

			local msg = ""	

			if(code.value == param) then
				if(doPlayerRemoveBalance(cid, 2000)) then
					db.executeQuery("INSERT INTO `wb_changelog` (`type`, `key`, `value`, `time`) VALUES ('change-pvp', " .. getPlayerGUID(cid) .. ", '" .. code.value .. "', " .. os.time() .. ");")
					
					if(doPlayerIsPvpEnable(cid)) then
						doPlayerDisablePvp(cid)
						msg = "Parabens, você desativou seu PvP! Divirta-se!"
						doSendAnimatedText(getPlayerPosition(cid), "PvP OFF!", TEXTCOLOR_PURPLE)
					else
						doPlayerEnablePvp(cid)
						msg = "Parabens, você ativou seu PvP! Divirta-se!"
						doSendAnimatedText(getPlayerPosition(cid), "PvP ON!", TEXTCOLOR_PURPLE)
					end
					
				else
					msg = "Não há saldo disponível em sua conta. Por favor, adicione saldo em sua conta pelo nosso website e tente novamente."	
				end

				codes[cid] = nil
			else
				msg = "Comando digitado errado. Para confirmar, digite \"!changepvp " .. code.value .. "\" (sem as aspas)."
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
