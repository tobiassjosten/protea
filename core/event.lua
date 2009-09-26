-- === === === === === === === === === === === === === === === === === === ====
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local table =
{
	insert = table.insert,
	sort = table.sort,
}

module(...)

listeners = {}



-- === === === === === === === === === === === === === === === === === === ====
-- EVENT METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Raise an event.
-- 
function Raise(self, name, parameters)
	if not self.listeners[name] then
		return
	end

	for _, listener in ipairs(self.listeners[name]) do
		listener.callback(parameters)
	end
end -- Raise()

--- Register an event listener.
-- 
function Listen(self, name, callback, sequence)
	if not self.listeners[name] then
		self.listeners[name] = {}
	end

	local listener =
	{
		event = name,
		callback = callback,
		sequence = sequence or 0,
	}
	table.insert(self.listeners[name], listener)

	if #self.listeners[name] > 1 then
		table.sort(self.listeners[name], function(a, b) return a.sequence < b.sequence end)
	end
end -- Listen()
