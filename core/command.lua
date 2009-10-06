-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
local ipairs = ipairs
local Send = Send
local string =
{
	match = string.match,
}
local table =
{
	insert = table.insert,
	remove = table.remove,
}
local type = type

module(...)

queue = {}
history = {}



-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Queue a command.
-- 
function Queue(self, command, count)
	table.insert(self.queue, { command = command, ticks = (count or 3) })
	Send(command)
	event:Raise('command', { name = 'sent', value = command })
end -- Queue()

--- Fetch a queued command.
-- 
function Get(self, pattern)
	for _, item in ipairs(self.queue) do
		if string.match(item.command, pattern) then
			return item.command
		end
	end

	return false
end -- Get()

--- Heartbeat for command queue.
-- 
function Tick(self, count)
	if #self.queue <= 0 then
		return
	end

	local i = 1
	while i <= #self.queue do
		if self.queue[i].ticks <= (0 + count) then
			table.insert(self.history, self.queue[i])
			table.remove(self.queue, i)
			event:Raise('command', { name = 'timeout', value = self.history[#self.history].command })
		else
			self.queue[i].ticks = self.queue[i].ticks - count
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

	for key, item in ipairs(self.queue) do
		for _, command in ipairs(commands) do
			if string.match(item.command, command) then
				self.success_queue = key
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
end -- Success()

--- Reset queue from successful commands.
-- 
function Succeed(self)
	if self.success_queue then
		self.history = {}
		for i = 1, self.success_queue do
			if i == self.success_queue then
				event:Raise('command', { name = 'success', value = self.queue[1].command })
			else
				event:Raise('command', { name = 'reset', value = self.queue[1].command })
			end
			table.remove(self.queue, 1)
		end
	end

	if self.success_history then
		for i = 1, self.success_history do
			table.remove(self.history, 1)
		end
	end

	self.success_queue = nil
	self.success_history = nil
end -- Reset()
