-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'

local protea  = require 'core.init'
local trigger = protea:GetModule('trigger')



-- === === === === === === === === === === === === === === === === === === ====
-- TRIGGER MODULE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.core.testtrigger', lunit.testcase, package.seeall)

function SetUp()
	trigger:Initialize()

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
	trigger:Add('test suite', '^one\ntwo$', 2, function() test_trigger_variable = true end)
	trigger:Parse('test suite', 'one\ntwo')
	assert_true(test_trigger_variable, 'Multiline pattern trigger did not fire.')
end
