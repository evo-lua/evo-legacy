local Socket = {}

local setmetatable = setmetatable

function Socket:Construct()
	local instance = {}

	setmetatable(instance, { __index = Socket })

	return instance
end

function Socket:StartConnecting(hostName, port)
	DEBUG("Connecting to tcp://" .. hostName .. ":" .. port)
end

_G.Socket = Socket

return Socket