-- All paths should be relative to the project root so that Lua can find it
dofile("Tests/assertions.lua")
dofile("Tests/Environment/test-path.lua")

-- Failsafe to make sure no assertions are silently skipped
-- Not the most elegant solution, but it can be improved later...
local NUM_EXPECTED_ASSERTIONS = 422
local assertionsAreMissingError = string.format("Expected %d assertions (actual: %d)", NUM_EXPECTED_ASSERTIONS, _G.numAssertions)
assert(_G.numAssertions == NUM_EXPECTED_ASSERTIONS, assertionsAreMissingError)
print(string.format("OK\tAll tests completed\t%d assertions", _G.numAssertions))