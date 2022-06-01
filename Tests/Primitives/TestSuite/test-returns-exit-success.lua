local testSuite = TestSuite:Construct("Failing test runner generates EXIT_SUCCESS code")

local failingScenario = Scenario:Construct("Scenario with passing assertion")
function failingScenario:OnEvaluate()
	assert(1 == 1, "Should always succeed and NOT raise an error in the process")
end
testSuite:AddScenario(failingScenario)
assertTrue(testSuite:Run(), "Should return true if at not a single assertion has failed")