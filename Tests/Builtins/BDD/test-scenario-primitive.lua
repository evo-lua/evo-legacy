
local Scenario = _G.Scenario
assert(type(Scenario) == "table", "The Scenario primitive should be exported")

local exportedApiSurface = {
	"Construct",
	"Run",
	"PrintResults",
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
	"FINALLY",
}

for _, fieldName in pairs(exportedApiSurface) do
	assert(type(Scenario[fieldName]) == "function", "Should export function " .. fieldName)
end


----------------------------------------------------------------------------------------------------------------

import("./Scenario/test-noop-scenario.lua")
import("./Scenario/test-multi-assertions-scenario.lua")

----------------------------------------------------------------------------------------------------------------

print("OK\tBDD\t\tScenario")

-- Construct
-- GIVEN
-- WHEN
-- THEN
-- FINALLY

-- Run
-- PrintResults
-- GetName
-- GetResultsText
-- GetNumFailedAssertions
-- HasFailed
