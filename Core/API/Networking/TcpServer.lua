local TcpServer = {}

local setmetatable = setmetatable

function TcpServer:Construct()
	local instance = {}

	setmetatable(instance, { __index = TcpServer })

	return instance
end

function TcpServer:StartListening(hostName, port)
	DEBUG("Listening on tcp://" .. hostName .. ":" .. port)
end

_G.TcpServer = TcpServer

return TcpServer