-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
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
