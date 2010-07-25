-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
protea = require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.testcore', lunit.testcase, package.seeall)

function SetUp()
end

function TearDown()
end

function TestLoadModule()
	local init = protea:LoadModule('Init')
	assert_true(init, 'Module loading indicates success.')
	assert_table(protea.Init, 'Module is loaded into Protea.')
end

function TestLoadMissingModule()
	local asdf = protea:LoadModule('asdf')
	assert_false(asdf, 'Missing module is not loaded.')
end
