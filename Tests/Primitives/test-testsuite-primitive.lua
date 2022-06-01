
local TestSuite = _G.TestSuite
assert(type(TestSuite) == "table", "The TestSuite primitive should be exported")

local exportedApiSurface = {
	"Construct",
	"AddScenario",
	"RunScenario",
	"RunAllScenarios",
	"ReportSummary",
}

for _, fieldName in pairs(exportedApiSurface) do
	assert(type(TestSuite[fieldName]) == "function", "Should export function " .. fieldName)
end

----------------------------------------------------------------------------------------------------------------

import("./TestSuite/test-noop-suite.lua")
import("./TestSuite/test-multi-scenario-suite.lua")
import("./TestSuite/test-returns-exit-failure.lua")

----------------------------------------------------------------------------------------------------------------

print("OK\tPrimitives\tTestSuite")

-- Construct
-- AddScenario
-- RunAllScenarios

-- RunScenario
-- ReportSummary