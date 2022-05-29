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
assertEquals(scenario:GetNumFailedAssertions(), 42)

local fauxConsole = C_Testing:CreateFauxConsole()
assertEquals(fauxConsole.read(), "")

scenario:Run()

local expectedOutput = "todo"
assertEquals(fauxConsole.read(), expectedOutput)
fauxConsole.clear()

assertEquals(scenario:GetNumFailedAssertions(), 32)
assertTrue(scenario:HasFailed())