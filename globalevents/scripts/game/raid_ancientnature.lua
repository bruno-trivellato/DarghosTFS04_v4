function onTime(time)

	local date = os.date("*t")
	
	if(date.wday ~= WEEKDAY.TUESDAY) then
		return true
	end
	
	doExecuteRaid("ent")
	return true
end