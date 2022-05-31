
local Scenario = _G.Scenario
assert(type(Scenario) == "table", "The Scenario primitive should be exported")

local exportedApiSurface = {
	"Construct",
	"OnSetup",
	"OnRun",
	"OnEvaluate",
	"OnCleanup",
	"OnReport",
	"Run",
	"GetName",
	"ToString",
	"GetOverviewText",
	"GetResultsText",
	"GetSummaryText",
	"GetNumFailedAssertions",
	"HasFailed",
	"GIVEN",
	"WHEN",
	"WHEN",
	"THEN",
}

for _, fieldName in pairs(exportedApiSurface) do
	assert(type(Scenario[fieldName]) == "function", "Should export function " .. fieldName)
end

----------------------------------------------------------------------------------------------------------------

import("./Scenario/test-noop-scenario.lua")
import("./Scenario/test-multi-assertions-scenario.lua")
import("./Scenario/test-event-handlers-are-run.lua")

----------------------------------------------------------------------------------------------------------------

print("OK\tPrimitives\tScenario")