-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'

local protea  = require 'core.init'
local action  = protea:GetModule('action')
local command = protea:GetModule('command')
local state   = protea:GetModule('state')



-- === === === === === === === === === === === === === === === === === === ====
-- ACTION MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testaction', lunit.testcase, package.seeall)

function SetUp()
	action:Initialize(protea)
	command:Initialize(protea)
	state:Initialize(protea)
end

function TestActionCheck()
	assert_true(action:Validate('test'), 'Test action should validate.')
	state:Set('pause', true)
	assert_false(action:Validate('test'), 'Test action should not validate when system is paused.')
end

function TestActionCheckExclude()
	state:Set('pause', true)
	assert_true(action:Validate('pause'), 'Pause action should validate even when system is paused.')
end

function TestActionParse()
	action:Parse({ 'test' })
	assert_equal('test', command:QueueGet(), 'Action was not properly added to command queue.')
end

function TestActionParseSequence()
	action:Parse({ 'test2', 'test2', 'test3', 'test1', 'test3' })
	assert_equal('test1', command:QueueGet(), 'Action was not properly added first to command queue.')
end
