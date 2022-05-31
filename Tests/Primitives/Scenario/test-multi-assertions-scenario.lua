local scenario = Scenario:Construct("Multiple assertions (some failing)")

local someValue = 0

scenario:GIVEN("Some preconditions are true")
scenario:WHEN("I run the test code")
scenario:THEN("The post-conditions hold true")

function scenario:OnRun()
	someValue = 42
end

function scenario:OnEvaluate()
	assert(someValue == 42, "Some value is set to 42")
	assert(someValue == 43, "Some value is set to 43")
	assert(someValue == 44, "Some value is set to 44")
end


assertFalse(scenario:HasFailed(), "Should return false before the scenario was run")
assertEquals(scenario:GetNumFailedAssertions(), 0, "Should return zero before the scenario was run")


local expectedOverviewText = "\n" -- To offset from the previous content (sub-optimal...)

expectedOverviewText = expectedOverviewText .. "\t" -- To highlight the keywords visually
expectedOverviewText = expectedOverviewText .. transform.cyan("Scenario: ") .. transform.white("Multiple assertions (some failing)") .. "\n\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("GIVEN") .. "\t" ..  transform.white("(no preconditions)") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("WHEN") .. "\t" ..  transform.white("I run the test code") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("THEN") .. "\t" ..  transform.white("The post-conditions hold true") .. "\n"

local fauxConsole = C_Testing:CreateFauxConsole()
assertEquals(fauxConsole.read(), "",  "Should not have printed anything before the scenario was run")

scenario:Run(fauxConsole)

assertEquals(scenario:GetOverviewText(), expectedOverviewText, "Should return a string representation of the scenario in a standardized format")

local expectedResultsText = "\t\t" .. transform.green("✓") .. " Some value is set to 42\n"
expectedResultsText = expectedResultsText .. "\t\t" .. transform.red("✗") .. " Some value is set to 43\n"
expectedResultsText = expectedResultsText .. "\t\t" .. transform.red("✗") .. " Some value is set to 44\n"
assertEquals(scenario:GetResultsText(), expectedResultsText, "Should return the evaluation results text")


local expectedSummaryText = transform.brightRedBackground("2 FAILED assertions!")
assertEquals(scenario:GetSummaryText(), expectedSummaryText, "Should return the summary text")


local expectedOutput = expectedOverviewText .. "\n" .. expectedResultsText .. "\n" .. expectedSummaryText .. "\n"
assertEquals(fauxConsole.read(), expectedOutput, "Should display the full report text when the scenario is run")
fauxConsole.clear()

assertEquals(scenario:GetNumFailedAssertions(), 2, "Should return the number of failed assertions after the scenario was run")
assertTrue(scenario:HasFailed(), "Should return true if some assertions have failed after the scenario was run")