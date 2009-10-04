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
}
local Send = Send

module(...)

queue = {}



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
