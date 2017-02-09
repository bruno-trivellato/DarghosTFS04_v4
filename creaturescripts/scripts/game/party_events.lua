function onPartyPassLeadership(cid, target)

	Dungeons.onPartyPassLeadership(cid, target)
end

function onPartyLeave(cid)

	local ret = Dungeons.onPartyLeave(cid)
	if not ret then
		return false
	end
	
	return true
end