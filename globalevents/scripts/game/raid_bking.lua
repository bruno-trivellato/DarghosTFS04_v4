function onTime(time)

	local date = os.date("*t")

	  local raidTimes = {
	    [WEEKDAY.MONDAY] = { [22] = true },
	    [WEEKDAY.FRIDAY] = { [14] = true },
	    [WEEKDAY.SATURDAY] = { [17] = true }
	  }
	
	if(not raidTimes[date.wday] or not raidTimes[date.wday][date.hour]) then
		return true
	end
	
	doExecuteRaid("behemoth_king")
	return true
end