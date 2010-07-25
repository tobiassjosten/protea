-- === === === === === === === === === === === === === === === === === === ====
-- MAP MODULE
-- === === === === === === === === === === === === === === === === === === ====

local pairs        = pairs
local ipairs       = ipairs
local rawget       = rawget
local require      = require
local setmetatable = setmetatable
local string       = string
local table        = table
local tonumber     = tonumber
local tostring     = tostring
local type         = type

package.loaded[...] = {}
module(...)

map   = {}
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

--- Bidirectional A* algorithm.
function Path(self, start, goal)
	if type(start) ~= 'table' or not start.id then
		start = self:Room(start)
		if not start then
			return false
		end
	end

	if type(goal) ~= 'table' then
		goal = self:Room(goal)
		if not goal then
			return false
		end
	end

	local open, closed = {}, {}

	local getentry = function()
		local next_cost, next_key
		for key, value in ipairs(open) do
			if not next_cost or next_cost >= value.cost then
				next_cost = value.cost
				next_key = key
			end
		end

		if next_key then
			local next_entry = open[next_key]
			closed[next_entry.room.id] = next_entry
			table.remove(open, next_key)
			return next_entry
		end

		return false
	end

	local getcost = function(room)
		return 1
	end

	local getopen = function(room)
		local entry = false
		for _, value in pairs(open) do
			if value.room.id == room.id then
				entry = value
			end
		end
		return entry
	end

	local getbacktrace = function(room, reverse)
		local path = {}

		while room and closed[room.id].parent do
			local parent = closed[room.id].parent
			local parent_direction = false
			for direction, adjacent_room in pairs(not reverse and room.exits or parent.exits) do
				if adjacent_room.id == (not reverse and parent.id or room.id) then
					parent_direction = direction
				end
			end
			table.insert(path, parent_direction)
			room = parent
		end

		if reverse then
			local path_reversed = {}
			for i = #path, 0, -1 do
				table.insert(path_reversed, path[i])
			end
			path = path_reversed
		end

		return path
	end

	table.insert(open, { room = start, cost = 0, origin = start })
	table.insert(open, { room = goal, cost = 0, origin = goal })

	local search = function()
		while #open > 0 do
			local current_entry = getentry()
			local success = false

			for direction, adjacent_room in pairs(current_entry.room.exits) do
				local adjacent_entry =
				{
					room = adjacent_room,
					cost = current_entry.cost + getcost(adjacent_room),
					parent = current_entry.room,
					direction = direction,
					origin = current_entry.origin,
				}
				if not closed[adjacent_room.id] and not getopen(adjacent_room) then
					table.insert(open, adjacent_entry)
				elseif closed[adjacent_room.id] and closed[adjacent_room.id].origin.id ~= current_entry.origin.id then
					success = { current_entry.room, adjacent_room }
				end
			end

			if success then
				local reverse = closed[success[1].id].origin.id == start.id

				local path = {}
				local path1 = getbacktrace(success[reverse and 1 or 2], true)
				local path2 = getbacktrace(success[reverse and 2 or 1], false)

				-- The missing piece
				for direction, adjacent_room in pairs(success[reverse and 1 or 2].exits) do
					if adjacent_room.id == success[reverse and 2 or 1].id then
						table.insert(path1, direction)
						break
					end
				end

				for _,v in ipairs(path1) do
					table.insert(path, v)
				end
				for _,v in ipairs(path2) do
					table.insert(path, v)
				end

				return path
			end
		end
	end

	return search()
end -- Path
