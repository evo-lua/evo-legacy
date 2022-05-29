
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

local globalPrint = _G.print -- Backup

-- This should likely be streamlined and made re-usable (later)?
local stdoutBuffer= ""
local function fauxPrint(...)
	stdoutBuffer = stdoutBuffer .. tostring(... or "") .. "\n"
end

local function resetFauxPrintBuffer()
	stdoutBuffer= ""
end

_G.print = fauxPrint

----------------------------------------------------------------------------------------------------------------

import("./Scenario/test-constructor.lua")

----------------------------------------------------------------------------------------------------------------

_G.print = globalPrint -- Restore

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
