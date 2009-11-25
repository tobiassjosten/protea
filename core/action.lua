-- === === === === === === === === === === === === === === === === === === ====
-- ACTION MODULE
-- === === === === === === === === === === === === === === === === === === ====

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

module(...)

actions =
{
	['.+'] = {
		state_hinders = { 'pause' },
	},
}



-- === === === === === === === === === === === === === === === === === === ====
-- ACTION METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Aggregate an action.
function Get(self, name)
	local action = {}

	for action_name, action_entry in pairs(self.actions) do
		if string.match(name, action_name) then
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
		return false
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
		if command:Get(command_hinder) or command:TransactionGet(command_hinder) then
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
