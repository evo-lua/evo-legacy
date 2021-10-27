local pairs = pairs
local type = type

-- This function is provided purely for convenience; it's neither optimized nor particularly robust
-- Note: I'd prefer something builtin, but I haven't found anything in LuaJIT
function table.count(object)
	local count = 0
	for k, v in pairs(object) do
		-- cdata can trip up nil checks, so it's best to be explicit here
		if type(v) ~= "nil" then count = count + 1 end
	end
	return count
end