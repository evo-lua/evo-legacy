local testSuite = TestSuite:Construct("TestSuite with no scenarios")

assertEquals(testSuite:GetNumScenarios(), 0, "Should return zero if no scenarios have been added")

local fauxConsole = C_Testing.CreateFauxConsole()

assertEquals(fauxConsole.read(), "", "Should not display anything before the test suite was run")
testSuite:ReportSummary(fauxConsole)

local expectedConsoleOutput = TestSuite.REPORT_HORIZONTAL_LINE .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput ..transform.cyan("Test Suite: ") .. transform.white("TestSuite with no scenarios") .. "\n\n"
expectedConsoleOutput = expectedConsoleOutput .. transform.yellow("Warning: No scenarios to run (technically passing...)") .. "\n"
assertEquals(fauxConsole.read(), expectedConsoleOutput, "Should display a summary text indicating no scenarios have been added")
