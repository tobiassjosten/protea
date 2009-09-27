-- === === === === === === === === === === === === === === === === === === ====
-- ATCP MODULE
-- === === === === === === === === === === === === === === === === === === ====

local ipairs = ipairs
local protea = protea
local table =
{
	insert = table.insert,
	concat = table.concat,
}

module(...)

-- Telnet escape codes
EOR = '\025'
ATCP = '\200'
SE = '\240'
GA = '\249'
SB = '\250'
WILL = '\251'
WONT = '\252'
DO = '\253'
DONT = '\254'
IAC = '\255'

-- Telnet sequences
IAC_WILL_ATCP = IAC .. WILL .. ATCP
IAC_WONT_ATCP = IAC .. WONT.. ATCP
IAC_DO_ATCP = IAC .. DO .. ATCP
IAC_DONT_ATCP = IAC .. DONT .. ATCP
IAC_SB_ATCP = IAC .. SB.. ATCP
IAC_SE = IAC .. SE
IAC_DO_EOR = IAC .. DO .. EOR
IAC_WILL_EOR = IAC .. WILL .. EOR
IAC_GA = IAC .. GA

-- Initialization options
options =
{
	{ key = 'hello', value = 'Protea ' .. protea.version },
	{ key = 'auth', value = '1' },
	{ key = 'composer', value = '0' },
	{ key = 'keepalive', value = '1' },
	{ key = 'char_name', value = '1' },
	{ key = 'filestore', value = '0' },
	{ key = 'topvote', value = '0' },
	{ key = 'char_vitals', value = '1' },
	{ key = 'room_brief', value = '1' },
	{ key = 'room_exits', value = '1' },
	{ key = 'map_display', value = '1' },
	{ key = 'mediapak', value = '0' },
	{ key = 'wiz', value = '0' },
}



-- === === === === === === === === === === === === === === === === === === ====
-- ATCP METHODS
-- === === === === === === === === === === === === === === === === === === ====

--- Initialize ATCP negotiations.
-- 
function Initialize(self)
	local options = {}
	for _, option in ipairs(self.options) do
		table.insert(options, option.key .. ' ' .. option.value)
	end
	options = table.concat(options, '\10')

	return self.IAC_DO_ATCP .. self.IAC_SB_ATCP .. options .. self.IAC_SE
end -- Initialize()
