function onLogout(cid, forceLogout)
	
	if(isPlayerInDungeon(cid)) then
		doPlayerSendCancel(cid, "You must leave from the Dungeon to log out.")
		return false			
	end
	
	if(doPlayerIsBot(cid)) then
		std.clog("Bot " .. getPlayerName(cid) .. " is leaving...")
	end
	
	return true
end 