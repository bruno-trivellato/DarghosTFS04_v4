function onTime(time)

	local date = os.date("*t")
	
	if(date.wday ~= WEEKDAY.SATURDAY) then
		return true
	end
	
	doExecuteRaid("dark_general")
	return true
end