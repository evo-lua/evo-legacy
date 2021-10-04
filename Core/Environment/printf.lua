local print = print
local format = string.format

function printf(...)
	return print(format(...))
end

return printf