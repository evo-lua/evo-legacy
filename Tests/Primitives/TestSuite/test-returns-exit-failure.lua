-- local EXIT_SUCCESS = 0
-- local EXIT_FAILURE = 1

-- local presumedExitCode = EXIT_SUCCESS -- Lua default, if error() was not called



-- local function fauxErrorHandler(...)
-- 	presumedExitCode = EXIT_FAILURE -- Whenever error() is called, the exit code is set to 1 by Lua
-- 	-- Since even the custom ERROR builtin forwards everything to the default handler in the end, this should be reliable enough
-- 	error(...)
-- end

-- local defaultErrorHandler = error
-- _G.error = fauxErrorHandler -- Intercept to ensure the error handler is called - we can assume it sets the exit code properly (Lua API)

local testSuite = TestSuite:Construct("Failing test runner generates EXIT_FAILURE code")

local failingScenario = Scenario:Construct("Scenario with failed assertion")
function failingScenario:OnEvaluate()
	assert(1 == 0, "Should always fail and raise an error in the process")
end
testSuite:AddScenario(failingScenario)
assertFalse(testSuite:Run(), "Should return false if at least one assertion has failed")

-- _G.error = defaultErrorHandler -- Restore ASAP to avoid unintended side effects

-- -- assertEquals(presumedExitCode, EXIT_FAILURE, "Should set the exit code to EXIT_FAILURE while running a test suite if any assertions have failed")
