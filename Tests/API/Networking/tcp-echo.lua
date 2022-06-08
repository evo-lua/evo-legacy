local scenario = Scenario:Construct("TCP echo server")

-- Whatever name or description you set here will be displayed in the final report
-- Labelling the individual phases is optional, but highly recommended
-- You can think of this notation as a shortcut for something like scenario:SetLabel("GIVEN", "Your text")
scenario:GIVEN("I start a TCP echo server on localhost")
scenario:WHEN("A TCP client sends some data to the server")
scenario:THEN("The server should send the same data back to the client")

-- local

-- Event handlers can be overridden to implement a simulation of the scenario you're testing
function scenario:OnSetup()
	self.server = C_Networking.CreateTcpServer()
	self.client = C_Networking.CreateSocket()

	self.server:StartListening("127.0.0.1", 1234)
	self.client:StartConnecting("127.0.0.1", 1234)
end

function scenario:OnRun()
        -- This function should run the code that you want to test
			self.someValue = 42
		end

		function scenario:OnEvaluate()
		-- This function should assert the expected post-conditions, using standard assertions
		assert(self.someValue == 42, "Some value is set correctly")
end

function scenario:OnCleanup()
    -- This should undo any setup you've had to do to establish the pre-conditions
end

-- Return scenario instance as a Lua module
return scenario