local Socket = import("Socket.lua")
local TcpServer = import("TcpServer.lua")

local C_Networking = {}

function C_Networking.CreateTcpServer()
	return TcpServer:Construct()
end

function C_Networking.CreateSocket()
	return Socket:Construct()
end

_G.C_Networking = C_Networking