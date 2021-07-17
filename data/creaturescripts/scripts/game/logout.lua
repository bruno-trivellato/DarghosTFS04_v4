function onLogout(cid, forceLogout)
	
	if(isPlayerInDungeon(cid)) then
		doPlayerSendCancel(cid, "You must leave from the Dungeon to log out.")
		return false			
	end

	if(not doPlayerIsBot(cid)) then
		logouts = logouts + 1
  else
    local rand = math.random(1,100)
    if rand < 5 then
      std.clog("Adding bot " .. getPlayerName(cid) .. " to be generated a death.")
      db.executeQuery("INSERT INTO `player_botdeaths` (`player_id`) VALUES (" .. getPlayerGUID(cid) .. ");")
    end
  end
	
	if(doPlayerIsBot(cid)) then
		std.clog("Bot " .. getPlayerName(cid) .. " is leaving...")
	end
	
	return true
end 
