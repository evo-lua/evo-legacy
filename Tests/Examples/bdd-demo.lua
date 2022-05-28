    local Example = {}

	function Example:Execute()

		local testSuite = TestSuite:Construct("Basic demonstration")
		local scenario = Scenario:Construct("Testing the framework")

		scenario:GIVEN(
			"I have established the pre-conditions",
			function()
				-- This function should run all setup code ("establish preconditions" for the test)
			end
		)

		scenario:WHEN(
			"I run the test code",
			function()
				-- This function should run the code under test
				self.someValue = 42
			end
		)

		scenario:THEN(
			"The post-conditions hold true",
			function()
				-- This function should assert the expected post-conditions
				assert(self.someValue == 42, "Some value is set correctly")
			end
		)

		scenario:FINALLY(function()
			-- Cleanup tasks; this won't be displayed in the final report
		end)

		testSuite:AddScenario(scenario)
		testSuite:RunAllScenarios()

	end

	Example:Execute()