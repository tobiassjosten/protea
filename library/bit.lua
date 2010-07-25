-- === === === === === === === === === === === === === === === === === === ====
-- BITWISE LIBRARY
-- === === === === === === === === === === === === === === === === === === ====

--[[---------------
LuaBit v0.4
-------------------
a bitwise operation lib for lua.

http://luaforge.net/projects/bit/

How to use:
-------------------
 bit.bnot(n) -- bitwise not (~n)
 bit.band(m, n) -- bitwise and (m & n)
 bit.bor(m, n) -- bitwise or (m | n)
 bit.bxor(m, n) -- bitwise xor (m ^ n)
 bit.brshift(n, bits) -- right shift (n >> bits)
 bit.blshift(n, bits) -- left shift (n << bits)
 bit.blogic_rshift(n, bits) -- logic right shift(zero fill >>>)

Please note that bit.brshift and bit.blshift only support number within
32 bits.

2 utility functions are provided too:
 bit.tobits(n) -- convert n into a bit table(which is a 1/0 sequence)
               -- high bits first
 bit.tonumb(bit_tbl) -- convert a bit table into a number
-------------------

Under the MIT license.

copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
--]]---------------

local math  = math
local table = table

package.loaded[...] = {}
module(...)

------------------------
-- bit lib implementions

function check_int(self, n)
 -- checking not float
 if(n - math.floor(n) > 0) then
  error("trying to use bitwise operation on non-integer!")
 end
end

function tobits(self, n)
 self:check_int(n)
 if(n < 0) then
  -- negative
  return self:tobits(bit.bnot(math.abs(n)) + 1)
 end
 -- to bits table
 local tbl = {}
 local cnt = 1
 while (n > 0) do
  local last = math.mod(n,2)
  if(last == 1) then
   tbl[cnt] = 1
  else
   tbl[cnt] = 0
  end
  n = (n-last)/2
  cnt = cnt + 1
 end

 return tbl
end

function tonumb(self, tbl)
 local n = table.getn(tbl)

 local rslt = 0
 local power = 1
 for i = 1, n do
  rslt = rslt + tbl[i]*power
  power = power*2
 end

 return rslt
end

function expand(self, tbl_m, tbl_n)
 local big = {}
 local small = {}
 if(table.getn(tbl_m) > table.getn(tbl_n)) then
  big = tbl_m
  small = tbl_n
 else
  big = tbl_n
  small = tbl_m
 end
 -- expand small
 for i = table.getn(small) + 1, table.getn(big) do
  small[i] = 0
 end

end

function bor(self, m, n)
 local tbl_m = self:tobits(m)
 local tbl_n = self:tobits(n)
 self:expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 and tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return self:tonumb(tbl)
end

function band(self, m, n)
 local tbl_m = self:tobits(m)
 local tbl_n = self:tobits(n)
 self:expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 or tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return self:tonumb(tbl)
end

function bnot(self, n)
 local tbl = self:tobits(n)
 local size = math.max(table.getn(tbl), 32)
 for i = 1, size do
  if(tbl[i] == 1) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 return self:tonumb(tbl)
end

function bxor(self, m, n)
 local tbl_m = self:tobits(m)
 local tbl_n = self:tobits(n)
 self:expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i] ~= tbl_n[i]) then
   tbl[i] = 1
  else
   tbl[i] = 0
  end
 end

 --table.foreach(tbl, print)

 return self:tonumb(tbl)
end

function brshift(self, n, bits)
 self:check_int(n)

 local high_bit = 0
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
  high_bit = 2147483648 -- 0x80000000
 end

 for i=1, bits do
  n = n/2
  n = bit_or(math.floor(n), high_bit)
 end
 return math.floor(n)
end

-- logic rightshift assures zero filling shift
function blogic_rshift(self, n, bits)
 self:check_int(n)
 if(n < 0) then
  -- negative
  n = self:bit_not(math.abs(n)) + 1
 end
 for i=1, bits do
  n = n/2
 end
 return math.floor(n)
end

function blshift(self, n, bits)
 self:check_int(n)

 if(n < 0) then
  -- negative
  n = self:bit_not(math.abs(n)) + 1
 end

 for i=1, bits do
  n = n*2
 end
 return self:bit_and(n, 4294967295) -- 0xFFFFFFFF
end

function bxor2(self, m, n)
 local rhs = self:bit_or(self:bit_not(m), self:bit_not(n))
 local lhs = self:bit_or(m, n)
 local rslt = self:bit_and(lhs, rhs)
 return rslt
end
