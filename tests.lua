-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core', lunit.testcase, package.seeall)

function TestModulesExistance()
	assert_table(event, 'Missing Event module.')
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
