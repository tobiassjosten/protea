-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'

local protea = require 'core.init'
local event  = protea:GetModule('event')
local state  = protea:GetModule('state')



-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.teststate', lunit.testcase, package.seeall)

function SetUp()
	event:Initialize()
	state:Initialize(protea)

	test_state_variable = nil
end

function TestStateNew()
	local test = state:New('test')
	assert_table(test, 'New() factory produces states.')
end

function TestStateSet()
	local test = state:New('test')
	test:Set(true)
	assert_true(test.status, 'States can have their status set.')
end

function TestStateSetIndividually()
	local test1 = state:New('test'):Set(true)
	local test2 = state:New('test'):Set(false)
	assert_true(test1.status, 'States are kept individually.')
	assert_false(test2.status, 'States are kept individually.')
end

function TestStateSetEvent()
	event:Listen('state', function() test_state_variable = true end, { name = 'test', value = true })
	state:New('test'):Set(true)
	assert_true(test_state_variable, 'State changes raises an event.')
end

function TestStateGet()
	state:New('test'):Set(true)
	local test = state:Get('test')
	assert_true(test.status, 'States can be fetched from factory list.')
end

function TestStateSetGetProperty()
	local test = state:New('test'):Set(true, 'arbitrary_property')
	assert_true(test.arbitrary_property, 'States can set and hold arbitrary properties.')
	assert_nil(test.status, 'Changing state properties does not affect its status.')
end

function TestStateTimer()
	local test = state:New('test'):Set(false):Timer(true, 1)
	assert_true(test.status, 'Initiating a timer also sets the status of the state.')
	state:TickTimers(.5)
	assert_true(test.status, 'State keeps status while timer is still active.')
	state:TickTimers(.5)
	assert_false(test.status, 'Status is changed back on timeout.')
end

function TestStateTimerOverflow()
	local test = state:New('test'):Set(false):Timer(true, 1)
	state:TickTimers(2)
	assert_false(test.status, 'Status is changed back on timeout.')

end

function TestStateTimerReset()
	local test = state:New('test'):Set(false):Timer(true, 1)
	test:Set(false):Set(true)
	state:TickTimers(2)
	assert_true(test.status, 'Timer should be reset when status is updated.')
end

function TestStateTemporary()
	local test = state:New('test'):Set(false):Temporary(true)
	state:FlushTemporaries()
	assert_false(test.status, 'States reset when temporaries are flushes.')
end

function TestStateQueue()
	local test = state:New('test'):Queue(true)
	state:ParseQueue()
	assert_true(test.status, 'Queued values are set when queue is parsed.')
end

function TestStateDequeue()
	local test = state:New('test'):Queue(true):Dequeue()
	state:ParseQueue()
	assert_nil(test.status, 'Dequeuing removes state from queue.')
end

function TestStateActionsAffliction()
	state:New('affliction',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'someaction' }
	})
	local actions = state:Actions()
	assert_equal('affliction', actions['someaction'][1], 'Afflictions are cured with disablers.')
end

function TestStateActionsDefense()
	state:New('defense',
	{
		status   = false,
		type     = 'defense',
		enablers = { 'someaction' }
	})
	local actions = state:Actions()
	assert_equal('defense', actions['someaction'][1], 'Defenses are put up with enablers.')
end

function TestStateReset()
	local affliction = state:New('affliction',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'someaction' }
	})
	local defense = state:New('defense',
	{
		status   = false,
		type     = 'defense',
		enablers = { 'someaction' }
	})
	state:MarkResets('someaction')
	assert_table(affliction.reset, 'Afflictions are marked for resetting when their disablers matches reset input.')
	assert_table(defense.reset, 'Defense are marked for resetting when their enablers matches reset input.')
end

function TestStateResetAffliction()
	local affliction = state:New('affliction',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'someaction' }
	})
	state:MarkResets('someaction')
	state:ParseResets()
	assert_false(affliction.status, 'Afflictions are set to false when reset.')
end

function TestStateResetDefense()
	local defense = state:New('defense',
	{
		status   = false,
		type     = 'defense',
		enablers = { 'someaction' }
	})
	state:MarkResets('someaction')
	state:ParseResets()
	assert_true(defense.status, 'Defenses are set to true when reset.')
end

function TestStateResetSet()
	local affliction = state:New('affliction',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'someaction' }
	})
	state:MarkResets('someaction')

	affliction:Set(false)

	assert_nil(affliction.reset, 'Setting the status of a state removes its reset mark.')
end

function TestStateResetQueue()
	local affliction = state:New('affliction',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'someaction' }
	})
	state:MarkResets('someaction')

	affliction:Queue(false)

	assert_nil(affliction.reset, 'Queuing the status of a state removes its reset mark.')
end

function TestStateResetResetSet()
	local affliction1 = state:New('affliction1',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action1' }
	})
	local affliction2 = state:New('affliction2',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action1' }
	})
	local affliction3 = state:New('affliction3',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action2' }
	})
	state:MarkResets('action1'):MarkResets('action2')

	affliction1:Set(true)

	assert_nil(affliction2.reset, 'States sharing reset input are all unmarked from resetting when one of them is set.')
	assert_table(affliction3.reset, 'States not sharing reset input are unaffected by one being set.')
end

function TestStateResetResetQueue()
	local affliction1 = state:New('affliction1',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action1' }
	})
	local affliction2 = state:New('affliction2',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action1' }
	})
	local affliction3 = state:New('affliction3',
	{
		status    = true,
		type      = 'affliction',
		disablers = { 'action2' }
	})
	state:MarkResets('action1'):MarkResets('action2')

	affliction1:Queue(true)

	assert_nil(affliction2.reset, 'States sharing reset input are all unmarked from resetting when one of them is queued.')
	assert_table(affliction3.reset, 'States not sharing reset input are unaffected by one being queued.')
end
