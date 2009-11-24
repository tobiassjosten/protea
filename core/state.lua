-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local event = event
local pairs = pairs
local protea = protea
local type = type

module(...)

states = {}
timed = {}
temporary = {}
queue = {}



-- === === === === === === === === === === === === === === === === === === ====
-- STATE METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Set state status.
function Set(self, name, value, attribute)
	attribute = attribute or 'status'
	if not self.states[name] then
		self.states[name] = { status = false }
	end

	event:Raise('state', { name = name, attribute = attribute, value = value })

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

--- Set temporary state.
function SetTemporary(self, name, value)
	self:Set(name, value)
	self.temporary[name] = true
end -- SetTemporary()

--- Get state status.
function Get(self, name, attribute)
	attribute = attribute or 'status'
	return self.states[name] and self.states[name][attribute] or false
end -- Get()

--- Invoke a tick for timed states.
function Tick(self, count)
	for name in pairs(self.timed) do
		self.states[name].ticks = (self.states[name].ticks or 0) - count
		if self.states[name].ticks <= 0 then
			self.states[name] = nil
			self.timed[name] = nil
		end
	end
end -- Tick()

--- Flush temporary states.
function Flush(self)
	for name in pairs(self.temporary) do
		self.states[name] = nil
	end
	self.temporary = {}
end -- Flush()



-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
-- STATE QUEUE
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

--- Queue state.
function Queue(self, name, value)
	self.queue[name] = value
end -- Queue

--- Remove state from the queue.
function Dequeue(self, name)
	self.queue[name] = nil
end -- Dequeue

--- Parse the queue.
function Parse(self)
	if not protea:Illusion() then
		for name, value in pairs(self.queue) do
			self:Set(name, value)
		end
	end

	self.queue = {}
end -- Parse()
