local scenario = Scenario:Construct("Cleaning up with FINALLY")

local hasRunCleanupFunction = false
local function fauxCleanupFunction()
	-- Better to be safe than sorry...
	if hasRunCleanupFunction then error("Cleanup should be run exactly once") end
	hasRunCleanupFunction = true
end

assertFalse(hasRunCleanupFunction)
scenario:FINALLY(fauxCleanupFunction)
assertTrue(scenario:HasCleanupFunction())
assertFalse(hasRunCleanupFunction)
scenario:Run()
assertTrue(hasRunCleanupFunction)