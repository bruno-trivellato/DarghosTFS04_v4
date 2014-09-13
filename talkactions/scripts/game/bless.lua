local usePvPBless = false
local usePvEBless = true -- Inquisition

function onSay(cid, words, param)	
	local blesses = {
		{name="First", location="Quendor"},
		{name="Second", location="Aracura"},
		{name="Third", location="Aaragon"},
		{name="Fourth", location="Thaun"},
		{name="Fifth", location="Salazart"}
	}
	
	local totalBlesses = 0
	
	local message = "Confira se você possui todas as benções ou não:\n\n"
	
	for k,v in pairs(blesses) do
	
		if(getPlayerBless(cid, k)) then
			message = message .. v.name .. " (" .. v.location .. "): Completa\n"
			totalBlesses = totalBlesses + 1
		else
			message = message .. v.name .. " (" .. v.location .. "): n/a\n"
		end
	end
	
	message = message .. "\n\nChance de perder itens:"
	
	if(totalBlesses > 0) then
		if (totalBlesses == #blesses) then
			message = message .. "\nVocê está completamente abençoado pelos Deuses, os itens em seu inventário e mochila estão completamente seguros!"
		else
			local lossBackpack = 100
			local lossInventory = 100
		
			if(totalBlesses == 1) then
				lossBackpack = 70
				lossInventory = 7
			elseif(totalBlesses == 2) then
				lossBackpack = 45
				lossInventory = 4.5		
			elseif(totalBlesses == 3) then
				lossBackpack = 25
				lossInventory = 2.5	
			elseif(totalBlesses == 4) then
				lossBackpack = 10
				lossInventory = 1			
			end
			
			message = message .. "\nVocê está abençoado por " .. totalBlesses .. " deuses. Com isso a chance de quando você morrer perder sua mochila é de " .. lossBackpack .. "% e " .. lossInventory .. "% para outros itens em seu inventário."
		end
	else
		message = message .. "\nCuidado! Você não possui nenhuma benção! A chance de você perder itens ou sua mochila são muito altas!"
	end
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
	message = ""
	
	if(usePvPBless) then
		message = message .. "\n\nBenção do PvP (twist of fate):"
		
		if(getPlayerPVPBlessing(cid)) then	
			message = message .. "\nVocê possui benção do PvP. Assim suas benções normais estão protegidas quando você morre e 40% ou mais dos danos recebidos no ultimo minutos foram causados por outros jogadores (não montros)!"
		else
			message = message .. "\nVocê não possui a benção do PvP! Você irá perder suas benções regulares caso morra mesmo para outros jogadores! Compre-a em qualquer NPC dentro dos templos!"
		end
	end	

	if(usePvEBless) then
		message = message .. "\n\nBenção do Inquisitor:"
		
		if(getPlayerPVEBlessing(cid)) then	
			message = message .. "\nVocê prestou enorme ajuda ao Constantino no combate as forças demôniacas. Suas benções estarão sempre protegido caso você morra para monstros!"
		else
			message = message .. "\nVocê pode obter esta benção ao concluir a Quest da Inquisição. Procure o NPC Constantino em Thorn para maiores informações."
		end
	end		
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
	return true	
end