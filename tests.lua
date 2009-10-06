-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
require 'library.bit'

-- Adapter functions
SendPkt = function(packet) test_sendpkt_variable = packet end
Send = function(action) test_send_variable = action end

require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core', lunit.testcase, package.seeall)

function SetUp()
	protea:EnvironmentReset()
	modules_queue = protea.modules_queue
	test_core_variable = nil
end

function TearDown()
	protea:EnvironmentReset()
	protea.modules_queue = modules_queue
	test_core_variable = nil
end

function TestModulesExistance()
	assert_table(event, 'Missing Event module.')
	assert_table(atcp, 'Missing ATCP module.')
	assert_table(trigger, 'Missing Trigger module.')
	assert_table(command, 'Missing Command module.')
	assert_table(state, 'Missing State module.')
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



-- === === === === === === === === === === === === === === === === === === ====
-- EVENT MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.event', lunit.testcase, package.seeall)

function SetUp()
	listeners = table.clone(event.listeners)
	test_event_variable = nil
end

function TearDown()
	event.listeners = listeners
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



-- === === === === === === === === === === === === === === === === === === ====
-- ATCP MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.atcp', lunit.testcase, package.seeall)

function SetUp()
	listeners = table.clone(event.listeners)
	test_atcp_variable = nil
	test_sendpkt_variable = nil
	SendPkt()
end

function TearDown()
	event.listeners = listeners
	test_atcp_variable = nil
	test_sendpkt_variable = nil
	SendPkt()
end

function TestATCPInitialization()
	atcp:Initialize()
	assert_match('^\255\253\200\255\250\200.+\255\240$', test_sendpkt_variable, 'Invalid initialization string.')
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
	assert_match('^\255\250\200auth 1083 Protea .+\255\240$', test_sendpkt_variable, 'Authentication challenge was not met.')
end



-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.trigger', lunit.testcase, package.seeall)

function SetUp()
	triggers = table.clone(trigger.triggers)
	test_trigger_variable = nil
end

function TearDown()
	trigger.triggers = triggers
	test_trigger_variable = nil
end

function TestTriggerSimple()
	trigger:Add('test suite', 'test', function() test_trigger_variable = true end)
	local matched = trigger:Parse('test suite', 'test')
	assert_true(test_trigger_variable, 'Simple trigger did not fire.')
	assert_true(matched, 'Trigger parser did not say that it matched any triggers.')
end

function TestTriggerMatches()
	trigger:Add('test suite', '(.+)', function(matches) test_trigger_variable = matches[1] end)
	trigger:Parse('test suite', 'test')
	assert_equal('test', test_trigger_variable, 'Parser did not send the pattern capture to the trigger callback.')
end

function TestTriggerPattern()
	trigger:Add('test suite', '^test[!&]%a+$', function() test_trigger_variable = true end)
	trigger:Add('test suite', '^test[^!&]%a+$', function() test_trigger_variable = false end, 1)
	trigger:Add('test suite', '^[!&].+', function() test_trigger_variable = false end, 1)
	trigger:Parse('test suite', 'test&asdf')
	assert_not_equal(false, test_trigger_variable, 'Mismatching trigger patterns fired.')
	assert_true(test_trigger_variable, 'Matching trigger patterns did not fire.')
end

function TestTriggerSequence()
	trigger:Add('test suite', 'test', function() test_trigger_variable = true end, 1)
	trigger:Add('test suite', 'test', function() test_trigger_variable = false end)
	trigger:Parse('test suite', 'test')
	assert_true(test_trigger_variable, 'Triggers fired out of sequence.')
end

function TestTriggerMultilineParagraph()
	trigger:Add('test suite', '^two$', function() test_trigger_variable = true end)
	trigger:Parse('test suite', 'one\ntwo')
	assert_true(test_trigger_variable, 'Pattern anchor did not work with multiline paragraph.')
end

function TestTriggerMultilinePattern()
	trigger:Add('test suite', { '^one\ntwo$', 2 }, function() test_trigger_variable = true end)
	trigger:Parse('test suite', 'one\ntwo')
	assert_true(test_trigger_variable, 'Multiline pattern trigger did not fire.')
end



-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.command', lunit.testcase, package.seeall)

function SetUp()
	queue = table.clone(command.queue)
	test_command_variable = nil
	test_send_variable = nil
end

function TearDown()
	command.queue = queue
	test_command_variable = nil
	test_send_variable = nil
end

function TestCommandSend()
	command:Queue('test')
	assert_equal('test', test_send_variable, 'Command was not sent.')
end

function TestCommandEvent()
	event:Listen('command', function(parameters) test_command_variable = parameters['value'] end, { name = 'sent' })
	command:Queue('test')
	assert_equal('test', test_command_variable, 'Command did not raise the proper event.')
end

function TestCommandCheckQueue()
	command:Queue('test')
	command:Queue('tests')
	assert_equal('test', command:Get('test'), 'Could not get the first command from queue.')
	assert_equal('tests', command:Get('tests+'), 'Could not get the second command from queue.')
end

function TestCommandTimeout()
	command:Queue('test')
	for i = 1, 14 do
		command:Tick(.2)
	end
	assert_equal('test', command:Get('test'), 'Command should not yet timeout.')
	command:Tick(.2)
	assert_false(command:Get('test'), 'Command did not properly timeout.')
end

function TestCommandSuccess()
	command:Queue('test')
	command:Success('test')
	command:Succeed()
	assert_false(command:Get('test'), 'Command was not marked as successful and removed.')
end

function TestCommandSuccessMultiple()
	command:Queue('a')
	command:Queue('b')
	command:Queue('c')
	command:Success('b')
	command:Succeed()
	assert_false(command:Get('a'), 'Command was not marked as successful and removed.')
	assert_equal('c', command:Get('c'), 'Command should not have been reset.')
end



-- === === === === === === === === === === === === === === === === === === ====
-- STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.state', lunit.testcase, package.seeall)

function SetUp()
	states = table.clone(state.states)
	test_state_variable = nil
end

function TearDown()
	state.states = states
	test_state_variable = nil
end

function TestStateSetGet()
	event:Listen('state', function() test_state_variable = true end, { name = 'test', value = true })
	state:Set('test', true)
	assert_true(state:Get('test'), 'State was not set to true.')
	assert_true(test_state_variable, 'State change did not raise event.')
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
