local format = string.format
_G.format = format

local print = print
local function printf(...)
	return print(format(...))
end

_G.printf = printf