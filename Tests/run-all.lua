-- All paths should be relative to the project root so that Lua can find it
dofile("Tests/assertions.lua")
dofile("Tests/Environment/test-path.lua")
dofile("Tests/Libs/test-v8-string-lastindexof.lua")

-- Failsafe to make sure no assertions are silently skipped
-- Not the most elegant solution, but it can be improved later...
local NUM_EXPECTED_ASSERTIONS_PER_TEST_SUITE = {
	["Tests/Environment/test-path.lua"] = 422,
	["Tests/Libs/test-v8-string-lastindexof.lua"] = 68,
}

-- Super basic helper; I guess it could be generalized but YAGNI?
local function sum_values(t)
	local sum = 0
	for k, v in pairs(t) do
		sum = sum + v
	end
	return sum
end

local NUM_EXPECTED_ASSERTIONS = sum_values(NUM_EXPECTED_ASSERTIONS_PER_TEST_SUITE)
local assertionsAreMissingError = string.format("Expected %d assertions (actual: %d)", NUM_EXPECTED_ASSERTIONS, _G.numAssertions)

assert(_G.numAssertions == NUM_EXPECTED_ASSERTIONS, assertionsAreMissingError)
print(string.format("OK\tAll tests completed\t%d assertions", _G.numAssertions))