local scenario = Scenario:Construct("Multiple assertions (some failing)")

local someValue = 0

scenario:WHEN(
	"I run the test code",
	function()
		someValue = 42
	end
)

scenario:THEN(
	"The post-conditions hold true",
	function()
		assert(someValue == 42, "Some value is set to 42")
		assert(someValue == 43, "Some value is set to 43")
		assert(someValue == 44, "Some value is set to 44")
	end
)

assertFalse(scenario:HasFailed())
assertEquals(scenario:GetNumFailedAssertions(), 0)

local fauxConsole = C_Testing:CreateFauxConsole()
assertEquals(fauxConsole.read(), "")

local expectedOverviewText = "\n" -- To offset from the previous content (sub-optimal...)

expectedOverviewText = expectedOverviewText .. "\t" -- To highlight the keywords visually
expectedOverviewText = expectedOverviewText .. transform.cyan("Scenario: ") .. transform.white("Multiple assertions (some failing)") .. "\n\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("GIVEN") .. "\t" ..  transform.white("(no preconditions)") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("WHEN") .. "\t" ..  transform.white("I run the test code") .. "\n"
expectedOverviewText = expectedOverviewText .. "\t" .. transform.cyan("THEN") .. "\t" ..  transform.white("The post-conditions hold true") .. "\n"

-- Does nothing when run/empty initialization -> "stdoutBuffer should be empty before running the scenario"
assertEquals(fauxConsole.read(), "")

scenario:Run(fauxConsole)

assertEquals(scenario:GetOverviewText(), expectedOverviewText)

local expectedResultsText = "\t\t" .. transform.green("✓") .. " Some value is set to 42\n"
expectedResultsText = expectedResultsText .. "\t\t" .. transform.red("✗") .. " Some value is set to 43\n"
expectedResultsText = expectedResultsText .. "\t\t" .. transform.red("✗") .. " Some value is set to 44\n"
assertEquals(scenario:GetResultsText(), expectedResultsText)


local expectedSummaryText = transform.brightRedBackground("2 FAILED assertions!")
assertEquals(scenario:GetSummaryText(), expectedSummaryText)


local expectedOutput = expectedOverviewText .. expectedResultsText .. "\n" .. expectedSummaryText .. "\n"
assertEquals(fauxConsole.read(), expectedOutput)
fauxConsole.clear()

assertEquals(scenario:GetNumFailedAssertions(), 32)
assertTrue(scenario:HasFailed())