
local Scenario = _G.Scenario
assert(type(Scenario) == "table", "The Scenario primitive should be exported")

local exportedApiSurface = {
	"Construct",
	"Run",
	"PrintResults",
	"GetName",
	"GetResultsText",
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
	-- error("faux print used")
	stdoutBuffer = stdoutBuffer .. tostring(... or "") .. "\n"
end

local function resetFauxPrintBuffer()
	stdoutBuffer= ""
end

_G.print = fauxPrint

----------------------------------------------------------------------------------------------------------------

-- Scenario: A new scenario is created without defining any script logic
local scenario = Scenario:Construct("Do nothing")
assert(scenario:GetName() == "Do nothing", "Should initialize a new scenario with the given name")

-- Does nothing when run/empty initialization -> "stdoutBuffer should be empty before running the scenario"
assertEquals(stdoutBuffer, "")

scenario:Run(fauxPrint)

-- Since there's no scripts attached to the scenario, it should just print nothing as its summary?
-- TBD should display 0 tests run/0 assertions maybe?
-- "stdoutBuffer should be empty after running the scenario"
assertEquals(stdoutBuffer, "")

resetFauxPrintBuffer()

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
