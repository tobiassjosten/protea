-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
local ipairs = ipairs
local string =
{
	match = string.match,
}
local table =
{
	insert = table.insert,
	remove = table.remove,
}
local Send = Send

module(...)

queue = {}
history = {}



-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Queue a command.
-- 
function Queue(self, command)
	table.insert(self.queue, { command = command, ticks = 15 })
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
function Tick(self)
	if #self.queue <= 0 then
		return
	end

	local i = 1
	while i <= #self.queue do
		if self.queue[i].ticks <= 1 then
			table.insert(self.history, self.queue[i])
			table.remove(self.queue, i)
			event:Raise('command', { name = 'timeout', value = self.history[#self.history].input })
		else
			self.queue[i].ticks = self.queue[i].ticks - 1
			i = i + 1
		end
	end
end -- Tick()
