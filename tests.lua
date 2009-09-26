-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core', lunit.testcase, package.seeall)

function SetUp()
	protea:EnvironmentReset()
	test_core_variable = nil
end

function TearDown()
	protea:EnvironmentReset()
	test_core_variable = nil
end

function TestModulesExistance()
	assert_table(event, 'Missing Event module.')
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



-- === === === === === === === === === === === === === === === === === === ====
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.event', lunit.testcase, package.seeall)

function SetUp()
	event.listeners = {}
	test_event_variable = nil
end

function TearDown()
	event.listeners = {}
	test_event_variable = nil
end

function TestEventSimpleListener()
	event:Listen('test', function() test_event_variable = true end)
	event:Raise('test')
	assert_true(test_event_variable, 'Event was not raised.')
end

function TestEventSequenceListener()
	event:Listen('test', function() assert_true(test_event_variable, 'Event was not raised in correct order.') end, 1)
	event:Listen('test', function() test_event_variable = true end)
	event:Raise('test')
end

function TestEventPassParameters()
	local TestEventPassParametersFunction = function(parameters)
		assert_not_nil(parameters)
		test_event_variable = parameters['property']
	end
	event:Listen('test', TestEventPassParametersFunction)
	event:Raise('test', { property = true })
	assert_true(test_event_variable, 'Event did not pass its parameters.')
end

function TestEventParameterFilters()
	event:Listen('test', function() test_event_variable = true end, { property = true })
	event:Listen('test', function() test_event_variable = false end, { property = false })
	event:Raise('test', { property = true })
	assert_true(test_event_variable, 'Event was run despite its parameter filter.')
end
