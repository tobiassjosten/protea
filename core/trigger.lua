-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local string =
{
  match = string.match,
}
local table =
{
  insert = table.insert,
  sort = table.sort,
}

module(...)

triggers = {}



-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Parse paragraph and look for trigger matches.
-- 
function Parse(self, paragraph)
  for _, trigger in ipairs(self.triggers) do
    if string.match(paragraph, trigger.pattern) then
      trigger.callback()
    end
  end
end -- Parse()

--- Add a trigger.
-- 
function Add(self, pattern, callback, sequence)
  local trigger =
  {
    pattern = pattern,
    callback = callback,
    sequence = sequence or 0,
  }
  table.insert(self.triggers, trigger)

	if #self.triggers > 1 then
		table.sort(self.triggers, function(a, b) return a.sequence < b.sequence end)
	end
end -- Add()
