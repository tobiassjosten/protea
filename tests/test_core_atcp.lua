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
-- ATCP MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testatcp', lunit.testcase, package.seeall)

function SetUp()
	event_listeners = table.clone(event.listeners)
	test_atcp_variable = nil
	adapter.sendpkt_variable = nil
end

function TearDown()
	event.listeners = event_listeners
	test_atcp_variable = nil
	adapter.sendpkt_variable = nil
end

function TestATCPInitialization()
	atcp:Initialize()
	assert_match('^\255\253\200\255\250\200.+\255\240$', adapter.sendpkt_variable, 'Invalid initialization string.')
end

function TestATCPAuthentication()
	assert_equal(1083, atcp:Auth('ygvhnqpakyzubgiejmrc'), 'Authentication challenge did not validate.')
end

function TestATCPParseNegotiationWillATCP()
	event:Listen('atcp', function() test_atcp_variable = true end, { name = 'status', value = true })
	local test_atcp_variable_packet = atcp:Parse('\255\251\200')
	assert_equal('', test_atcp_variable_packet, 'ATCP parser did not strip the IAC WILL ATCP sequence.')
	assert_true(test_atcp_variable, 'ATCP parser did not raise the ATCP event for status = true.')
end

function TestATCPParseNegotiationWontATCP()
	event:Listen('atcp', function() test_atcp_variable = true end, { name = 'status', value = false })
	local test_atcp_variable_packet = atcp:Parse('\255\252\200')
	assert_equal('', test_atcp_variable_packet, 'ATCP parser did not strip the IAC WONT ATCP sequence.')
	assert_true(test_atcp_variable, 'ATCP parser did not raise the ATCP event for status = false.')
end

function TestATCPExtract()
	local packet, test_atcp_variable = atcp:Extract('\255\250\200test_key test_value\255\240')
	assert_equal('', packet, 'ATCP extracter did not strip ATCP buffer sequence.')
	assert_table(test_atcp_variable, 'No ATCP values were extracted from ATCP buffer sequence.')
	assert_equal('test_value', test_atcp_variable['test_key'], 'Test key/value was not extracted from ATCP buffer sequence.')
end

function TestATCPParseRaiseEvent()
	event:Listen('atcp', function() test_atcp_variable = true end, { name = 'test_key', value = 'test_value' })
	atcp:Parse('\255\250\200test_key test_value\255\240')
	assert_true(test_atcp_variable, 'No event was raised for ATCP data.')
end

function TestATCPParseMultiplePackets()
	event:Listen('atcp', function() test_atcp_variable = true end)

	local packet = 'test_before\255\250\200test_key '
	packet = atcp:Parse(packet)
	assert_equal('test_before\255\250\200test_key ', packet, 'ATCP parser should not strip incomplete ATCP sequences.')

	assert_nil(test_atcp_variable, 'ATCP parser should not raise event for incomplete data.')

	packet = packet .. 'test_value\255\240test_after'
	packet = atcp:Parse(packet)
	assert_equal('test_beforetest_after', packet, 'ATCP parser did not strip the ATCP data.')

	assert_true(test_atcp_variable, 'No event was raised for ATCP data.')
end

function TestATCPParseAuthChallenge()
	atcp:Parse('\255\250\200Auth.Request CH ygvhnqpakyzubgiejmrc\255\240')
	assert_match('^\255\250\200auth 1083 Protea .+\255\240$', adapter.sendpkt_variable, 'Authentication challenge was not met.')
end
