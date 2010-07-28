-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs       = ipairs
local pairs        = pairs
local setmetatable = setmetatable
local string       = string
local table        = table
local type         = type

package.loaded[...] = {}
module(...)

states = {}
queue  = {}



-- === === === === === === === === === === === === === === === === === === ====
-- PROTOTYPE
-- === === === === === === === === === === === === === === === === === === ====

prototype = {}
prototype_mt =
{
	__index = function(t, k)
		return t.properties[k]
	end,

	__tostring = function(t)
		return t.name
	end,

	__concat = function(a, b)
		a = type(a) == 'table' and tostring(a) or a
		b = type(b) == 'table' and tostring(b) or b
		return a .. b
	end,
}

--- Change state properties.
-- Change properties of the state. If no property is specified then 'status'
-- will be used.
function prototype:Set(value, property)
	property = property or 'status'

	event:Raise('state', { name = self.name, property = property, value = value })

	self.properties[property] = value

	if self.timer and property == 'status' then
		self:Set(nil, 'timer'):Set(nil, 'old_status')
	end

	if self.reset and property == 'status' then
		for _, input1 in pairs(self.reset) do
			for _, state in pairs(self.state.states) do
				for _, input2 in pairs(state.reset or {}) do
					if input1 == input2 then
						state:Set(nil, 'reset')
					end
				end
			end
		end

		self:Set(nil, 'reset')
	end

	return self
end -- prototype:Set()

--- Set timed status.
function prototype:Timer(value, count)
	self:Set(self.status, 'old_status'):Set(value):Set(count, 'timer')

	return self
end -- prototype:Timer()

--- Set temporary status.
function prototype:Temporary(value)
	self:Set(self.status, 'old_status'):Set(value):Set(true, 'temporary')

	return self
end -- prototype:Temporary()

--- Queue state.
function prototype:Queue(value)
	self:Set(value, 'queue')

	if self.reset then
		for _, input1 in pairs(self.reset) do
			for _, state in pairs(self.state.states) do
				for _, input2 in pairs(state.reset or {}) do
					if input1 == input2 then
						state:Set(nil, 'reset')
					end
				end
			end
		end

		self:Set(nil, 'reset')
	end

	return self
end -- Queue

--- Remove state from the queue.
function prototype:Dequeue()
	self:Set(nil, 'queue')

	return self
end -- Dequeue

--- State factory.
function New(self, name, settings)
	local state = {}

	for key, value in pairs(prototype) do
		state[key] = value
	end

	state.properties = {}
	for key, value in pairs(settings or {}) do
		state.properties[key] = value
	end
	state.properties['name'] = name

	setmetatable(state, prototype_mt)

	self['states'][name] = state
	state.state = self

	return state
end -- New()



-- === === === === === === === === === === === === === === === === === === ====
-- STATE METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Initialize module.
function Initialize(self, protea)
	command = protea:GetModule('command')
	event   = protea:GetModule('event')

	self.states = {}
	self.queue  = {}

	return self
end

--- Get state status.
function Get(self, name)
	return self['states'][name]
end -- Get()

--- Invoke a tick for timed states.
function TickTimers(self, count)
	for _, state in pairs(self.states) do
		if state.timer then
			if state.timer > count then
				state:Set(state.timer - count, 'timer')
			else
				state:Set(nil, 'timer')
				state:Set(state.old_status):Set(nil, 'old_status')
			end
		end
	end

	return self
end -- TickTimers()

--- Flush temporary states.
function FlushTemporaries(self)
	for _, state in pairs(self.states) do
		if state.temporary then
			state:Set(nil, 'temporary')
			state:Set(state.old_status):Set(nil, 'old_status')
		end
	end

	return self
end -- FlushTemporaries()

--- Parse the queue.
-- Goes through the queue and updates states. If an illusion has been detected
-- then nothing happens.
function ParseQueue(self)
	if self:Get('illusion') then
		self.queue = {}
		return;
	end

	for _, state in pairs(self.states) do
		if state.queue ~= nil then
			state:Set(state.queue):Set(nil, 'queue')
		end
	end

	self.queue = {}

	return self
end -- ParseQueue()

--- Mark states to be reset.
-- Finds all states that would be toggled by given input and marks them for
-- resetting.
function MarkResets(self, input)
	for _, state in pairs(self.states) do
		local actions
		if state.type == 'affliction' and state.status then
			actions = state.disablers or {}
		elseif state.type == 'defense' and not state.status then
			actions = state.enablers or {}
		end

		local match = false
		for _, action in pairs(actions) do
			if action == input then
				match = true
				break
			end
		end

		if match then
			local reset = state.reset or {}
			table.insert(reset, input)

			state:Set(reset, 'reset')
		end
	end

	return self
end -- ResetAction()

--- Reset states.
-- Reset all states marked by Reset().
function ParseResets(self, input)
	for _, state in pairs(self.states) do
		if state.reset then
			if state.type == 'affliction' and state.status then
				state:Set(false)
			elseif state.type == 'defense' and not state.status then
				state:Set(true)
			end
			state:Set(nil, 'reset')
		end
	end

	return self
end -- ResetAction()

--- Build list of actions.
function Actions(self)
	local actions = {}

	for _, state in pairs(self.states) do
		local state_actions = {}
		if state.type == 'affliction' and state.status then
			state_actions = state.disablers or {}
		elseif state.type == 'defense' and not state.status then
			state_actions = state.enablers or {}
		end

		for _, action in pairs(state_actions) do
			actions[action] = actions[action] or {}
			table.insert(actions[action], state.name)
		end
	end

	return actions
end -- Actions()

--- Slow command.
function GotSlowCommand(self)
	return false
end -- GetSlowCommand()

--- Slow command handling.
function GotSlowCommandHandling(self)
	return false
end -- GetSlowCommandHandling()

--- Command fumble.
function GotCommandFumble(self)
	return false
end -- GetCommandFumble()
