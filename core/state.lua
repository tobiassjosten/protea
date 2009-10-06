-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
local type = type

module(...)

states = {}



-- === === === === === === === === === === === === === === === === === === ====
-- STATE METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Set state status.
function Set(self, name, value)
	self.states[name] = self.states[name] or {}
	event:Raise('state', { name = name, value = (type(value) == 'table' and true or value) })
	self.states[name].status = value
end -- Set

--- Get state status.
function Get(self, name)
	return self.states[name] and self.states[name].status or false
end -- Get
