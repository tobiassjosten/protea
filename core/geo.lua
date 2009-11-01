-- === === === === === === === === === === === === === === === === === === ====
-- MAP MODULE
-- === === === === === === === === === === === === === === === === === === ====

module(...)

map = {}



-- === === === === === === === === === === === === === === === === === === ====
-- MAP METHODS
-- === === === === === === === === === === === === === === === === === === ====

-- Load map.
function Load(self, map)
	self.map = map
	return true
end -- Load()

--- Save map.
function Save(self)
	return self.map
end -- Save()