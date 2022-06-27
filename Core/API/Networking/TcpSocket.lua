local uv = require("uv")

local setmetatable = setmetatable
local type = type

local AsyncHandleMixin = _G.AsyncHandleMixin -- import("../../Primitives/AsyncHandleMixin.lua")
local AsyncStreamMixin = _G.AsyncStreamMixin -- import("../../Primitives/AsyncStreamMixin.lua")
local AsyncSocketMixin = _G.AsyncSocketMixin -- import("../../Primitives/AsyncSocketMixin.lua")

local TcpSocket = {
	__className = "TcpSocket",
	DEFAULT_SOCKET_CREATION_OPTIONS = {
		hostName = "127.0.0.1",
		port = 12345,
	}
}

function TcpSocket:Construct(hostName, port)
	local instance = {
		handle = uv.new_tcp(),
		hostName = hostName or self.DEFAULT_SOCKET_CREATION_OPTIONS.hostName,
		port = port or self.DEFAULT_SOCKET_CREATION_OPTIONS.port,
	}

	setmetatable(instance, { __index = self })

	return instance
end

setmetatable(TcpSocket, { __call = TcpSocket.Construct } )

function TcpSocket:SetKeepAliveTime(keepAliveTimeInMilliseconds)
	if type(keepAliveTimeInMilliseconds) ~= "number" or keepAliveTimeInMilliseconds < 0 then
		ERROR("Usage: TcpSocket:SetKeepAliveTime(keepAliveTimeInMilliseconds : number)")
		return
	end

	local enabledFlag = (keepAliveTimeInMilliseconds > 0)
	self.handle:keepalive(enabledFlag, keepAliveTimeInMilliseconds)
	if enabledFlag then
		DEBUG("TCP_KEEPALIVE is now " .. keepAliveTimeInMilliseconds .. " ms for socket at " .. self:GetURL())
	else
		DEBUG("TCP_KEEPALIVE is now OFF for socket at " .. self:GetURL())
	end

	return true
end

function TcpSocket:GetPort()
	return self.port
end

function TcpSocket:GetHostName()
	return self.hostName
end

function TcpSocket:GetURL()
	return "tcp://" .. self.hostName .. ":" .. self.port
end

mixin(TcpSocket, AsyncHandleMixin, AsyncStreamMixin, AsyncSocketMixin)

function TcpSocket:OnEvent(eventID, ...)
	DEBUG("[TcpSocket] OnEvent triggered", eventID, ...) -- TBD remove?

	local eventListener = self[eventID]
	if not eventListener then return end

	eventListener(self, eventID, ...)
end

_G.TcpSocket = TcpSocket

return TcpSocket