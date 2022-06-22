local TcpClient = import("./TcpClient.lua")
local TcpServer = import("./TcpServer.lua")
local TcpSocket = import("./TcpSocket.lua")

local C_Networking = {
	TcpSocket = TcpSocket,
	TcpServer = TcpServer,
	TcpClient = TcpClient,
}

_G.C_Networking = C_Networking