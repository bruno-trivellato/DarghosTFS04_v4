NPC_DIALOG_INTERVAL = 1000

NpcDialog = {
	lastMessage = 0,
	delays = nil,
	messages = nil,
	default_messages = nil
}

function NpcDialog:new()
	local obj = {}
	obj.delays = {}
	obj.messages = {}
	obj.default_messages = {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function NpcDialog:say(message, creature, delay)	

	--print("Antes [" .. message .. "]")
	--print(table.show(self.messages))

	if(delay == nil) then
		delay = NPC_DIALOG_INTERVAL
	end

	if(creature ~= nil) then
		if(self.messages[creature] == nil) then
			table.insert(self.messages, creature, {msgQueue = {}, lastMessage = 0})
		end
		
		self:delay(delay, creature)
		
		local prop = {msgStr=message}
		table.insert(self.messages[creature].msgQueue, prop)	
	else
		self:delay(delay)
		
		local prop = {msgStr=message}
		table.insert(self.default_messages, prop)			
	end
	
	--print("Depois")
	--print(table.show(self.messages))
end

function NpcDialog:delay(mseconds, cid)


	if(cid ~= nil) then
		if(self.messages[cid] == nil) then
			table.insert(self.messages, cid, {msgQueue = {}, lastMessage = 0})
		end
	
		if(self.messages[cid].lastMessage == 0) then
			self.messages[cid].lastMessage = os.mtime() + mseconds
		else
			if(os.mtime() > self.messages[cid].lastMessage) then
				self.messages[cid].lastMessage = os.mtime() + mseconds
			else
				self.messages[cid].lastMessage = self.messages[cid].lastMessage + mseconds
			end
		end
	
		table.insert(self.messages[cid].msgQueue, {delay=self.messages[cid].lastMessage})	
	else	
		if(self.lastMessage == 0) then
			self.lastMessage = os.mtime() + mseconds
		else
			if(os.mtime() > self.lastMessage) then
				self.lastMessage = os.mtime() + mseconds
			else
				self.lastMessage = self.lastMessage + mseconds
			end
		end
	
		table.insert(self.default_messages, {delay=self.lastMessage})	
	end
end

function NpcDialog:run()

	--print(table.show(self.messages))

	for cid,value in pairs(self.messages) do	
	
		if(value.msgQueue ~= nil) then
			for k,msgInfo in pairs(value.msgQueue) do
				if(msgInfo.delay ~= nil) then
					if(os.mtime() <= msgInfo.delay) then
						break
					end
					
					self.messages[cid].msgQueue[k] = nil
				else
					selfSay(msgInfo.msgStr, cid)					
					self.messages[cid].msgQueue[k] = nil	
				end		
			end	
		end
	end
	
	for k,msgInfo in pairs(self.default_messages) do
		if(msgInfo.delay ~= nil) then
			if(os.mtime() <= msgInfo.delay) then
				break
			end
			
			self.default_messages[k] = nil
		else
			selfSay(msgInfo.msgStr)
			self.default_messages[k] = nil	
		end		
	end		
end