-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local command = command
local event = event
local ipairs = ipairs
local pairs = pairs
local protea = protea
local string =
{
	match = string.match,
}
local table =
{
	insert = table.insert,
}
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
-- Add a state and its associated value to the queue, to be added or discarded
-- later on. This also removes the 'action reset' state if the action that have
-- been taken could be the reason this state is changing.
function Queue(self, name, value)
	local action_reset = self:Get('action reset')
	if action_reset then
		local actions
		if value then
			actions = self.states[name].disable_actions or {}
		else
			actions = self.states[name].enable_actions or {}
		end

		local match = false
		for _, action_entry in pairs(actions) do
			if action_entry == action_reset then
				match = true
			end
		end

		if match then
			self:Set('action reset', nil)
		end
	end

	self.queue[name] = value
end -- Queue

--- Remove state from the queue.
function Dequeue(self, name)
	self.queue[name] = nil
end -- Dequeue

--- Parse the queue.
-- Go through the queue and, if no illusions have been found, change the states
-- to their associated values. If the 'action reset' state holds an action now,
-- then we toggle all the states which would have been affected by that action.
function Parse(self)
	local action_reset = self:Get('action reset')
	if action_reset then
		for state_name, state_entry in pairs(self.states) do
			local actions
			if state_entry.status then
				actions = state_entry.disable_actions or {}
			else
				actions = state_entry.enable_actions or {}
			end

			for _, action_entry in pairs(actions) do
				if string.match(action_entry, action_reset) then
					if state_entry.status then
						self.queue[state_name] = false
					else
						self.queue[state_name] = true
					end
				end
			end
		end
	end

	if not protea:Illusion() then
		for name, value in pairs(self.queue) do
			self:Set(name, value)
		end
	end

	self.queue = {}
end -- Parse()



-- === === === === === === === === === === === === === === === === === === ====
-- GENERALIZED STATES
-- === === === === === === === === === === === === === === === === === === ====

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



-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
-- ACTION INTEGRATION
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

--- Build list of actions.
function Actions(self)
	local actions = {}

	for name, state in pairs(self.states) do
		local state_actions, state_hinders = {}, {}
		if (state.status and state.setting == false) or (not state.status and state.setting) then
			if state.status then
				state_actions = state.disable_actions or {}
				state_hinders = state.disable_state_hinders or {}
			elseif not state.status then
				state_actions = state.enable_actions or {}
				state_hinders = state.enable_state_hinders or {}
			end

			if type(state.status) == 'table' then
				local list_state_actions = {}
				for _, action_entry in ipairs(state_actions) do
					if string.find(action_entry, '%%') then
						for list_entry in pairs(state.status) do
							action_entry = string.gsub(action_entry, '%%', list_entry)
							table.insert(list_state_actions, action_entry)
						end
					else
						table.insert(list_state_actions, action_entry)
					end
				end
				state_actions = list_state_actions
			end

			local state_hindering = false
			for _, state_hinder in pairs(state_hinders) do
				if self:Get(state_hinder) then
					local state_hinder_resolving = false
					for _, state_hinder_action in pairs(self.states[state_hinder].disable_actions or {}) do
						if command:QueueGet(state_hinder_action) then
							state_hinder_resolving = true
						end
					end
					if not state_hinder_resolving then
						state_hindering = true
					end
				end
			end

			local state_commands_sent = false
			for _, state_action in ipairs(state_actions) do
				if command:Get(state_action) or command:QueueGet(state_action) then
					state_commands_sent = true
				end
			end

			if not state_hindering and not state_commands_sent then
				for _, state_action in ipairs(state_actions) do
					table.insert(actions, state_action)
				end
			end
		end
	end

	return actions
end -- Actions()
