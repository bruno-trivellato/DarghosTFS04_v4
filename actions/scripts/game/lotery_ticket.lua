function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	local rand = math.random(1,100)
	
	if(rand < 5) then
		doPlayerAddItem(cid,5958,1)
		doSendMagicEffect(fromPosition, 30)	
		doCreatureSay(cid, "You are with luck! You ticket is a winner!", TALKTYPE_ORANGE_1)
	else
		doCreatureSay(cid, "Damn... No luck this time! Keep trying!", TALKTYPE_ORANGE_1)	
		doSendMagicEffect(fromPosition, 2)		
	end
	
	doRemoveItem(item.uid)
	return TRUE
end
