-- Whatever name or description you set here will be displayed in the final report
local scenario = Scenario:Construct("Testing the framework")

-- Whatever name or description you set here will be displayed in the final report
-- Labelling the individual phases is optional, but highly recommended
-- You can think of this notation as a shortcut for something like scenario:SetLabel("GIVEN", "Your text")
scenario:GIVEN("I have established the pre-conditions")
scenario:WHEN("I run the test code")
scenario:THEN("The post-conditions hold true")

-- Event handlers can be overridden to implement a simulation of the scenario you're testing
function scenario:OnSetup()
		-- This function should run all setup code and establish the preconditions you expect
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