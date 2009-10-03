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

--- Parse paragraph and look for trigger matches.
-- 
function Parse(self, paragraph)
	if type(paragraph) == 'string' then
		local lines, ansi_leftovers = {}, nil
		for line in string.gmatch(paragraph .. '\10', '(.-)[\10\255]\249?') do
			if #string.gsub(line, '\27%[.-m', '') > 0 then
				table.insert(lines, (ansi_leftovers or '') .. line)
				ansi_leftovers = nil
			else
				for ansi in string.gmatch(line, '\27%[.-m') do
					ansi_leftovers = (ansi_leftovers or '') .. ansi
				end
      end
		end

		self:Parse(lines)

		return
	end

	for line in ipairs(paragraph) do
		for _, trigger in ipairs(self.triggers) do
			if #paragraph >= trigger.lines - 1 + line then
				local paragraph = table.concat(paragraph, '\n', line, trigger.lines - 1 + line)
				local match = { string.match(paragraph, trigger.pattern) }
				if #match > 0 then
					trigger.callback(match)
				end
			end
		end
	end
end -- Parse()

--- Add a trigger.
-- 
function Add(self, pattern, callback, sequence)
	local lines = (type(pattern) == 'table' and pattern[2] or 1)
	local pattern = (type(pattern) == 'table' and pattern[1] or pattern)
	local sequence = sequence or 0

	local trigger =
	{
		pattern = pattern,
		callback = callback,
		sequence = sequence,
		lines = lines,
	}
	table.insert(self.triggers, trigger)

	if #self.triggers > 1 then
		table.sort(self.triggers, function(a, b) return a.sequence < b.sequence end)
	end
end -- Add()
