function onThink(cid, interval)

	if string.lower(getCreatureName(cid)) == "behemoth king" then
		bkingOnThink(cid, interval)
	end

	return true
end