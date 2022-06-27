-- Importing via relative paths from the VFS doesn't work due to an error in the path resolution
-- This is a workaround and should be replaced with relative imports once the issue is resolved
local TcpClient = _G.TcpClient
local TcpServer = _G.TcpServer
local TcpSocket = _G.TcpSocket
local AsyncHandleMixin = _G.AsyncHandleMixin
local AsyncStreamMixin = _G.AsyncStreamMixin
local AsyncSocketMixin = _G.AsyncSocketMixin

local C_Networking = {
	TcpSocket = TcpSocket,
	TcpServer = TcpServer,
	TcpClient = TcpClient,
	AsyncHandleMixin = AsyncHandleMixin,
	AsyncStreamMixin = AsyncStreamMixin,
	AsyncSocketMixin = AsyncSocketMixin,
}

_G.C_Networking = C_Networking

_G.TcpClient = nil
_G.TcpServer = nil
_G.TcpSocket = nil
_G.AsyncHandleMixin = nil
_G.AsyncStreamMixin = nil
_G.AsyncSocketMixin = nil