-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

protea =
{
	version = '0.1-alpha',
	environment = {},
	modules = {},
  modules_queue = {},
}



-- === === === === === === === === === === === === === === === === === === ====
-- LUA EXTENSIONS
-- === === === === === === === === === === === === === === === === === === ====

--- Clone a table.
-- This can be very useful since Lua passes all its variables as references and
-- sometimes you do not want to affect the original.
-- @param t The table you want a clone of.
function table.clone(t)
	if not t or type(t) ~= 'table' then
		return t
	end
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end -- table.clone()



-- === === === === === === === === === === === === === === === === === === ====
-- EXTEND PROTEA MODULE
-- === === === === === === === === === === === === === === === === === === ====

--- Illusion handler.
function protea:Illusion(message)
	if message then
		if type(message) ~= 'string' then
			message = nil
		end
		event:Raise('illusion', { message = message })
		state:SetTemporary('illusion', true)
	elseif message == false then
		state:SetTemporary('illusion', false)
	end
	return state:Get('illusion')
end

function protea:Environment(name, value)
	if value ~= nil then
		event:Raise('environment', { name = name, value = value })
		self.environment[name] = value
	end

	return self.environment[name]
end

function protea:EnvironmentReset()
	self.environment = {}
	protea:ModuleReset()
end

function protea:Actions()
	local actions = {}
	for _, action_entry in ipairs(state:Actions()) do
		if action:Validate(action_entry) then
			table.insert(actions, action_entry)
		end
	end
	return actions
end



-- === === === === === === === === === === === === === === === === === === ====
-- MODULES
-- === === === === === === === === === === === === === === === === === === ====

function protea:ModuleLoad(name, realm)
	if not name and realm then
		self:ModuleLoad('init', realm)
		for _, module_name in ipairs(self.modules_queue) do
			self:ModuleLoad(module_name, realm)
		end
		self.modules_queue = {}

		return
	end

	local success, module_instance = pcall(require, (realm and ('realms.' .. realm) or 'core') .. '.' .. name)
	if not success and not module_instance:match('^module \'.+\' not found:.+') then
		print('ERROR: ' .. tostring(module_instance))
	end

	if type(module_instance) == 'table' then
		if not realm then
			_G[name] = module_instance
		else
			self.modules[name] = table.clone(_G[name])
			for key, value in pairs(module_instance) do
				if key:sub(1, 1) ~= '_' then
					_G[name][key] = value
				end
			end
		end
	end

	if not realm then
		table.insert(self.modules_queue, name)
	end
end

function protea:ModuleReset()
	for module_name, module_instance in pairs(self.modules) do
		_G[module_name] = module_instance
	end
end

protea:ModuleLoad('event')
protea:ModuleLoad('atcp')
protea:ModuleLoad('trigger')
protea:ModuleLoad('command')
protea:ModuleLoad('state')
protea:ModuleLoad('action')
protea:ModuleLoad('geo')

-- Load realm specific modules when realm is detected
event:Listen('environment', function(parameters) protea:ModuleLoad(nil, parameters['value']) end, { name = 'realm' })



-- === === === === === === === === === === === === === === === === === === ====
-- CLOSURE
-- === === === === === === === === === === === === === === === === === === ====

protea:ModuleLoad('load')

return protea
