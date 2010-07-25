-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
local protea = require 'core.init'
local geo    = protea:GetModule('geo')



-- === === === === === === === === === === === === === === === === === === ====
-- GEO MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testgeo', lunit.testcase, package.seeall)

sample_map =
{
	{
		title = 'Room A',
		exits =
		{
			east = 2,
		},
	},
	{
		title = 'Room B',
		exits =
		{
			east = 3,
			west = 1,
		},
	},
	{
		title = 'Room C',
		exits =
		{
			west = 2,
		},
	},
}

function SetUp()
	geo_map = nil
end

function TestGeoSetGet()
	assert_true(geo:Load({}), 'Empty map could not be loaded.')
	assert_table(geo:Save(), 'Map was not properly returned.')
end

function TestGeoRoomBasic()
	geo:Load(sample_map)
	assert_equal(1, geo:Room('Room A').id, 'Incorrect room ID returned for Room A.')
	assert_equal('Room A', tostring(geo:Room(1)), 'Incorrect room title returned for room 1.')
end

function TestGeoRoomSearch()
	geo:Load(sample_map)
	assert_equal(1, geo:Room('.- A').id, 'Search did not properly find Room A.')
end

function TestGeoExits()
	geo:Load(sample_map)
	assert_equal('Room B', tostring(geo:Room(1).exits.east), 'Exits were not properly loaded.')
end

function TestGeoPathing()
	geo:Load(sample_map)
	local path = geo:Path(geo:Room(1), geo:Room(3))
	assert_table(path, 'Did not get a propery path.')
	assert_equal('east', path[1], 'First direction in path should be east.')
	assert_equal('east', path[2], 'Second direction in path should be east.')
end

function TestGeoPathingReverse()
	geo:Load(sample_map)
	local path = geo:Path(geo:Room(3), geo:Room(1))
	assert_table(path, 'Did not get a propery path.')
	assert_equal('west', path[1], 'First direction in path should be west.')
	assert_equal('west', path[2], 'Second direction in path should be west.')
end
