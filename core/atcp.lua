-- === === === === === === === === === === === === === === === === === === ====
-- ATCP MODULE
-- === === === === === === === === === === === === === === === === === === ====

local bit =
{
	bor = bit.bor,
}
local event = event
local ipairs = ipairs
local math =
{
	fmod = math.fmod,
}
local protea = protea
local SendPkt = SendPkt
local string =
{
	byte = string.byte,
	find = string.find,
	gmatch = string.gmatch,
	gsub = string.gsub,
	sub = string.sub,
}
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

	SendPkt(self.IAC_DO_ATCP .. self.IAC_SB_ATCP .. options .. self.IAC_SE)
end -- Initialize()

--- ATCP authentication.
-- 
function Auth(self, seed)
	local answer, i, n = 17, 0

	for letter in string.gmatch(seed, '.') do
		n = letter:byte() - 96

		if math.fmod(i, 2) == 0 then
			answer = answer + n * (bit.bor(i, 13))
		else
			answer = answer - n * (bit.bor(i, 11))
		end

		i = i + 1
	end

	return answer
end -- Auth()

--- Handle ATCP in incoming packages.
-- 
function Parse(self, packet)
	if (string.find(packet, self.IAC_WILL_ATCP)) then
		event:Raise('atcp', { name = 'status', value = true })
		packet = string.gsub(packet, self.IAC_WILL_ATCP, '')
	end

	if (string.find(packet, self.IAC_WONT_ATCP)) then
		event:Raise('atcp', { name = 'status', value = false })
		packet = string.gsub(packet, self.IAC_WONT_ATCP, '')
	end

	return packet
end -- Parse()

--- Extract ATCP data from a packet.
-- 
function Extract(self, packet)
	local pattern = self.IAC_SB_ATCP .. '(.-)' .. self.IAC_SE

	local extract = function(data)
		if not string.find(data, '\10') then
			data = string.gsub(data, ' ', '\10', 1)
		end
		if string.find(data, '\10') then
			local seperator = data:find('\10')
			atcp_extract_values[string.sub(data, 1, seperator - 1)] = string.sub(data, seperator + 1)
		end
		return ''
	end

	atcp_extract_values = {}

	packet = string.gsub(packet, pattern, extract)

	return packet, atcp_extract_values
end -- Extract()
