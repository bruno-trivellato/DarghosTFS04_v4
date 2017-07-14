function onTime(time)

	local world_id = getConfigValue('worldId')
	if world_id == WORLD_NOVIUM then
		return true
	end

	local date = os.date("*t")

  local raidTimes = {
    [WEEKDAY.SUNDAY] = { [14] = true },
    [WEEKDAY.WEDNESDAY] = { [17] = true },
    [WEEKDAY.THURSDAY] = { [22] = true }
  }
	
	if(not raidTimes[date.wday] or not raidTimes[date.wday][date.hour]) then
		return true
	end
	
	doExecuteRaid("dark_general")
	return true
end
