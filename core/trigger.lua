-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local string =
{
	gmatch = string.gmatch,
	gsub = string.gsub,
	match = string.match,
}
local table =
{
	concat = table.concat,
	insert = table.insert,
	sort = table.sort,
}
local type = type

module(...)

triggers = {}



-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Parse chunk and look for trigger matches.
-- 
function Parse(self, source, chunk)
	if not self.triggers[source] then
		return
	end

	if type(chunk) == 'string' then
		local lines, ansi_leftovers = {}, nil
		for line in string.gmatch(chunk .. '\10', '(.-)[\10\255]\249?') do
			if #string.gsub(line, '\27%[.-m', '') > 0 then
				table.insert(lines, (ansi_leftovers or '') .. line)
				ansi_leftovers = nil
			else
				for ansi in string.gmatch(line, '\27%[.-m') do
					ansi_leftovers = (ansi_leftovers or '') .. ansi
				end
      end
		end

		return self:Parse(source, lines)
	end

	local matched = false

	for line in ipairs(chunk) do
		for _, trigger in ipairs(self.triggers[source]) do
			if #chunk >= trigger.lines - 1 + line then
				local chunk = table.concat(chunk, '\n', line, trigger.lines - 1 + line)
				chunk = string.gsub(chunk, '\27%[.-m', '')
				local match = { string.match(chunk, trigger.pattern) }
				if #match > 0 then
					matched = true
					trigger.callback(match)
				end
			end
		end
	end

	return matched
end -- Parse()

--- Add a trigger.
-- 
function Add(self, source, pattern, callback, sequence)
	local lines = (type(pattern) == 'table' and pattern[2] or 1)
	local pattern = (type(pattern) == 'table' and pattern[1] or pattern)
	local sequence = sequence or 0

	if not self.triggers[source] then
		self.triggers[source] = {}
	end

	local trigger =
	{
		pattern = pattern,
		callback = callback,
		sequence = sequence,
		lines = lines,
	}
	table.insert(self.triggers[source], trigger)

	if #self.triggers[source] > 1 then
		table.sort(self.triggers[source], function(a, b) return a.sequence < b.sequence end)
	end
end -- Add()
