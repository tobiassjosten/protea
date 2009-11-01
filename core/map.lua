-- === === === === === === === === === === === === === === === === === === ====
-- MAP MODULE
-- === === === === === === === === === === === === === === === === === === ====

module(...)

rooms = {}



-- === === === === === === === === === === === === === === === === === === ====
-- MAP METHODS
-- === === === === === === === === === === === === === === === === === === ====

-- Load map.
function Load(self, rooms)
	self.rooms = rooms
	return true
end

--- Save map.
function Save(self)
	return self.rooms
end
