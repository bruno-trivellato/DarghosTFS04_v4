function onStepIn(cid, item, position, fromPosition)

	local thrones = {
	
		[aid.POI_TRONE1] = {
			name = "Ashfalors",
			sid = sid.POI_TRONE_1
		},
		
		[aid.POI_TRONE2] = {
			name = "Pumins",
			sid = sid.POI_TRONE_2
		},
		
		[aid.POI_TRONE3] = {
			name = "Apocalypses",
			sid = sid.POI_TRONE_3
		},
		
		[aid.POI_TRONE4] = {
			name = "Tafariels",
			sid = sid.POI_TRONE_4
		},
		
		[aid.POI_TRONE5] = {
			name = "Infernatils",
			sid = sid.POI_TRONE_5
		},
		
		[aid.POI_TRONE6] = {
			name = "Verminors",
			sid = sid.POI_TRONE_6
		}
		
	}
	
	if((thrones[item.actionid] ~= nil)) then
		if(getPlayerStorageValue(cid, thrones[item.actionid].sid) ~= 1) then
			setPlayerStorageValue(cid, thrones[item.actionid].sid, 1)
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have touched " .. thrones[item.actionid].name .. " throne and absorbed sobe of his spirit!")
		else
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You already have touched the " .. thrones[item.actionid].name .. " throne.")			
		end
	end
	
end


