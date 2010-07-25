-- === === === === === === === === === === === === === === === === === === ====
-- ACTION MODULE
-- === === === === === === === === === === === === === === === === === === ====

local command = command
local ipairs = ipairs
local next = next
local pairs = pairs
local state = state
local string =
{
	match = string.match,
}
local table =
{
	insert = table.insert,
}

package.loaded[...] = {}
module(...)

actions =
{
	-- Pause state stops all actions but 'pause'
	{
		patterns = { '.+' },
		patterns_exclude = { '^pause$' },
		state_hinders = { 'pause' },
	},
}



-- === === === === === === === === === === === === === === === === === === ====
-- ACTION METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Aggregate an action.
function Get(self, name)
	local action = {}

	for _, action_entry in pairs(self.actions) do
		local match = false

		for _, pattern in pairs(action_entry.patterns) do
			if string.match(name, pattern) then
				match = true
				break
			end
		end

		for _, pattern in pairs(action_entry.patterns_exclude or {}) do
			if string.match(name, pattern) then
				match = false
				break
			end
		end

		if match then
			for action_property, properties in pairs(action_entry) do
				action[action_property] = action[action_property] or {}
				for _, property in pairs(properties) do
					table.insert(action[action_property], property)
				end
			end
		end
	end

	return action
end -- Get()

--- Validate an action.
function Validate(self, name)
	local action = self:Get(name)

	if not next(action) then
		return true
	end

	for _, state_hinder in pairs(action.state_hinders or {}) do
		if state:Get(state_hinder) then
			return false
		end
	end

	for _, state_requirement in pairs(action.state_requirements or {}) do
		if not state:Get(state_requirement) then
			return false
		end
	end

	for _, config_requirement in pairs(action.config_requirements or {}) do
		if not config:Get(config_requirement) then
			return false
		end
	end

	for _, command_hinder in pairs(action.command_hinders or {}) do
		if command:Get(command_hinder) or command:QueueGet(command_hinder) then
			return false
		end
	end

	for _, equipment_requirement in pairs(action.equipment_requirements or {}) do
		if equipment:CountAll(equipment_requirement) <= 0 then
			return false
		end
		if equipment:Count(equipment_requirement) <= 0 and not self:Check(equipment:Extract(equipment_requirement)) then
			return false
		end
	end

	for _, validator in pairs(action.validators or {}) do
		if not validator() then
			return false
		end
	end

	return true
end -- Validate()

--- Parse actions and populate command queue.
function Parse(self, actions)
	local actions_grouped, action_candidate = {}
	for _, action in ipairs(actions) do
		actions_grouped[action] = (actions_grouped[action] or 0) + 1
	end
	for _, action in ipairs(actions) do
		if not action_candidate or actions_grouped[action_candidate] > actions_grouped[action] then
			action_candidate = action
		end
	end

	if action_candidate then
		local action = self:Get(action_candidate)

		for _, equipment_requirement in pairs(action.equipment_requirements or {}) do
			if equipment:Count(equipment_requirement) <= 0 then
				local equipment_action = equipment:Extract(equipment_requirement)
				command:Queue(equipment_action)
				if state:GotCommandFumble() then
					command:Queue(equipment_action)
				end
			end
		end

		command:Queue(action_candidate)

		if state:GotCommandFumble() then
			command:Queue(action_candidate)
		end
	end
end -- Parse()
