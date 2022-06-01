local testSuite = TestSuite:Construct("Adding multiple scenarios at once")

local listOfScenarioFilesToLoad = {
	"../../Fixtures/example-scenario-file-1.lua",
	"../../Fixtures/example-scenario-file-2.lua",
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

local fauxConsole = C_Testing.CreateFauxConsole()
assertEquals(fauxConsole.read(), "", "Should not display anything before the test suite was run")
testSuite:Run(fauxConsole)

local expectedConsoleOutput = TestSuite.HORIZONTAL_LINE_SEPARATOR .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. transform.cyan("Test Suite: ") .. transform.white("Adding multiple scenarios at once") .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. "\t" .. transform.green("✓") .. " " .. "Asserting some stuff: 1 passing (0.00 ms)" .. "\n"
expectedConsoleOutput = expectedConsoleOutput .. "\t" .. transform.green("✓") .. " " .. "Asserting some more stuff: 1 passing (0.00 ms)" .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. transform.green("All scenarios completed successfully!") .. "\n"

assertEquals(fauxConsole.read(), expectedConsoleOutput, "Should display the expected result after loading and running all scenario files")

assertFalse(testSuite:HasFailedScenarios(), "Should return false if no scenarios have failed")