local testSuite = TestSuite:Construct("TestSuite with multiple failing assertions")

assertEquals(testSuite:GetNumScenarios(), 0, "Should return zero if no scenarios have been added")

local scenario = Scenario:Construct("NOOP scenario")

function scenario:OnEvaluate()
	assert(1 == 1, "NOOP assertion #1")
	assert(42 == 0, "FAILED assertion #1")
	assert(1234 == 12345, "FAILED assertion #2")
end

testSuite:AddScenario(scenario)

assertEquals(testSuite:GetNumScenarios(), 1, "Should return one if a single scenarios has been added")

local fauxConsole = C_Testing.CreateFauxConsole()

assertEquals(fauxConsole.read(), "", "Should not display anything before the test suite was run")
testSuite:Run(fauxConsole)

local expectedConsoleOutput = TestSuite.HORIZONTAL_LINE_SEPARATOR .. "\n\n"
-- The 0.00ms is kinda risky here, but it's probably safe to assume the three NOOPS won't take any significant time...
expectedConsoleOutput = expectedConsoleOutput ..transform.cyan("Test Suite: ") .. transform.white("TestSuite with multiple failing assertions") .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .."\t" .. transform.red("✗") .. " " .. "NOOP scenario: " .. transform.brightRedBackground("2 FAILED assertions") .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. transform.brightRedBackground("1 scenario failed!") .. "\n"
assertEquals(fauxConsole.read(), expectedConsoleOutput, "Should display a summary text indicating no scenarios have been added")
