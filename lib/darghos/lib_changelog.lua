CLOG_CHANGE_CHARACTER_NAME = 1
CLOG_CHANGE_CHARACTER_SEX = 2
CLOG_RECHARGE_CHARACTER_STAMINA = 3
CLOG_ACCOUNT_RENAME = 4
CLOG_SWITCH_PVP = 5
CLOG_CLEAN_CHANGE_PVP_DEBUFF = 6

changeLog = {}

function changeLog.create(type, key, value)

	if(value ~= nil and type(value) == "table") then
		local json = require("json")	
		value = json.encode(value)
	else
		value = value or ""
	end
	
	db.executeQuery("INSERT `wb_changelog` (`type`, `key`, `value`, `time`) VALUES (" .. type .. ", " .. key .. ", '" .. value .. "', " .. os.time() .. ");")
end

function changeLog.onBuySpecialPermission(cid)

	changeLog.create(CLOG_SWITCH_PVP, getPlayerGUID(cid), nil)
end

function changeLog.onCleanExpDebuff(cid)
	changeLog.create(CLOG_CLEAN_CHANGE_PVP_DEBUFF, getPlayerGUID(cid), nil)
end