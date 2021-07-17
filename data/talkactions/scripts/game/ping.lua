function onSay(cid, words, param)
	
	local ping = getPlayerCurrentPing(cid)
	
	local str = "";
	
	str = str .. "Seu ping (latência) atual é de " .. ping .. " ms (quanto menor, melhor).\n\n"
	
	local qual_str = ""
	
	if(ping > 275) then
		str = str .. "Avaliação: Seu ping é considerado muito alto, e isto não é bom. Você pode ter problemas de lag, que podem atrapalhar seu jogo. Recomendações:\n"
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
		str = "\n"	
		
		if(not isInTunnel(cid)) then
			str = str .. "Use o Darghos Tunnel (atualmente, você não usa). Usando ele seu ping pode ser consideravelmente diminuido resolvendo o problema.\nMaiores informações sobre o nosso tunnel em: http://darghos.com.br/?ref=tunnel.about\n"
			str = str .. "Siga os passos e depois de se conectar pelo tunnel use o comando !ping novamente para ter uma nova avaliação!"
		else
			str = str .. "*Evite conexões sem fio (rede wi-fi, 3G, etc)\n"
			str = str .. "*Feche todos outros programas que podem estar consumindo toda sua internet (downloads, torrents, jogos, etc)\n"
			str = str .. "*Evite conexões compartilhadas em rede (outro computador em sua rede pode estar esgotando sua internet e estar causando o problema)\n"
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
			str = "\n"			
			str = str .. "*Faça uma limpeza no seu computador com seu anti-virus ou anti-spyware.\n"		
			str = str .. "*Entre em contato com sua provedora de internet, informe o problema de ping alto e solicite uma visita tecnica.\n"		
			str = str .. "*Faça uma nova e limpa instalação de seu sistema (ultimo caso, recomenda-se usar uma assistência tecnica para isto)."		
		end
	else
		if(not isInTunnel(cid)) then
			str = str .. "Avaliação: Seu ping é considerado bom mas foi identificado que você não usa o Darghos Tunnel. Usando ele sua conexão pode ficar ainda melhor, experimente!\nMaiores informações sobre o nosso tunnel em: http://darghos.com"
		else
			str = str .. "Avaliação: Você possui uma conexão boa com o Darghos e não deverá ter problemas com lags! Parabens!"
		end
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)

	return TRUE
end