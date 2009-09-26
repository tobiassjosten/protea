-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

protea =
{
	environment = {},
  modules_queue = {},
}

function protea:Environment(name, value)
	if value ~= nil then
		event:Raise('environment', { name = 'realm', value = value })
		self.environment[name] = value
	end

	return self.environment[name]
end

function protea:EnvironmentReset()
	self.environment = {}
end



-- === === === === === === === === === === === === === === === === === === ====
-- LOAD MODULES
-- === === === === === === === === === === === === === === === === === === ====

function protea:Load(name, realm)
	if not name and realm then
		self:Load('init', realm)
		for _, module_name in ipairs(self.modules_queue) do
			self:Load(module_name, realm)
		end
		self.modules_queue = {}

		return
	end

	local success, module_instance = pcall(require, (realm or 'core') .. '.' .. name)

	if type(module_instance) == 'table' then
		if not realm then
			_G[name] = module_instance
		else
			for key, value in pairs(module_instance) do
				if k:sub(1, 1) ~= '_' then
					_G[name][key] = value
				end
			end
		end
	end

	if not realm then
		table.insert(self.modules_queue, name)
	end
end

protea:Load('event')

-- Load realm specific modules when realm is detected
event:Listen('environment', function(parameters) protea:Load(nil, parameters['value']) end, { name = 'realm' })



return protea
