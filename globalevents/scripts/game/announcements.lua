function onThink(interval)
	autoBroadcast()
	return true
end

function autoBroadcast()

	local messages = {
		{text = "Com o fim do Darghos você ja esta procurando um novo OTServ? Conheça o Prime OTServ! Um servidor com mapa global de grande qualidade! Confira! -> www.primeotserv.com", chance = 33}
	}
	
	for k,v in pairs(messages) do
		local m = math.random(0, 100)
		if(m <= v.chance) then
			doBroadcastMessage(v.text, MESSAGE_TYPES["orange"])
			break
		end
	end	
end
