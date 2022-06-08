local TcpServer = {}

local setmetatable = setmetatable

function TcpServer:Construct()
	local instance = {}

	setmetatable(instance, { __index = TcpServer })

	return instance
end

_G.TcpServer = TcpServer

return TcpServer