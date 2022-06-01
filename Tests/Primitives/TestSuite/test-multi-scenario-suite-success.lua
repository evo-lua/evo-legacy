local testSuite = TestSuite:Construct("TestSuite with multiple passing assertions")

assertEquals(testSuite:GetNumScenarios(), 0, "Should return zero if no scenarios have been added")

local scenario = Scenario:Construct("NOOP scenario")

function scenario:OnEvaluate()
	assert(1 == 1, "NOOP assertion #1")
	assert(42 == 42, "NOOP assertion #2")
	assert(1234 == 1234, "NOOP assertion #3")
end

testSuite:AddScenario(scenario)

assertEquals(testSuite:GetNumScenarios(), 1, "Should return one if a single scenarios has been added")

local fauxConsole = C_Testing.CreateFauxConsole()

assertEquals(fauxConsole.read(), "", "Should not display anything before the test suite was run")
testSuite:Run(fauxConsole)

local expectedConsoleOutput = TestSuite.HORIZONTAL_LINE_SEPARATOR .. "\n\n"
-- The 0.00ms is kinda risky here, but it's probably safe to assume the three NOOPS won't take any significant time...
expectedConsoleOutput = expectedConsoleOutput .. transform.cyan("Test Suite: ") .. transform.white("TestSuite with multiple passing assertions") .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. "\t" .. transform.green("✓") .. " " .. "NOOP scenario: 3 passing (0.00 ms)" .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. transform.green("All scenarios completed successfully!") .. "\n"
assertEquals(fauxConsole.read(), expectedConsoleOutput, "Should display a summary text indicating no scenarios have been added")
