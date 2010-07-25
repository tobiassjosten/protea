-- === === === === === === === === === === === === === === === === === === ====
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local pairs = pairs
local table =
{
	insert = table.insert,
	sort = table.sort,
}
local type = type

package.loaded[...] = {}
module(...)

listeners = {}



-- === === === === === === === === === === === === === === === === === === ====
-- EVENT METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Initialize module.
function Initialize(self)
	self.listeners = {}

	return self
end

--- Raise an event.
-- 
function Raise(self, name, parameters)
	if not self.listeners[name] then
		return
	end

	local parameters = parameters or {}

	local passed_filter
	for _, listener in ipairs(self.listeners[name]) do
		passed_filter = true
		for key, value in pairs(listener.filter) do
			if parameters[key] == nil or parameters[key] ~= value then
				passed_filter = false
			end
		end

		if passed_filter then
			listener.callback(parameters)
		end
	end
end -- Raise()

--- Register an event listener.
-- 
function Listen(self, name, callback, sequence, filter)
	if not self.listeners[name] then
		self.listeners[name] = {}
	end

	local sequence = sequence or 0
	local filter = filter or {}

	-- If sequence is skipped then a potential filter must be moved
	if type(sequence) == 'table' then
		filter = sequence
		sequence = 0
	end

	local listener =
	{
		event = name,
		callback = callback,
		sequence = sequence,
		filter = filter,
	}
	table.insert(self.listeners[name], listener)

	if #self.listeners[name] > 1 then
		table.sort(self.listeners[name], function(a, b) return a.sequence < b.sequence end)
	end
end -- Listen()
