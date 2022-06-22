local scenario = Scenario:Construct("TCP echo server")

local TcpServer = C_Networking.TcpServer
local TcpClient = C_Networking.TcpClient

scenario:GIVEN("A TCP echo server is listening on localhost")
scenario:WHEN("A TCP client sends some data to the server")
scenario:THEN("The server should send the same data back to the client")

local hasClientSentMessageToServer = false
local hasServerReceivedMessage = false
local hasServerSentResponse = false
local hasClientReceivedEchoMessage = false

function scenario:OnSetup()
	local serverOptions = {
		port = 1234,
		hostName = "127.0.0.1",
	}
	self.server = TcpServer(serverOptions)
	self.client = TcpClient("127.0.0.1", 1234)
end

function scenario:OnRun()
	local currentThread = coroutine.running()
	local client = self.client

	function client:TCP_CONNECTION_ESTABLISHED()
		self:Send("Hello server!")
		hasClientSentMessageToServer = true
	end

	function client:TCP_CHUNK_RECEIVED(chunk)
		assertEquals(chunk, "Hello server!", "Should receive the same message that was originally sent")
		hasClientReceivedEchoMessage = true
		-- The echo test is over, so we can continue with the report
		coroutine.resume(currentThread)
	end

	local server = self.server
	function server:TCP_CHUNK_RECEIVED(client, chunk)
		assertEquals(chunk, "Hello server!")
		hasServerReceivedMessage = true
		self:Send(client, chunk)
	end

	function server:TCP_WRITE_SUCCEEDED(client, chunk)
		hasServerSentResponse = true
	end

	-- Hand off control to libuv to let async requests complete
	coroutine.yield()
end

function scenario:OnEvaluate()
	assertTrue(hasClientSentMessageToServer, "The client should have sent a message to the server")
	assertTrue(hasServerReceivedMessage, "The server should have received the client's message")
	assertTrue(hasServerSentResponse, "The server should have sent a response")
	assertTrue(hasClientReceivedEchoMessage, "The client should have received the response")
end

function scenario:OnCleanup()
	self.client:Disconnect()
	self.server:StopListening()
end

return scenario