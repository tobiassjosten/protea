-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'

local protea = require 'core.init'
local event  = protea:GetModule('event')

protea.Send = function(self, command)
	send_variable = command
end

local command = require 'core.command'



-- === === === === === === === === === === === === === === === === === === ====
-- COMMAND MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testcommand', lunit.testcase, package.seeall)

function SetUp()
	send_variable = nil
	command:Initialize(protea)
end

function TestCommandSend()
	command:Send('test')
	assert_equal('test', send_variable, 'Command was not sent.')
end

function TestCommandEvent()
	event:Listen('command', function(parameters) test_command_variable = parameters['value'] end, { name = 'send' })
	command:Send('test')
	assert_equal('test', test_command_variable, 'Command did not raise the proper event.')
end

function TestCommandCheckSent()
	command:Send('test')
	command:Send('tests')
	assert_equal('test', command:Get('test'), 'Could not get the first command from sent list.')
	assert_equal('tests', command:Get('tests+'), 'Could not get the second command from sent list.')
end

function TestCommandTimeout()
	command:Send('test')
	for i = 1, 14 do
		command:Tick(.2)
	end
	assert_equal('test', command:Get('test'), 'Command should not yet timeout.')
	command:Tick(.2)
	assert_false(command:Get('test'), 'Command did not properly timeout.')
end

function TestCommandSuccess()
	command:Send('test')
	command:Success('test')
	command:Succeed()
	assert_false(command:Get('test'), 'Command was not marked as successful and removed.')
end

function TestCommandSuccessMultiple()
	command:Send('a')
	command:Send('b')
	command:Send('c')
	command:Success('b')
	command:Succeed()
	assert_false(command:Get('a'), 'Command was not marked as successful and removed.')
	assert_equal('c', command:Get('c'), 'Command should not have been reset.')
end

function TestCommandQueue()
	assert_false(command:QueueGet('test'), 'Command queue should start out empty.')
	command:Queue('test')
	assert_equal('test', command:QueueGet('test'), 'Command was not added to queue.')
end

function TestCommandQueueGetFirst()
	command:Queue('test1')
	command:Queue('test2')
	assert_equal('test1', command:QueueGet(), 'First entry in command queue should be the first one inserted.')
end

function TestCommandQueueSend()
	command:Queue('test')
	command:QueueSend()
	assert_equal('test', send_variable, 'Command in queue was not sent.')
end

function TestCommandQueueSendOrder()
	command:Queue('a')
	command:Queue('b')
	command:Queue('c')
	command:QueueSend()
	assert_equal('c', send_variable, 'Commands in queue were not sent in correct order.')
end

function TestCommandQueueFlush()
	command:Queue('test')
	command:QueueFlush()
	assert_false(command:QueueGet('test'), 'Command queue was not properly flushed.')
end
