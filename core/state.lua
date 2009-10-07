-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
local pairs = pairs
local type = type

module(...)

states = {}
timed = {}



-- === === === === === === === === === === === === === === === === === === ====
-- STATE METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Set state status.
function Set(self, name, value, attribute)
	attribute = attribute or 'status'
	if not self.states[name] then
		self.states[name] = {}
	end

	event:Raise('state', { name = name, value = (type(value) == 'table' and true or value) })

	self.states[name][attribute] = value
	self.timed[name] = nil

	return self.states[name]
end -- Set()

--- Set timed state.
function SetTimed(self, name, value, count)
	self:Set(name, value)
	self:Set(name, count, 'ticks')
	self.timed[name] = true
end -- SetTimed()

--- Get state status.
function Get(self, name)
	return self.states[name] and self.states[name].status or false
end -- Get()

--- Invoke a tick for timed states.
function Tick(self, count)
	for name in pairs(self.timed) do
		self.states[name].ticks = (self.states[name].ticks or 0) - count
		if self.states[name].ticks <= 0 then
			self.states[name] = nil
		end
	end
end -- Tick()
