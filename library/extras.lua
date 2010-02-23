-- === === === === === === === === === === === === === === === === === === ====
-- EXTRAS LIBRARY
-- === === === === === === === === === === === === === === === === === === ====

--- Clone a table.
-- This can be very useful since Lua passes all its variables as references and
-- sometimes you do not want to affect the original.
-- @param t The table you want a clone of.
function table.clone(t)
	if not t or type(t) ~= 'table' then
		return t
	end
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end -- table.clone()
