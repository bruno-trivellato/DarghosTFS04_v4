function onLogout(cid, forceLogout)
	
	if(isPlayerInDungeon(cid)) then
		doPlayerSendCancel(cid, "You must leave from the Dungeon to log out.")
		return false			
	end

	logouts = logouts + 1
	
	return true
end 
