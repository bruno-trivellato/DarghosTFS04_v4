function onTime(time)

	local date = os.date("*t")
	
	if(date.wday ~= WEEKDAY.SUNDAY) then
		return true
	end
	
	doExecuteRaid("dark_general")
	return true
end