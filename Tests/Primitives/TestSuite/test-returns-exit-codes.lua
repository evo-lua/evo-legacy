
local function testRunner()
	local testSuite = TestSuite:Construct("Failing test runner generates EXIT_FAILURE code")

	local failingScenario = Scenario:Construct("Scenario with failed assertion")
	function failingScenario:OnEvaluate()
		assert(1 == 0, "Should always fail and raise an error in the process")
	end
	testSuite:AddScenario(failingScenario)
	testSuite:Run()
end

local function onError(...)
	error("ERROR RAISED", ...)
end

xpcall(testRunner, onError)
