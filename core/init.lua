-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

local pairs   = pairs
local pcall   = pcall
local print   = print
local require = require
local type    = type
local string  = string
local table   = table

--- Set metatable for Protea.
function ProteaMetatable(module)
  setmetatable(module, {
		__index = function(i,k)
			return i.modules[k]
		end
	})
end

package.loaded[...] = {}
module(..., ProteaMetatable)

version      = '0.1-alpha'
modules      = {}
core_modules = {}

--- Load a module.
function LoadModule(self, module, realm)
	module = module:lower()

	local success, module_instance = pcall(require, 'core.' .. module)
	if not success then
		return false
	end

	self['modules'][module]      = module_instance
	self['core_modules'][module] = module_instance

	local success, module_instance = pcall(require, 'realms.' .. (realm or 'nil') .. '.' .. module:lower())
	if not success and not module_instance:match('^module \'.+\' not found:.+') then
		print('ERROR:', module_instance)
	end

	if type(module_instance) == 'table' then
		self['core_modules'][module] = self[module]
		self['modules'][module]      = module_instance
	end

	return self['modules'][module]
end

--- Load a list of module.
function LoadModules(self, modules, realm)
	for _, module in pairs(modules) do
		self:LoadModule(module, realm)
	end
end

--- Fetch a module.
function GetModule(self, module)
	if not self['modules'][module:lower()] then
		self:LoadModule(module)
	end

	return self['modules'][module:lower()]
end
