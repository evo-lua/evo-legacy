-- Scenario: A new scenario is created without defining any script logic
local scenario = Scenario:Construct("Do nothing")
assert(scenario:GetName() == "Do nothing", "Should initialize a new scenario with the given name")

-- Human-readable overview should indicate no handlers were registered
local expectedOverviewText = "\n" -- To offset from the previous content (sub-optimal...)

expectedOverviewText = expectedOverviewText .. "\t" -- To highlight the keywords visually
expectedOverviewText = expectedOverviewText .. transform.cyan("Scenario: ") .. transform.white("Do nothing") .. "\n\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("GIVEN") .. "\t" ..  transform.white("(no preconditions)") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("WHEN") .. "\t" ..  transform.white("(no code to execute)") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("THEN") .. "\t" ..  transform.white("(no postconditions)") .. "\n"

assertEquals(scenario:GetOverviewText(), expectedOverviewText)

-- No assertions should be added
local expectedResultsText = ""
assertEquals(scenario:GetResultsText(), expectedResultsText)

-- Warning should be displayed instead of the actual summary (no assertions...)
local expectedSummaryText = transform.yellow("Warning: Nothing to assert (technically passing...)")
assertEquals(scenario:GetSummaryText(), expectedSummaryText)

-- Does nothing when run/empty initialization -> "stdoutBuffer should be empty before running the scenario"
local fauxConsole = C_Testing:CreateFauxConsole()
assertEquals(fauxConsole.read(), "")

scenario:Run(fauxConsole)
local expectedOutput = expectedOverviewText .. expectedResultsText .. "\n" .. expectedSummaryText .. "\n"
assertEquals(fauxConsole.read(), expectedOutput)

fauxConsole.clear()

assertFalse(scenario:HasFailed())