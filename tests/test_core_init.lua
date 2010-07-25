-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA TEST SUITE
-- === === === === === === === === === === === === === === === === === === ====

require 'lunit'
protea = require 'core.init'



-- === === === === === === === === === === === === === === === === === === ====
-- PROTEA CORE
-- === === === === === === === === === === === === === === === === === === ====

module('protea.testcore', lunit.testcase, package.seeall)

function TestLoadModule()
	local init = protea:LoadModule('init')
	assert_table(init, 'Module loading indicates success.')
	assert_table(protea:GetModule('init'), 'Module is loaded into Protea.')
end

function TestLoadModuleCase()
	local init = protea:LoadModule('InIt')
	assert_table(init, 'Loading modules is case insensitive.')
	assert_table(protea:GetModule('iNiT'), 'Fetching modules is case insensitive.')
end

function TestLoadMissingModule()
	local asdf = protea:LoadModule('asdf')
	assert_false(asdf, 'Missing module is not loaded.')
end

function TestGetUnloadedModule()
	local init = protea:GetModule('init')
	assert_table(init, 'Unloaded module is automatically loaded on request.')
end
