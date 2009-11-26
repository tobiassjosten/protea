-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

local adapter = adapter
local event = event
local ipairs = ipairs
local protea = protea
local string =
{
	match = string.match,
}
local table =
{
	insert = table.insert,
	remove = table.remove,
	concat = table.concat,
}
local tostring = tostring
local type = type

module(...)

sent = {}
history = {}
queue = {}



-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Send a command.
-- 
function Send(self, command)
	table.insert(self.sent, { command = command, ticks = 3 })
	adapter:Send(command)
	event:Raise('command', { name = 'send', value = command })
end -- Send()

--- Fetch a sent command.
-- 
function Get(self, pattern)
	for _, item in ipairs(self.sent) do
		if string.match(item.command, pattern) then
			return item.command
		end
	end

	return false
end -- Get()

--- Queue a command.
-- 
function Queue(self, command)
	table.insert(self.queue, command)
	event:Raise('command', { name = 'queue', value = command })
end -- Queue()

--- Fetch a queued command.
function QueueGet(self, pattern)
	for _, item in ipairs(self.queue) do
		if string.match(item, pattern) then
			return item
		end
	end

	return false
end -- QueueGet()

--- Flush command queue.
function QueueFlush(self)
	self.queue = {}
	event:Raise('command', { name = 'flush' })
end -- QueueFlush()

--- Send commands in queue.
function QueueSend(self)
	for _, command in ipairs(self.queue) do
		self:Send(command)
	end
	self:QueueFlush()
end -- QueueSend()

--- Heartbeat for commands.
-- 
function Tick(self, count)
	if #self.sent <= 0 then
		return
	end

	local i = 1
	while i <= #self.sent do
		if self.sent[i].ticks <= (0 + count) then
			table.insert(self.history, self.sent[i])
			table.remove(self.sent, i)
			event:Raise('command', { name = 'timeout', value = self.history[#self.history].command })
		else
			self.sent[i].ticks = self.sent[i].ticks - count
			i = i + 1
		end
	end
end -- Tick()

--- Mark a command as successful.
--
function Success(self, commands)
	if type(commands) == 'string' then
		commands = { commands }
	end

	for key, item in ipairs(self.sent) do
		for _, command in ipairs(commands) do
			if string.match(item.command, command) then
				self.success_sent = key
				return
			end
		end
	end

	for key, item in ipairs(self.history) do
		for _, command in ipairs(commands) do
			if string.match(item.command, command) then
				self.success_history = key
				return
			end
		end
	end

	-- No command was found, so we obviously have an illusion
	protea:Illusion('Command(s) have not been sent: ' .. tostring(table.concat(input, ', ')))
end -- Success()

--- Reset successful commands.
-- 
function Succeed(self)
	if protea:Illusion() then
		self.success_sent = nil
		self.success_history = nil
		return
	end

	if self.success_sent then
		self.history = {}
		for i = 1, self.success_sent do
			if i == self.success_sent then
				event:Raise('command', { name = 'success', value = self.sent[1].command })
			else
				event:Raise('command', { name = 'reset', value = self.sent[1].command })
			end
			table.remove(self.sent, 1)
		end
	end

	if self.success_history then
		for i = 1, self.success_history do
			table.remove(self.history, 1)
		end
	end

	self.success_sent = nil
	self.success_history = nil
end -- Reset()
