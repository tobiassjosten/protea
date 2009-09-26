-- === === === === === === === === === === === === === === === === === === ====
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local table =
{
	insert = table.insert,
}

module(...)

listeners = {}



-- === === === === === === === === === === === === === === === === === === ====
-- EVENT METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Raise an event.
-- 
function Raise(self, name)
	if not self.listeners[name] then
		return
	end

	for _, v in ipairs(self.listeners[name]) do
		v()
	end
end -- Raise()

--- Register an event listener.
-- 
function Listen(self, name, callback)
	if not self.listeners[name] then
		self.listeners[name] = {}
	end

	table.insert(self.listeners[name], callback)
end -- Listen()
