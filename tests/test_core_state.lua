-- === === === === === === === === === === === === === === === === === === ====
-- TEST ADAPTER
-- === === === === === === === === === === === === === === === === === === ====

adapter = {}

function adapter:SendPkt(packet)
	self.sendpkt_variable = packet
end

function adapter:Send(action)
	self.send_variable = action
end



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.teststate', lunit.testcase, package.seeall)

function SetUp()
	state_states = table.clone(state.states)
	state.states['affliction1'] = {
		status = false,
		setting = false,
		disable_actions = { 'cure1' },
	}
	state.states['affliction2'] = {
		status = false,
		setting = false,
		disable_actions = { 'cure2' },
	}
	event_listeners = table.clone(event.listeners)
	test_state_variable = nil
end

function TearDown()
	state.states = state_states
	event.listeners = event_listeners
	test_state_variable = nil
end

function TestStateSetGet()
	event:Listen('state', function() test_state_variable = true end, { name = 'test', value = true })
	state:Set('test', true)
	assert_true(state:Get('test'), 'State was not set to true.')
	assert_true(test_state_variable, 'State change did not raise event.')
end

function TestStateSetGetAttribute()
	state:Set('test', true, 'attribute')
	assert_false(state:Get('test'), 'State status should default to false.')
	assert_true(state:Get('test', 'attribute'), 'Attribute of state was not set.')
end

function TestStateTimed()
	event:Listen('state', function() test_state_variable = true end, { name = 'test', value = nil })
	state:SetTimed('test', true, 1)
	assert_true(state:Get('test'), 'State was not set to true.')
	state:Tick(.5)
	assert_true(state:Get('test'), 'State should still be true when not yet timed out.')
	state:Tick(.5)
	assert_false(state:Get('test'), 'State should have timed out.')
	assert_true(test_state_variable, 'State timeout did not raise event.')
end

function TestStateTimedOverCount()
	event:Listen('state', function() test_state_variable = true end, { name = 'test', value = nil })
	state:SetTimed('test', true, 1)
	state:Tick(2)
	assert_false(state:Get('test'), 'State should have timed out.')
	assert_true(test_state_variable, 'State timeout did not raise event.')
end

function TestStateTimedReset()
	state:SetTimed('test', false, 1)
	state:Set('test', true)
	state:Tick(1)
	assert_true(state:Get('test'), 'State should not have timed out.')
end

function TestStateTemporary()
	state:SetTemporary('test', true)
	assert_true(state:Get('test'), 'Temporary state was not set.')
	state:Flush()
	assert_false(state:Get('test'), 'Temporary state should have been flushed.')
end

function TestStateQueue()
	state:Queue('test', true)
	state:Parse()
	assert_true(state:Get('test'), 'State queue was not parsed.')
end

function TestStateQueue()
	state:Queue('test', true)
	state:Dequeue('test')
	state:Parse()
	assert_false(state:Get('test'), 'State could not be removed from queue.')
end

function TestStateActions()
	state:Set('affliction1', true)
	local actions = state:Actions()
	assert_equal('cure1', actions[1], 'Actions list was not correctly assembled.')
end

function TestStateReset()
	state:Set('affliction1', true)
	state:Reset('cure1')
	state:Parse()
	assert_false(state:Get('affliction1'), 'State should have been reset.')
end

function TestStateResetRemoveSet()
	state:Set('affliction1', true)
	state:Reset('cure1')
	state:Set('affliction1', false)
	assert_nil(state:Get('reset')['affliction1'], 'State should have been unmarked for resetting.')
end

function TestStateResetRemoveQueue()
	state:Set('affliction1', true)
	state:Reset('cure1')
	state:Queue('affliction1', false)
	assert_nil(state:Get('reset')['affliction1'], 'State should have been unmarked for resetting.')
end
