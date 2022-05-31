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

assertEquals(scenario:GetOverviewText(), expectedOverviewText, "Should return a string representation of the scenario in a standardized format")

-- No assertions should be added
local expectedResultsText = ""
assertEquals(scenario:GetResultsText(), expectedResultsText, "Should return an empty string if no assertions have been added")

local expectedSummaryText = transform.yellow("Warning: Nothing to assert (technically passing...)")
assertEquals(scenario:GetSummaryText(), expectedSummaryText, "Should return a warning instead of the summary if no assertions have been added")

local fauxConsole = C_Testing:CreateFauxConsole()
assertEquals(fauxConsole.read(), "", "Should not have printed anything before the scenario was fun")

scenario:Run(fauxConsole)
local expectedOutput = expectedOverviewText .. expectedResultsText .. "\n" .. expectedSummaryText .. "\n"
assertEquals(fauxConsole.read(), expectedOutput, "Should display the full report text when the scenario is run")

fauxConsole.clear()

assertEquals(scenario:GetNumFailedAssertions(), 0, "Should return zero if no assertions have been added")
assertFalse(scenario:HasFailed(), "Should return false if no assertions have been added")