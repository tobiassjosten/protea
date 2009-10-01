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
function Add(self, pattern, callback)
  local trigger =
  {
    pattern = pattern,
    callback = callback,
  }
  table.insert(self.triggers, trigger)
end -- Add()
