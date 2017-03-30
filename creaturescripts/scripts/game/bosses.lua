function onThink(cid, interval)

	if string.lower(getCreatureName(cid)) == "behemoth king" then
		bkingOnThink(cid, interval)
	elseif string.lower(getCreatureName(cid)) == "dark general" then
		darkGeneralOnThink(cid, interval)
	end

	return true
end