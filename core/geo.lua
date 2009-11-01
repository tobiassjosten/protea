-- === === === === === === === === === === === === === === === === === === ====
-- MAP MODULE
-- === === === === === === === === === === === === === === === === === === ====

local pairs = pairs
local rawget = rawget
local setmetatable = setmetatable
local string =
{
	match = string.match,
}
local tonumber = tonumber
local tostring = tostring
local type = type

module(...)

map = {}
rooms = {}



-- === === === === === === === === === === === === === === === === === === ====
-- MAP METHODS
-- === === === === === === === === === === === === === === === === === === ====

-- Load map.
function Load(self, map)
	self.map = map

	for id in pairs(self.map) do
		self.map[id].id = id
	end

	return true
end -- Load()

--- Save map.
function Save(self)
	return self.map
end -- Save()

--- Fetch a room object.
function Room(self, data)
	if not data then
		if not self.current_room then
			return false
		end
		return self:Room(self.current_room)
	end

	if type(data) == 'number' then
		if not self.map[data] then
			return false
		end
		return self:Room(self.map[data])
	end

	if type(data) == 'string' then
		if self.rooms[data] then
			return self:Room(self.rooms[data])
		end

		for id, room in pairs(self.map) do
			if room.title == data or string.match(room.title, data) then
				self.rooms[data] = id
				return self:Room(id)
			end
		end

		return false
	end

	local room = { data = data }
	local mt =
	{
		__index = function(t, k)
			if k == 'exits' then
				if not rawget(t, k) then
					t[k] = self:Exits(t.data[k])
				end
				return t[k]
			end
			return t.data[k]
		end,

		__tostring = function(t)
			return t.data.title
		end,

		__concat = function(a, b)
			local a = type(a) == 'table' and tostring(a) or a
			local b = type(b) == 'table' and tostring(b) or b
			return a .. b
		end,
	}
	setmetatable(room, mt)

	return room
end -- Room()

--- Populate exits with room objects.
function Exits(self, exits)
	for direction, id in pairs(exits) do
		exits[direction] = self:Room(id) or nil
	end
	return exits
end -- Exits()
