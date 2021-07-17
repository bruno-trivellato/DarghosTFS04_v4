bgEvents = {
	messages = nil,
	bonus = nil
}

local minutesLeftMessage = BG_CONFIG_DURATION / 60
local secondsLeftMessage = 1
local secondsLeftMessages = {
	{ interval = 10, text = "Restam 30 segundos para o fim da partida."},
	{ interval = 10, text = "Restam 20 segundos para o fim da partida."},
	{ interval = 5, text = "Restam 10 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 5 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 4 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 3 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 2 segundos para o fim da partida."},
	{ text = "Restam 1 segundo para o fim da partida."},
}

function onBattlegroundStart(notJoinPlayers)
	
	doSetStorage(gid.BG_LAST_INIT, os.time())
	pvpBattleground.sendPvpChannelMessage("[Battleground] A partida foi iniciada! Será vencedor o primeiro time que capturar a bandeira dos adversários 3 vezes ou o que mais bandeiras capturadas ao fim da partida em " .. BG_CONFIG_DURATION / 60 .. " minutos!", PVPCHANNEL_MSGMODE_OUTBATTLE, TALKTYPE_TYPES["channel-orange"])
	
	if(notJoinPlayers > 0) then
		pvpBattleground.sendPvpChannelMessage(notJoinPlayers .. " jogadores não compareceram ao inicio da partida e poderam ser substituidos! Se você deseja IMEDIATAMENTE substituir esses jogadores digite '!bg entrar'!", PVPCHANNEL_MSGMODE_OUTBATTLE, TALKTYPE_TYPES["channel-orange"])
	end
	
	addEvent(messageTimeLeft, 100)
	
	if(bgEvents.bonus ~= nil) then
		stopEvent(bgEvents.bonus)
	end
	
	pvpBattleground.removeWall(BATTLEGROUND_TEAM_ONE)
	pvpBattleground.removeWall(BATTLEGROUND_TEAM_TWO)
	
	return true
end

function messageTimeLeft()

	if(minutesLeftMessage >= 1)  then
	
		local minutesStr = "minutos"
		if(minutesLeftMessage == 1)then
			minutesStr = "minuto"
		end
	
		pvpBattleground.sendPvpChannelMessage("Restam " .. minutesLeftMessage .. " " .. minutesStr .. " para o fim da partida.", PVPCHANNEL_MSGMODE_INBATTLE, TALKTYPE_TYPES["channel-orange"])	
		minutesLeftMessage = minutesLeftMessage - 1
		
		if(minutesLeftMessage > 0) then
			bgEvents.messages = addEvent(messageTimeLeft, 1000 * 60)
		else
			bgEvents.messages = addEvent(messageTimeLeft, 1000 * 30)
		end
	else
		local reset = false
		if(secondsLeftMessage == #secondsLeftMessages) then
			reset = true
		end	
	
		pvpBattleground.sendPvpChannelMessage(secondsLeftMessages[secondsLeftMessage].text, PVPCHANNEL_MSGMODE_INBATTLE, TALKTYPE_TYPES["channel-orange"])
		
		if(not reset) then
			bgEvents.messages = addEvent(messageTimeLeft, 1000 * secondsLeftMessages[secondsLeftMessage].interval)
			secondsLeftMessage = secondsLeftMessage + 1	
		else
			minutesLeftMessage = BG_CONFIG_DURATION / 60
			secondsLeftMessage = 1
			bgEvents.messages = nil
		end		
	end
end

function onBattlegroundEnd()
	
	if(bgEvents.messages ~= nil) then
		stopEvent(bgEvents.messages)
		timeLeftMessage = 0
		bgEvents.messages = nil
	end
	
	local points = getBattlegroundTeamsPoints()

	local teams = { "Time A", "Time B" }
	local msg = nil;
        local winByLastScore = false
        
        if(points[BATTLEGROUND_TEAM_ONE] == points[BATTLEGROUND_TEAM_TWO] and points[BATTLEGROUND_TEAM_ONE] ~= 0) then
            winByLastScore = true
        end
	
	if(points[BATTLEGROUND_TEAM_ONE] ~= points[BATTLEGROUND_TEAM_TWO] or winByLastScore) then
                if(not winByLastScore) then
                    local winnerTeam = BATTLEGROUND_TEAM_NONE
                    winnerTeam = (points[BATTLEGROUND_TEAM_ONE] > points[BATTLEGROUND_TEAM_TWO]) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
                    msg = "" .. teams[winnerTeam] .. " é o VENCEDOR por ";
                    
                    if(points[winnerTeam] == BG_CONFIG_WINPOINTS) then
                            msg = msg .. "3 bandeiras capturadas necessárias para vitoria!"
                    else
                            msg = msg .. "mais bandeiras capturadas ao fim da partida!"
                    end
                else
                    msg = "EMPATE! O Vencedor foi definido pelo time que capturou a ultima bandeira!"
                end
	else
		msg = "Não houve vencedor! EMPATE por igualdade de bandeiras capturadas ao fim da partida!"
	end	
	
	pvpBattleground.sendPvpChannelMessage("Partida encerrada. " .. msg, PVPCHANNEL_MSGMODE_BROADCAST, TALKTYPE_TYPES["channel-orange"])

	minutesLeftMessage = BG_CONFIG_DURATION / 60
	secondsLeftMessage = 1
	bgEvents.messages = nil	
	
	if(pvpBattleground.hasGain()) then
		pvpBattleground.setBonus(0)
		bgEvents.bonus = addEvent(checkBonus, 1000 * BG_BONUS_INTERVAL)
	end
	
	return true
end

local messages = {
	{ interval = 30, text = "A partida iniciará em 1 minuto e 30 segundos."},
	{ interval = 30, text = "A partida iniciará em 1 minuto."},
	{ interval = 10, text = "A partida iniciará em 30 segundos."},
	{ interval = 10, text = "A partida iniciará em 20 segundos."},
	{ interval = 5, text = "A partida iniciará em 10 segundos."},
	{ interval = 1, text = "A partida iniciará em 5 segundos."},
	{ interval = 1, text = "A partida iniciará em 4 segundos."},
	{ interval = 1, text = "A partida iniciará em 3 segundos."},
	{ interval = 1, text = "A partida iniciará em 2 segundos."},
	{ interval = 1, text = "A partida iniciará em 1 segundo."},
	{ text = "A partida está iniciada!"}
}

local message = 0

function onBattlegroundPrepare()

	doSetStorage(gid.BG_LAST_FLAG_KILLER_TEAM_ONE, -1)
	doSetStorage(gid.BG_LAST_FLAG_KILLER_TEAM_TWO, -1)
	doSetStorage(gid.BG_WINNING_BY_TWO_POINTS, -1)
	
	setBattlegroundTeamsPoints(BATTLEGROUND_TEAM_ONE, 0)
	setBattlegroundTeamsPoints(BATTLEGROUND_TEAM_TWO, 0)
	
	pvpBattleground.addObjects()
	addEvent(showMessage, 5000)
	return true
end

function showMessage()

	local reset = false
	if(message == #messages) then
		reset = true
	end

	if(message == 0)  then
		pvpBattleground.sendPvpChannelMessage("A partida iniciará em 2 minutos.", PVPCHANNEL_MSGMODE_BROADCAST, TALKTYPE_TYPES["channel-orange"])	
		addEvent(showMessage, 1000 * 30)
	else
		pvpBattleground.sendPvpChannelMessage(messages[message].text, PVPCHANNEL_MSGMODE_BROADCAST, TALKTYPE_TYPES["channel-orange"])
		if(not reset) then
			addEvent(showMessage, 1000 * messages[message].interval)
		end
	end
	
	if(not reset) then
		message = message + 1	
	else
		message = 0
	end
end

function checkBonus(onlyAlert)

	onlyAlert = onlyAlert or false

	if(not pvpBattleground.hasGain()) then
		return
	end

	local bonus = pvpBattleground.getBonus()
	bonus = bonus + 1
	
	local percent = (math.min(bonus, 7) * BG_EACH_BONUS_PERCENT) + BG_EXP_BUFF
	
	local hourStr = "na ultima hora"
	if(bonus > 1) then
		hourStr = "há " .. bonus .. " horas"
	end
	
	doBroadcastMessage("Nenhuma Battleground foi iniciada " .. hourStr .. ", os participantes da proxima partida receberão " .. percent .. "% mais experience durante 2 horas! Garanta seu lugar e aproveite! -> !bg entrar",  MESSAGE_TYPES["green"])
	bgEvents.bonus = addEvent(checkBonus, 1000 * BG_BONUS_INTERVAL)
	
	if(not onlyAlert) then
		pvpBattleground.setBonus(bonus)
	end
end

function onStartup()
	pvpBattleground.onInit()
	bgEvents.bonus = addEvent(checkBonus, 1000 * BG_BONUS_INTERVAL)
end

function onTime(time)

	local date = os.date("*t")
	
	if(not isInArray(BG_GAIN_EVERYHOUR_DAYS, date.wday)) then
		if(date.hour == BG_GAIN_START_HOUR) then
			doBroadcastMessage("Este é um alerta para avisar que esta iniciado o periodo de recompensas em Battlegrounds de hoje! São mais de 12 horas de muito PvP para você aproveitar e conseguir buff de exp, pontos de honra e rating além de façanhas! Boa sorte!",  MESSAGE_TYPES["green"])
		
			if(pvpBattleground.getBonus() > 0) then
				bgEvents.bonus = addEvent(checkBonus, 1000 * 10, true)
			end
		elseif(date.hour == BG_GAIN_END_HOUR) then
			doBroadcastMessage("Este é um alerta para avisar que esta encerrado o periodo de recompensas em Battlegrounds por hoje! As Battlegrounds iram voltar a conceder recompensas a 11:00! Tenha uma boa noite!",  MESSAGE_TYPES["green"])
		end
	end
	
	return true
end