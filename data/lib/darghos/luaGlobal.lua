luaGlobal = {}

function luaGlobal.getVar(name)
	local result = db.getResult("SELECT `value` FROM `lua_global` WHERE `var` = '" .. name .. "';")
	local value = nil
	
	if(result:getID() ~= -1) then
		value = result:getDataString("value")
		result:free()
	end	
	
	if(value ~= nil) then
		local json = require("json")
		value = json.decode(value)	
	end
	
	return value
end

function luaGlobal.setVar(var, value)
	
	local result = db.getResult("SELECT `value` FROM `lua_global` WHERE `var` = '" .. var .. "';")
	
	
	local json = require("json")	
	value = json.encode(value)		
	
	if(result:getID() ~= -1) then
		result:free()
		db.executeQuery("UPDATE `lua_global` SET `value` = '" .. value .. "' WHERE `var` = '" .. var .. "';")	
	else
		db.executeQuery("INSERT INTO `lua_global` VALUES ('" .. var .. "', '" .. value .. "');")
	end
	
end

function luaGlobal.unsetVar(var)
	db.executeQuery("DELETE FROM `lua_global` WHERE `var` = '" .. var .. "';")	
end

function luaGlobal.truncate()
	db.executeQuery("TRUNCATE `lua_global`;")
end