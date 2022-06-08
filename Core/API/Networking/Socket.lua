local Socket = {}

local setmetatable = setmetatable

function Socket:Construct()
	local instance = {}

	setmetatable(instance, { __index = Socket })

	return instance
end

_G.Socket = Socket

return Socket