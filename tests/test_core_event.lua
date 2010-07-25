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
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testevent', lunit.testcase, package.seeall)

function SetUp()
	event_listeners = table.clone(event.listeners)
	test_event_variable = nil
end

function TearDown()
	event.listeners = event_listeners
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