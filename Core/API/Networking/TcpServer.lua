local TcpServer = {
	DEFAULT_BACKLOG_SIZE = 128
}

-- Streams
-- uv.shutdown(stream, [callback])
-- uv.listen(stream, backlog, callback)
-- uv.accept(stream, client_stream)
-- uv.read_start(stream, callback)
-- uv.read_stop(stream)
-- uv.write(stream, data, [callback])
-- uv.try_write(stream, data)
-- uv.is_readable(stream)
-- uv.stream_get_write_queue_size()

-- TCP
-- uv.tcp_nodelay(tcp, enable)
-- uv.tcp_keepalive(tcp, enable, [delay])
-- uv.tcp_simultaneous_accepts(tcp, enable)
-- uv.tcp_bind(tcp, host, port, [flags])
-- uv.tcp_getpeername(tcp)
-- uv.tcp_getsockname(tcp)
-- uv.tcp_connect(tcp, host, port, callback)

local uv = require("uv")

local function uvTcpHandle_ToString(uvTcpHandle)
	-- uv.tcp_getpeername(tcp)
	local peerAddressInfo = uvTcpHandle:getpeername() -- expose via self:GetClientInfo
	local currentAddress = uvTcpHandle:getsockname() -- expose via self:GetSocketInfo

	-- print("peerAddressInfo", peerAddressInfo)

	-- todo issue for print/dump interop...
	-- dump(peerAddressInfo)
	-- dump(currentAddress)
	-- tcpHandleToString
	local socketID = peerAddressInfo.family .. "://" .. peerAddressInfo.ip .. ":" .. peerAddressInfo.port

	-- tostring metamethod for TcpServer, Socket, etc., and create tests to ensure it always works

	return transform.bold("<"  .. socketID .. ">")
end


local setmetatable = setmetatable

function TcpServer:Construct()
	local instance = {
		uvTcpHandle = uv.new_tcp(),
		maxBacklogSize = TcpServer.DEFAULT_BACKLOG_SIZE,
		hostName = "",
		port = 0,
	}

	setmetatable(instance, { __index = TcpServer })

	return instance
end

local type = type

-- if args missing use defaults OR error. if wrong type, error or autoconvert if possible
-- if port not available, error OR use ephemeral port, use getsockname to look it up?

-- When the port is already taken, you can expect to see an EADDRINUSE error from either uv.tcp_bind(), uv.listen() or uv.tcp_connect(). That is, a successful call to this function does not guarantee that the call to uv.listen() or uv.tcp_connect() will succeed as well.
function TcpServer:StartListening(hostName, port)
	-- assertURL(self:GetHostName())
	DEBUG("Listening on tcp://" .. hostName .. ":" .. port)

	self.hostName = hostName
	self.port = port

	local function onIncomingConnectionCallback(errorMessageOrNil)
		if type(errorMessageOrNil) == "string" then return self:OnError(errorMessageOrNil) end

		-- This is guaranteed to succeed when called the first time (by libuv)
		local client = uv.new_tcp()
		self.uvTcpHandle:accept(client)

		-- OnConnectionEstablished / OnSessionStart

		-- tbd store clients in list for later? numConnectedClients++
		client:read_start(function (err, chunk)
			print("read_start", chunk, err)

			if err then return self:OnClientError(client, err) end

			if chunk then
				print("Received data", chunk)
			  client:write(chunk)
			else
				print("No data received, shutting down")
				self:DisconnectClient(client) -- OnSessionEnd
			--   client:shutdown()
			--   client:close()
			end
		  end)

		self:OnIncomingConnection(client)
	end

	self.uvTcpHandle:bind(hostName, port)
	self.uvTcpHandle:listen(self.maxBacklogSize, onIncomingConnectionCallback)
end

function TcpServer:OnClientError(client, errorMessage)

	if errorMessage == "ECONNRESET" then
		errorMessage = transform.yellow("Connection was forcibly closed by peer [ECONNRESET]")
	end

	ERROR("OnClientError", errorMessage)
	dump(client)

	self:DisconnectClient(client)
end

function TcpServer:DisconnectClient(client)
	DEBUG("Disconnecting client: " .. uvTcpHandle_ToString(client)) -- readable client info
	client:shutdown()
	client:close()
end

function TcpServer:OnError(errorMessage)
	ERROR("OnError", errorMessage)
end

function TcpServer:OnIncomingConnection(client)
	EVENT("INCOMING_TCP_CONNECTION", uvTcpHandle_ToString(client))
end

_G.TcpServer = TcpServer

return TcpServer