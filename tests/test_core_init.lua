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
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.testcore', lunit.testcase, package.seeall)

function SetUp()
	protea:EnvironmentReset()
	modules_queue = protea.modules_queue
	test_core_variable = nil
	state_states = table.clone(state.states)
	state.states['affliction1'] = {
		status = false,
		setting = false,
		disable_actions = { 'cure1' },
	}
end

function TearDown()
	protea:EnvironmentReset()
	protea.modules_queue = modules_queue
	test_core_variable = nil
	state.states = state_states
end

function TestModulesExistance()
	assert_table(event, 'Missing Event module.')
	assert_table(atcp, 'Missing ATCP module.')
	assert_table(trigger, 'Missing Trigger module.')
	assert_table(command, 'Missing Command module.')
	assert_table(state, 'Missing State module.')
	assert_table(action, 'Missing Action module.')
	assert_table(geo, 'Missing Geo module.')
end

function TestModulesLoading()
	protea:ModuleLoad('test')
	assert_not_nil(test, 'Test module could not be loaded.')
	assert_not_nil(test.test_core_variable, 'Test module is missing the test_core_variable property.')
end

function TestModulesResetting()
	protea:ModuleLoad('test')
	protea:ModuleLoad('test', 'test')
	protea:ModuleReset()
	assert_true(test.test_core_variable, 'Property of test module was not reset.')
end

function TestEnvironmentSetGet()
	assert_nil(protea:Environment('test_environment'))
	local realm = protea:Environment('test_environment', 'test')
	assert_equal('test', realm, 'Setting realm environment did not return the value.')
	assert_equal('test', protea:Environment('test_environment'), 'Realm environment was not set.')
end

function TestEnvironmentRealmLoading()
	protea:Environment('realm', 'test')
	assert_true(test_core_variable, 'Init module in test realm package was not loaded.')
end

function TestIllusion()
	protea:Illusion('test')
	assert_true(protea:Illusion(), 'Illusion detection was not set.')
	state:Flush()
	assert_false(protea:Illusion(), 'Illusion detection was not properly cleared.')
end

function TestActions()
	state:Set('affliction1', true)
	local actions = protea:Actions()
	assert_equal('cure1', actions[1], 'Actions list was not correctly assembled.')
end
