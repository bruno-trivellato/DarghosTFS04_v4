function onStepIn(cid, item, position, fromPosition)
  
    if(item.actionid == aid.RAIDS_ENTRANCE) then
      local function pushBack(cid, position, fromPosition, displayMessage)
	displayMessage = displayMessage or false
	doTeleportThing(cid, fromPosition, false)
	doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)
	if(displayMessage) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The tile seems to be protected against unwanted intruders.")
	end
      end
      
      doPlayerSendCancel(cid, "No boss or events are running.")
      pushBack(cid, position, fromPosition, false)
      return true	      
    end
        
    return portalSystem.onStepInfoField(cid, item, position, fromPosition)
end
