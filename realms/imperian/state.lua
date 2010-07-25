-- === === === === === === === === === === === === === === === === === === ====
-- IMPERIAN STATE MODULE
-- === === === === === === === === === === === === === === === === === === ====

local command = command
local event = event
local state = state
local trigger = trigger

package.loaded[...] = {}
module(...)

states = state.states



-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
-- GENERALIZED STATES
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

--- Slow command.
function GotSlowCommand(self)
	return self:Get('aeon')
end -- GetSlowCommand()

--- Slow command handling.
function GotSlowCommandHandling(self)
	return self:Get('aeon handling')
end -- GetSlowCommandHandling()

--- Command fumble.
function GotCommandFumble(self)
	return self:Get('stupidity')
end -- GetCommandFumble()



-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
-- BALANCES
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

states['mind balance'] = { status = true }
states['body balance'] = { status = true }

states['elixir balance'] = { status = true }
states['herb balance'] = { status = true }
states['salve balance'] = { status = true }
states['pipe balance'] = { status = true }

states['tree balance'] = { status = true }
states['purge balance'] = { status = true }
states['focus balance'] = { status = true }



--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----
-- BALANCE TRIGGERS
--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

-- General balances
trigger:Add('server', '^You have regained your mental equilibrium%.$', function() state:Queue('mind', true) end)
trigger:Add('server', '^You have recovered balance%.$', function() state:Queue('body', true) end)
trigger:Add('server', '^You have recovered balance on your legs%.$', function() state:Queue('body', true) end)
trigger:Add('server', '^You have regained (%a+) arm balance%.$', function(match) state:Queue(match[1] .. ' arm', true) end)

-- Elixir balance
trigger:Add('server', '^You take a drink from .+ vial%.$', function() local drink_command = command:Get('^drink %a+$') if drink_command == 'drink health' or drink_command == 'drink mana' then state:Queue('elixir balance', false) end end)
trigger:Add('server', '^You drink the last drop from .+ vial%.$', function() local drink_command = command:Get('^drink %a+$') if drink_command == 'drink health' or drink_command == 'drink mana' then state:Queue('elixir balance', false) end end)
trigger:Add('server', '^The elixir heals your body%.$', function() if not state:Get('blackout') then return end local drink_command = command:Get('^drink %a+$') if drink_command == 'drink health' or drink_command == 'drink mana' then state:Queue('elixir balance', false) end end)
trigger:Add('server', '^Your mind feels rejuvenated%.$', function() if not state:Get('blackout') then return end local drink_command = command:Get('^drink %a+$') if drink_command == 'drink health' or drink_command == 'drink mana' then state:Queue('elixir balance', false) end end)
trigger:Add('server', '^You drink the elixir without effect%.$', function() if not state:Get('blackout') then return end local drink_command = command:Get('^drink %a+$') if drink_command == 'drink health' or drink_command == 'drink mana' then state:Queue('elixir balance', false) end end)
trigger:Add('server', '^You may drink another healing elixir%.$', function() state:Queue('elixir balance', true) end)

-- Herb balance
trigger:Add('server', '^You quickly eat a galingale flower%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat some hyssop stem%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a juniper berry%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a piece of kelp%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a maidenhair leaf%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a mandrake root%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a nightshade root%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat an orphine seed%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^You quickly eat a wormwood root%.$', function() state:Queue('herb balance', false) end)
trigger:Add('server', '^The plant does nothing for you%.$', function() if state:Get('blackout') then state:Queue('herb balance', false) end end)
trigger:Add('server', '^You may eat another herb or plant%.$', function() state:Queue('herb balance', true) end)

-- Salve balance
trigger:Add('server', '^You quickly rub some salve on your %a+%.$', function() state:Queue('salve balance', false) end)
trigger:Add('server', '^The salve dissolves and is wasted%.$', function() state:Queue('salve balance', false) end)
trigger:Add('server', '^You may apply another salve%.$', function() state:Queue('salve balance', true) end)

-- Pipe balance
trigger:Add('server', '^You take a long drag off your pipe, filling your lungs with (%a+) smoke%.$', function() state:Queue('pipe balance', false) end)
trigger:Add('server', '^Your lungs have not recovered yet!$', function() state:Queue('pipe balance', false) end)
trigger:Add('server', '^You have recovered your breath and can smoke once more%.$', function() state:Queue('pipe balance', true) end)

-- Toadstool balance
trigger:Add('server', '^You quickly eat a toadstool%.$', function() state:Queue('toadstool balance', false) end)
trigger:Add('server', '^You may eat another toadstool%.$', function() state:Queue('toadstool balance', true) end)
trigger:Add('server', '^You feel your health and mana replenished%.$', function() if state:Get('blackout') then state:Queue('toadstool balance', false) end end)
trigger:Add('server', '^The toadstool slides down without effect%.$', function() if state:Get('blackout') then state:Queue('toadstool balance', false) end end)

-- Tree
trigger:Add('server', '^You touch the tree of life tattoo%.$', function() state:Queue('tree balance', false) end)
trigger:Add('server', '^Your senses return in a rush%.$', function() if state:Get('blackout') and command:Get('touch tree') then state:Queue('tree balance', false) end end)
trigger:Add('server', '^Your tree of life tattoo glows faintly for a moment then fades, leaving you ?\nunchanged%.$', 2, function() state:Queue('tree balance', false) end)
event:Listen('state tree balance false', function() if state:Get('tree balance') then protea:TimerAdd(10, function() state:Set('tree balance', true) end, 'state_tree_balance_reset') end end)

-- Purge balance
trigger:Add('server', '^You concentrate on purging your body of foreign toxins%.$', function() state:Queue('purge balance', false) end)
trigger:Add('server', '^You have not regained the ability to purge your body of toxins%.$', function() state:Queue('purge balance', false) end)
trigger:Add('server', '^You have regained the ability to purge your body%.$', function() state:Queue('purge balance', true) end)

-- Focus balance
trigger:Add('server', '^You focus your mind intently on curing your mental maladies%.$', function() state:Queue('focus balance', false) end)
trigger:Add('server', '^You concentrate, but your mind is too tired to focus%.$', function() state:Queue('focus balance', false) end)
trigger:Add('server', '^Your mind is able to focus once again%.$', function() state:Queue('focus balance', true) end)

-- Reserve balance
trigger:Add('server', '^You feel invigorated as your wounds heal before your eyes%.$', function() state:Queue('reserve balance', false) end)
trigger:Add('server', '^You close your eyes and are bolstered with power as you feel your mind ?\nrefreshed%.$', 2, function() state:Queue('reserve balance', false) end)
trigger:Add('server', '^Your limbs fill with strength as your endurance is replenished%.$', function() state:Queue('reserve balance', false) end)
trigger:Add('server', '^You take a deep breath and relax your mind, filling it with mental strength%.$', function() state:Queue('reserve balance', false) end)
trigger:Add('server', '^You are not yet able to do that again%.$', function() state:Queue('reserve balance', false) end)
