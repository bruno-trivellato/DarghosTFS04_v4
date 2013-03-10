function onTime(time)

	local date = os.date("*t")
	
	if(date.wday ~= WEEKDAY.SATURDAY) then
		return true
	end
	
	doSetStorage(gid.EVENT_DARK_GENERAL, EVENT_STATE_INIT)
	doExecuteRaid("dark_general")
	return true
end